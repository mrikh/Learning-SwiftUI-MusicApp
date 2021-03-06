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
    
    @State private var playLatest = false
    @StateObject var centralManager = CentralManager()
    @StateObject var multipeerManager = MultipeerConnectionManager()
    
    @EnvironmentObject var musicStore : MusicDataStore
    
    @State private var showDevicesListing = false
    @State private var showingDetail = false
    @State private var currentPlaylist : MPMediaPlaylist?{
        didSet{
            currentItems = currentPlaylist?.items ?? [MPMediaItem]()
        }
    }
    
    @State private var showAlert : Bool = false
    @State private var mode : Mode = .bluetooth
    
    @State private var currentItems = [MPMediaItem]()
    
    var body: some View {
        
        
        ZStack(alignment: .bottom){
            List{
                if currentPlaylist != nil{
                    
                    HStack{
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Button("Use CoreBluetooth") {
                            mode = .bluetooth
                        }
                        if mode == .bluetooth{
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                    
                    HStack{
                        Image(systemName: "network")
                        Button("Use Multipeer") {
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
                    
                    Button("Start Scanning") {
                        
                        if mode == .bluetooth{
                            centralManager.cleanup()
                            showDevicesListing = true
                        }else{
                            multipeerManager.advertisingUpdate(start: true)
                        }
                    }
                    
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
            .sheet(isPresented: $showDevicesListing){
                SelectDevice(mode: mode) {
                    showDevicesListing = false
                }
                .environmentObject(centralManager)
            }
            .toolbar{
                EditButton()
            }
            .navigationTitle("Party Mode")
            .onDisappear{
                if mode == .bluetooth{
                    centralManager.cleanup()
                }else{
                    multipeerManager.advertisingUpdate(start: false)
                }
            }
            .onAppear{
                multipeerManager.musicReceiveHandler = { music in
                    currentItems.append(music)
                    playLatest = true
                }
            }
            .alert(isPresented: $centralManager.disabled){
                Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
            }
            .alert(isPresented: $centralManager.showReceivedString){
                Alert(title: Text("Oops"), message: Text("Received string: " + centralManager.receivedString), dismissButton: .default(Text("Okay")))
            }
            .alert(isPresented: $multipeerManager.showAlert){
                Alert(title: Text("Oops"), message: Text(multipeerManager.alertString ?? "Something went wrong"), primaryButton: .default(Text("Yes")){
                    multipeerManager.invitation(accept: true)
                }, secondaryButton: .default(Text("No")){
                    multipeerManager.invitation(accept: false)
                })
            }
            
            if playLatest{
                ZStack{
                    Color(UIColor.systemBackground)
                        .shadow(radius: 2.0)
                    MiniPlayer(mediaItem: currentItems.last!)
                }
                .frame(height: 60.0)
            }
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
