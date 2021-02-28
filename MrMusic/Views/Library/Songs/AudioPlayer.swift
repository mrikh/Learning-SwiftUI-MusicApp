//
//  AudioPlayer.swift
//  MrMusic
//
//  Created by Mayank Rikh on 26/02/21.
//

import MediaPlayer

class AudioPlayer{
    
    private var audioPlayer : AVAudioPlayer?
    
    func configure(url : URL) -> String?{
        
        do{
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.3
            self.play()
            return nil
        }catch{
            return error.localizedDescription
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
