//
//  AudioPlayer.swift
//  MrMusic
//
//  Created by Mayank Rikh on 26/02/21.
//

import MediaPlayer

class AudioPlayer : ObservableObject{
    
    private var audioPlayer : AVAudioPlayer?
    
    var errorString : String?
    @Published var showAlert = false
    
    func configure(url : URL){
        
        do{
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.3
            self.play()
        }catch{
            errorString = error.localizedDescription
            showAlert = true
        }
    }
    
    func pause(){
        audioPlayer?.pause()
    }
    
    func play(){
        audioPlayer?.play()
    }
    
    func clean(){
        audioPlayer?.pause()
        audioPlayer = nil
    }
}
