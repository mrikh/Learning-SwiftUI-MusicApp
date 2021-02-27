//
//  MiniPlayer.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import MediaPlayer
import SwiftUI

struct MiniPlayer: View {
    
    let mediaItem : MPMediaItem
    @State private var audioPlayer : AudioPlayer = AudioPlayer()
    @State private var errorString : String?
    @State private var showAlert : Bool = false
    @State private var isPlaying : Bool = true
    
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
                            .foregroundColor(Color.black)
                    })
                }
                .padding(.horizontal, 10)
                ProgressView(value: 0.5)
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Alert"), message: Text(errorString ?? "Something went wrong"), dismissButton: .default(Text("Okay")))
            })
        }
        .onAppear{
            reconfigurePlayer(mediaItem)
        }
        .onChange(of: mediaItem) { value in
            reconfigurePlayer(value)
        }
        .onDisappear{
//            audioPlayer.clean()
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
