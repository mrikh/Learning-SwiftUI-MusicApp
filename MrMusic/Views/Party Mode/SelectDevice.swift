//
//  SelectDevice.swift
//  MrMusic
//
//  Created by Mayank Rikh on 01/03/21.
//

import CoreBluetooth
import SwiftUI

struct SelectDevice: View {
    
    @EnvironmentObject var centralManager : CentralManager
    var completion : (()->())?
    
    var body: some View {
        List{
            HStack(spacing: 10){
                Text("Fetching Devices")
                    .font(.largeTitle).bold()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            ForEach(centralManager.bluetoothDevicesList, id: \.identifier) { (peripheral: CBPeripheral) in

                Button(peripheral.name ?? "Name not found") {
                    centralManager.selectedDevice = peripheral
                    completion?()
                }
            }
        }
        .onAppear{
            centralManager.startScan()
        }
        .alert(isPresented: $centralManager.disabled) {
            Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
        }
    }
}

struct SelectDevice_Previews: PreviewProvider {
    static var previews: some View {
        SelectDevice()
    }
}
