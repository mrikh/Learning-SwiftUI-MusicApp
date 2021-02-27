//
//  MusicDataStore.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import MediaPlayer

final class MusicDataStore : ObservableObject{
    
    @Published var songs : [MPMediaItem] = []
    @Published var authorizationStatus : MPMediaLibraryAuthorizationStatus?
    
    init(){
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized{
                self.fetchSongs()
            }
        }
    }
    
    
    private func fetchSongs(){
        
        let query = MPMediaQuery.songs()
        guard let items = query.items else {return}
        
        let collection = MPMediaItemCollection(items: items)
        DispatchQueue.main.async{ [weak self] in
            self?.songs = collection.items
        }
    }
}

//Below is only for testing in preview mode
class TempMediaItem : MPMediaItem{
    
    private let tempId : Int
    
    override var title: String?{
        "Adam Jensen - I can hold a grudge like nobody's business"
    }
    
    override var artist: String?{
        "Adamn Jensen"
    }
    
    override var albumTitle: String?{
        "Breakups"
    }
    
    override var assetURL: URL?{
        return nil
    }
    
    override var persistentID: MPMediaEntityPersistentID{
        MPMediaEntityPersistentID(tempId)
    }
    
    override var artwork: MPMediaItemArtwork?{
        let image = #imageLiteral(resourceName: "album_art")
        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
        })
        return artwork
    }
    
    init(id : Int){
        self.tempId = id
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
