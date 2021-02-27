//
//  SongsListingRow.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import MediaPlayer
import SwiftUI

struct SongsListingRow: View {
    
    let mediaItem : MPMediaItem
    
    var body: some View {
        HStack{
            if let image = mediaItem.artwork?.image(at: CGSize(width: 100, height: 100)){
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 40, idealHeight: 40, maxHeight: .infinity, alignment: .center)
                    .cornerRadius(5)
                
            }else{
                Image(systemName: "questionmark.square.fill")
                    .resizable()
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: 40, idealHeight: 40, maxHeight: .infinity, alignment: .center)
            }
            
            VStack(alignment: .leading){
                Text(mediaItem.title ?? "---")
                    .font(.body)
                    .lineLimit(1)

                if let artist = mediaItem.artist, !artist.isEmpty{
                    Text(artist)
                        .font(.caption)
                        .lineLimit(1)
                }else if let album = mediaItem.albumTitle, !album.isEmpty{
                    Text(album)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding(5)
    }
}

struct SongsListingRow_Previews: PreviewProvider {
    
    static var previews: some View {
        SongsListingRow(mediaItem: TempMediaItem(id: 1))
    }
}
