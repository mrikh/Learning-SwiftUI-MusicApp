//
//  CentralManager.swift
//  MrMusic
//
//  Created by Mayank Rikh on 28/02/21.
//

import CoreBluetooth
import Foundation

class CentralManager: NSObject, CBCentralManagerDelegate, ObservableObject{
    
    private var bluetoothManager : CBCentralManager!
    private var data : Data = Data()
    private var transferCharacteristic: CBCharacteristic?
    
    @Published var bluetoothDevicesList : [CBPeripheral] = []
    var selectedDevice : CBPeripheral?{
        didSet{
            if let device = selectedDevice{
                bluetoothManager?.connect(device, options: nil)
            }
        }
    }
    
    @Published var disabled : Bool = false
    var receivedString : String = ""
    
    @Published var showReceivedString : Bool = false
    
    override init(){
        super.init()
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
    }
    
    func startScan(){
        
        let connectedPeripherals: [CBPeripheral] = bluetoothManager.retrieveConnectedPeripherals(withServices: [Services.TransferUUID])
        
        //reconnect to previous one as otherwise its not disconnected and doesnt restart everything
        if let connectedPeripheral = connectedPeripherals.last {
            selectedDevice = connectedPeripheral
        } else {
            // We were not connected to our counterpart, so start scanning
            bluetoothManager.scanForPeripherals(withServices: [Services.TransferUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func stopScan(){
        bluetoothManager.stopScan()
    }
    
    func cleanup(){
        
        guard let current = self.selectedDevice, current.state == .connected else {return}
        
        for service in current.services ?? []{
            for characteristic in service.characteristics ?? []{
                if characteristic.uuid == Services.CharacteristicUUID && characteristic.isNotifying{
                    self.selectedDevice?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        bluetoothManager.cancelPeripheralConnection(current)
        selectedDevice = nil
    }
}

//MARK:- CBCentralManager Delegate
extension CentralManager{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            disabled = false
            startScan()
        default:
            disabled = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        #warning("Temp hack")
        if peripheral.name == nil {return}
        
        if !bluetoothDevicesList.contains(peripheral){
            bluetoothDevicesList.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        bluetoothManager.stopScan()
        
        //clear preexisting data
        data.removeAll(keepingCapacity : false)
        
        peripheral.delegate = self
        peripheral.discoverServices([Services.TransferUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        cleanup()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        cleanup()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
        for services in invalidatedServices{
            for characteristic in services.characteristics ?? [] where characteristic.uuid == Services.CharacteristicUUID {
                // If it is, subscribe to it
                peripheral.setNotifyValue(false, for: characteristic)
                bluetoothManager.cancelPeripheralConnection(peripheral)
                selectedDevice = nil
            }
        }
    }
}

//MARK:- CBPeripheral Delegate
extension CentralManager : CBPeripheralDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([Services.CharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == Services.CharacteristicUUID {
            // If it is, subscribe to it
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let characteristicData = characteristic.value  else { return }
        
        #if DEBUG
        print("Received %d bytes: %s", characteristicData.count)
        #endif
        
        self.receivedString += String(data: characteristicData, encoding: .utf8)!
        
        #if DEBUG
        print(self.receivedString)
        #endif
        
        // Have we received the end-of-message token?
        if let stringFromData = String(data: characteristicData, encoding: .utf8), stringFromData == "EOM" {
            // End-of-message case: show the data.
            // Dispatch the text view update to the main queue for updating the UI, because
            // we don't know which thread this method will be called back on.
            DispatchQueue.main.async() {
                // Write test data
                self.showReceivedString = true
            }
        } else {
            // Otherwise, just append the data to what we have previously received.
            data.append(characteristicData)
        }
    }
}
