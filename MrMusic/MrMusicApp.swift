//
//  MrMusicApp.swift
//  MrMusic
//
//  Created by Mayank Rikh on 22/02/21.
//

import SwiftUI

@main
struct MrMusicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MusicDataStore())
                .environmentObject(BluetoothManager())
        }
    }
}
