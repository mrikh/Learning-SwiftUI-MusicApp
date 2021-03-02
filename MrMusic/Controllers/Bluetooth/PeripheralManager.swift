//
//  PeripheralManager.swift
//  MrMusic
//
//  Created by Mayank Rikh on 01/03/21.
//

import CoreBluetooth
import MediaPlayer
import Foundation

class PeripheralManager: NSObject, ObservableObject{
    
    @Published var disabled : Bool = false
    
    private var peripheralManager : CBPeripheralManager!
    private var transferCharacteristic: CBMutableCharacteristic?
    private var data = Data()
    private var connectedCentral: CBCentral?
    private var sendDataIndex: Int = 0
    var musicItem : MPMediaItem?
    
    override init(){
        super.init()
        peripheralManager = CBPeripheralManager()
        peripheralManager.delegate = self
    }
    
    func startAdvertising(){
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey : "MrMusic",  CBAdvertisementDataServiceUUIDsKey: [Services.TransferUUID]])
    }
    
    func stopAdvertising(){
        peripheralManager.stopAdvertising()
    }
    
    private func setupPeripheral(){
        
        let transferCharacteristic = CBMutableCharacteristic(type: Services.CharacteristicUUID, properties: [.notify, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        let transferService = CBMutableService(type: Services.TransferUUID, primary: true)
        
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
        self.transferCharacteristic = transferCharacteristic
    }
    
    private static var sendingEOM = false
    private func sendData(){
        
        guard let transferCharacteristic = transferCharacteristic else {return}
        guard let item = self.musicItem, let url = item.assetURL else {return}
        
        if PeripheralManager.sendingEOM {
            // send it
            let didSend = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            // Did it send?
            if didSend {
                // It did, so mark it as sent
                PeripheralManager.sendingEOM = false
            }
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }
        
        export(url) { [self] (outputUrl, error) in
            self.data = try! Data(contentsOf: outputUrl!)
            
            if self.sendDataIndex >= self.data.count {
                // No data left.  Do nothing
                return
            }
            
            // There's data left, so send until the callback fails, or we're done.
            var didSend = true
            while didSend {
                // Work out how big it should be
                var amountToSend = self.data.count - self.sendDataIndex
                if let mtu = self.connectedCentral?.maximumUpdateValueLength {
                    amountToSend = min(amountToSend, mtu)
                }
                
                // Copy out the data we want
                let chunk = self.data.subdata(in: self.sendDataIndex..<(self.sendDataIndex + amountToSend))
                
                // Send it
                didSend = self.peripheralManager.updateValue(chunk, for: transferCharacteristic, onSubscribedCentrals: nil)
                
                // If it didn't work, drop out and wait for the callback
                if !didSend { return }
                
                #if DEBUG
                print("Sent %d bytes: %s", chunk.count)
                #endif
                
                // It did send, so update our index
                self.sendDataIndex += amountToSend
                // Was it the last one?
                if self.sendDataIndex >= self.data.count {
                    
                    PeripheralManager.sendingEOM = true
                    
                    let eomSent = self.peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
                    
                    if eomSent{
                        PeripheralManager.sendingEOM = false
                    }
                    
                    return
                }
            }
        }
    }
    
    private func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Sorry! Something went wrong."]))
            return
        }

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")

        exporter.outputURL = fileURL
        exporter.outputFileType = .m4a

        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate{
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            disabled = false
            setupPeripheral()
            startAdvertising()
        default:
            disabled = true
        }
    }
    
    //someone subscribed to our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        sendDataIndex = 0
        connectedCentral = central
        
        //sendData
        sendData()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        connectedCentral = nil
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        // Start sending again
        sendData()
    }
}
