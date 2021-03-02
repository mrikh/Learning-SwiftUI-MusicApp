//
//  MiniPlayer.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import MediaPlayer
import SwiftUI

struct MiniPlayer: View {
    
    @State private var showAlert : Bool = false
    let mediaItem : MPMediaItem
    @State private var audioPlayer : AudioPlayer = AudioPlayer()
    @State private var errorString : String?
    @State private var isPlaying : Bool = true
    @StateObject var peripheralManager = PeripheralManager()
    
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
                        peripheralManager.startAdvertising()
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
            peripheralManager.musicItem = self.mediaItem
            reconfigurePlayer(mediaItem)
        }
        .onChange(of: mediaItem) { value in
            peripheralManager.musicItem = value
            reconfigurePlayer(value)
        }
        .onDisappear{
            audioPlayer.clean()
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("Alert"), message: Text(errorString ?? "Something went wrong"), dismissButton: .default(Text("Okay")))
        }
        .alert(isPresented: $peripheralManager.disabled){
            Alert(title: Text("Oops"), message: Text("Enable bluetooth to dynamically update playlist"), dismissButton: .default(Text("Okay")))
        }
    }
    
    private func reconfigurePlayer(_ mediaItem : MPMediaItem){
        
        if let url = mediaItem.assetURL{
            errorString = self.audioPlayer.configure(url: url)
            showAlert = errorString != nil
        }else{
            showAlert = true
        }
    }
}

struct MiniPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayer(mediaItem: TempMediaItem(id: 1))
    }
}
