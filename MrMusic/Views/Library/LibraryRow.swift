//
//  LibraryRow.swift
//  MrMusic
//
//  Created by Mayank Rikh on 23/02/21.
//

import SwiftUI

struct LibraryRow: View {
    
    var title : String
    var imageName : String
    
    var body: some View {
        Label(title, systemImage : imageName)
            .font(.title2)
    }
}

struct LibraryRow_Previews: PreviewProvider {
    static var previews: some View {
        LibraryRow(title: "Mayank", imageName: "music.note.list")
    }
}
