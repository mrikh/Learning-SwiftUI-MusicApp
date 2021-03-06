//
//  SelectDevice.swift
//  MrMusic
//
//  Created by Mayank Rikh on 01/03/21.
//

import CoreBluetooth
import SwiftUI

struct SelectDevice: View {

    @State var mode : PartyMode.Mode
    @EnvironmentObject var multipeerManager : MultipeerConnectionManager
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
            
            if mode == .bluetooth{
                ForEach(centralManager.bluetoothDevicesList, id: \.identifier) { (peripheral: CBPeripheral) in

                    Button(peripheral.name ?? "Name not found") {
                        centralManager.selectedDevice = peripheral
                        completion?()
                    }
                }
            }else{
                ForEach(multipeerManager.peers, id: \.self){ peer in
                    Button(peer.displayName) {
                        multipeerManager.invitePeer(peer)
                        completion?()
                    }
                }
            }
        }
        .onAppear{
            if mode == .bluetooth{
                centralManager.startScan()
            }else{
                multipeerManager.browsingUpdate(start: true)
            }
        }
        .onDisappear{
            if mode == .bluetooth{
                centralManager.stopScan()
            }else{
                multipeerManager.browsingUpdate(start: false)
            }
        }
        .alert(isPresented: $centralManager.disabled) {
            Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
        }
    }
}

struct SelectDevice_Previews: PreviewProvider {
    static var previews: some View {
        SelectDevice(mode: .bluetooth)
    }
}
