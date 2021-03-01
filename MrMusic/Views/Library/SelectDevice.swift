//
//  SelectDevice.swift
//  MrMusic
//
//  Created by Mayank Rikh on 01/03/21.
//

import CoreBluetooth
import SwiftUI

struct SelectDevice: View {
    
    @EnvironmentObject var bluetoothManager : BluetoothManager
    @State private var showAlert = false
    
    var body: some View {
        List{
            HStack(spacing: 10){
                Text("Fetching Devices")
                    .font(.largeTitle).bold()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            ForEach(bluetoothManager.bluetoothDevicesList, id: \.identifier) { (peripheral: CBPeripheral) in
                Text(peripheral.name ?? "Name not found")
            }
        }
        .onAppear{
            bluetoothManager.errorHandler = {
                showAlert = true
            }
            bluetoothManager.startScan()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
        }
    }
}

struct SelectDevice_Previews: PreviewProvider {
    static var previews: some View {
        SelectDevice()
    }
}
