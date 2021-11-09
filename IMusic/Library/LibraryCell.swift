//
//  LibraryCell.swift
//  IMusic
//
//  Created by Sergey Lobanov on 09.11.2021.
//

import SwiftUI
import URLImage

// MARK: - LibraryCell

struct LibraryCell: View {
    var cell: SearchViewModel.Cell

    var body: some View {
        HStack {
            let url = URL(string: cell.iconUrlString)!
            URLImage(url) { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(2)
            }

            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)")
            }
        }
    }
}

struct LibraryCell_Previews: PreviewProvider {
    static var cells = UserDefaults.standard.savedTracks()
    
    static var previews: some View {
        LibraryCell(cell: cells[0])
    }
}
