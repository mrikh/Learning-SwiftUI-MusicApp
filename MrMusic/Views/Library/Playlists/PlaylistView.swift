//
//  PlaylistView.swift
//  MrMusic
//
//  Created by Mayank Rikh on 27/02/21.
//

import MediaPlayer
import SwiftUI

struct PlaylistView: View {
    
    @EnvironmentObject var musicStore : MusicDataStore
    var selectedPlaylist : ((MPMediaPlaylist)->())?
    
    var body: some View {
        VStack(spacing: 0) {
            List{
                ForEach(musicStore.playlists, id: \.persistentID) { (playlist) in
                    Button(action: {
                        selectedPlaylist?(playlist)
                    }, label: {
                        Text(playlist.name ?? "Invalid Name")
                    })
                }
            }
            .navigationTitle("Playlists")
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView { (playlist) in
            print(playlist)
        }
    }
}
