//
//  SongsListing.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import MediaPlayer
import SwiftUI

struct SongsListing: View {
    
    @EnvironmentObject var musicStore : MusicDataStore
    @State private var searchText : String = ""
    @State private var isPlaying = false
    
    @State private var selectedItem : MPMediaItem?
    private var songs : [MPMediaItem]{
        
        if searchText.isEmpty {return musicStore.songs}
        
        return musicStore.songs.filter { (item) -> Bool in
            if let title = item.title{
                return title.hasPrefix(searchText)
            }
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List{
                TextField("Type your search",text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                ForEach(songs, id: \.persistentID){ mediaItem in
                    Button(action: {
                        self.selectedItem = mediaItem
                    }, label: {
                        SongsListingRow(mediaItem: mediaItem)
                    })
                }
            }
            .navigationTitle("Songs")
            
            if selectedItem != nil{
                ZStack{
                    Color.white
                        .shadow(radius: 2.0)
                    MiniPlayer(mediaItem: selectedItem!)
                }
                .frame(height: 60.0)
            }
        }
    }
}

struct SongsListing_Previews: PreviewProvider {
    static var previews: some View {
        
        let store = MusicDataStore()
        store.songs = [TempMediaItem(id: 1), TempMediaItem(id : 2)]
        
        return SongsListing().environmentObject(store)
    }
}
