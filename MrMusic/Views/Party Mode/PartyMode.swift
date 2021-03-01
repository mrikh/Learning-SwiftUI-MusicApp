//
//  PartyMode.swift
//  MrMusic
//
//  Created by Mayank Rikh on 27/02/21.
//

import CoreBluetooth
import MediaPlayer
import SwiftUI

struct PartyMode: View {
    
    @EnvironmentObject var musicStore : MusicDataStore
    @State private var showingDetail = false
    @State private var currentPlaylist : MPMediaPlaylist?{
        didSet{
            currentItems = currentPlaylist?.items ?? [MPMediaItem]()
        }
    }
    @EnvironmentObject var bluetoothManager : BluetoothManager
    @State private var showAlert : Bool = false
    @State private var mode : Mode = .bluetooth
    
    @State private var currentItems = [MPMediaItem]()
    
    var body: some View {
        
        List{
            if currentPlaylist != nil{
                
                HStack{
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Button("Use Bluetooth") {
                        mode = .bluetooth
                    }
                    if mode == .bluetooth{
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
                
                HStack{
                    Image(systemName: "network")
                    Button("Use Network") {
                        mode = .network
                    }
                    if mode == .network{
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
                
                Button(action: {
                    showingDetail.toggle()
                }, label: {
                    HStack{
                        Text("Change Playlist")
                        if let name = currentPlaylist?.name{
                            Spacer()
                            Text(name)
                        }
                    }
                })
                .sheet(isPresented: $showingDetail, content: {
                    PlaylistView { (playlist) in
                        currentPlaylist = playlist
                        showingDetail.toggle()
                    }
                })
                
                ForEach(currentItems, id: \.persistentID){ mediaItem in
                    SongsListingRow(mediaItem: mediaItem)
                }
                .onMove(perform: move)
                
            }else{
                Button(action: {
                    showingDetail.toggle()
                }, label: {
                    Text("Choose a Playlist")
                })
                .sheet(isPresented: $showingDetail, content: {
                    PlaylistView { (playlist) in
                        currentPlaylist = playlist
                        showingDetail.toggle()
                    }
                })
            }
        }
        .toolbar{
            EditButton()
        }
        .navigationTitle("Party Mode")
        .onAppear{
            showAlert = !bluetoothManager.enabled
            bluetoothManager.errorHandler = {
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        currentItems.move(fromOffsets: source, toOffset: destination)
    }
    
    enum Mode{
        case bluetooth
        case network
    }
}

struct PartyMode_Previews: PreviewProvider {
    static var previews: some View {
        PartyMode()
    }
}
