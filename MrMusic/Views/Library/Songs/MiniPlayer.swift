//
//  MiniPlayer.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import MediaPlayer
import SwiftUI

struct MiniPlayer: View {
    
    #warning("change below property depending on what you want")
    @State private var mode : PartyMode.Mode = .network
    let mediaItem : MPMediaItem
    @StateObject private var audioPlayer : AudioPlayer = AudioPlayer()
    @State private var isPlaying : Bool = true
    @StateObject var peripheralManager = PeripheralManager()
    @StateObject var multipeerManager = MultipeerConnectionManager()
    @State private var showSelect = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 3){
                HStack(spacing: 10){
                    SongsListingRow(mediaItem: mediaItem)
                    Spacer()
                    Button(action: {
                        isPlaying.toggle()
                        isPlaying ? audioPlayer.play() : audioPlayer.pause()
                    }, label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(Color(UIColor.systemBlue))
                    })
                    Button(action : {
                        if mode == .bluetooth{
                            peripheralManager.startAdvertising()
                        }else{
                            showSelect = true
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .foregroundColor(Color(UIColor.systemBlue))
                    })
                    .padding(.horizontal, 5)
                }
                .padding(.horizontal, 10)
                ProgressView(value: 0.5)
            }
        }
        .onAppear{
            if mode == .bluetooth{
                peripheralManager.musicItem = self.mediaItem
            }else{
                multipeerManager.musicItemToSend = self.mediaItem
            }
            
            reconfigurePlayer(mediaItem)
        }
        .onChange(of: mediaItem) { value in
            if mode == .bluetooth{
                peripheralManager.musicItem = value
            }else{
                multipeerManager.musicItemToSend = value
            }
            reconfigurePlayer(value)
        }
        .onDisappear{
            audioPlayer.clean()
        }
        .alert(isPresented: $audioPlayer.showAlert){
            Alert(title: Text("Alert"), message: Text(audioPlayer.errorString ?? "Something went wrong"), dismissButton: .default(Text("Okay")))
        }
        .alert(isPresented: $peripheralManager.disabled){
            Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
        }
        .alert(isPresented: $peripheralManager.showUnsubscribedAlert) {

            Alert(title: Text("Oops"), message: Text("You have been unsubscribed"), dismissButton: .default(Text("Okay")))
        }
        .sheet(isPresented: $showSelect) {
            SelectDevice(mode: mode)
            .environmentObject(CentralManager())
            .environmentObject(multipeerManager)
        }
    }
    
    private func reconfigurePlayer(_ mediaItem : MPMediaItem){
        
        if let url = mediaItem.assetURL{
            self.audioPlayer.configure(url: url)
        }
    }
}

struct MiniPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayer(mediaItem: TempMediaItem(id: 1))
    }
}
