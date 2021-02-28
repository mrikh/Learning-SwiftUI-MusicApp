//
//  LibraryView.swift
//  MrMusic
//
//  Created by Mayank Rikh on 22/02/21.
//

import SwiftUI

struct LibraryView: View {
    
    @EnvironmentObject private var musicStore : MusicDataStore
    
    var body: some View {
        
        NavigationView{
            List{
                NavigationLink(destination: SongsListing()){
                    LibraryRow(title: "Songs", imageName: "music.note")
                }
                NavigationLink(destination: PlaylistView()){ 
                    LibraryRow(title: "Playlists", imageName: "music.note.list")
                }
                LibraryRow(title: "Albums", imageName: "rectangle.stack")
                LibraryRow(title: "Favourites", imageName: "star")
                LibraryRow(title: "Compilations", imageName: "music.quarternote.3")
                
                //TODO: Add recent played etc
            }
            .navigationTitle("Library")
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
