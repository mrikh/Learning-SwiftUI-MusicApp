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
    
    var errorHandler : (()->())?
    
    override init(){
        super.init()
        bluetoothManager = CBCentralManager()
        bluetoothManager?.delegate = self
    }
    
    //delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn: break
            default:
                errorHandler?()
            }
    }
}
