//
//  ContentView.swift
//  MrMusic
//
//  Created by Mayank Rikh on 22/02/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var current: Tab = .library
    @StateObject private var musicStore = MusicDataStore()
    
    enum Tab{
        case library
        case randomize
        case partyMode
        case explore
    }
    
    var body: some View {
        
        TabView(selection: $current){
            LibraryView()
                .environmentObject(musicStore)
                .tabItem{
                    Label("Library", systemImage : current == .library ? "music.note.house.fill" : "music.note.house")
                }
                .tag(Tab.library)
            NavigationView{
                PartyMode()
            }
            .environmentObject(musicStore)
            .tabItem{
                Label("Party Mode", systemImage : current == .partyMode ? "hifispeaker.fill" : "hifispeaker")
            }
            .tag(Tab.partyMode)
        }
        .onAppear{
            try? AVAudioSession.sharedInstance().setCategory(.playback)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
