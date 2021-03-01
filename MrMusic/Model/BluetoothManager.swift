//
//  BluetoothManager.swift
//  MrMusic
//
//  Created by Mayank Rikh on 28/02/21.
//

import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, CBCentralManagerDelegate, ObservableObject{
    
    private var bluetoothManager : CBCentralManager?
    
    @Published var bluetoothDevicesList : [CBPeripheral] = []
    
    var errorHandler : (()->())?
    var enabled : Bool = false
    
    override init(){
        super.init()
        bluetoothManager = CBCentralManager()
        bluetoothManager?.delegate = self
    }
    
    func startScan(){
        
        if !enabled {
            errorHandler?()
            return
        }

        bluetoothManager?.scanForPeripherals(withServices: nil, options: nil)
    }
}

//MARK:- Delegate
extension BluetoothManager{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            enabled = true
        default:
            enabled = false
            errorHandler?()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        #warning("Temp hack")
        if peripheral.name == nil {return}
        
        if !bluetoothDevicesList.contains(peripheral){
            bluetoothDevicesList.append(peripheral)
        }
    }
}
