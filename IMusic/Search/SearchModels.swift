//
//  SearchModels.swift
//  IMusic
//
//  Created by Sergey Lobanov on 29.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SwiftUI

enum Search {
    
    enum Model {
        struct Request {
            enum RequestType {
                case getTracks(searchText: String)
            }
        }
        struct Response {
            enum ResponseType {
                case presentTracks(searchResponse: SearchResponse?)
                case presentFooterView
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayTracks(searchViewModel: SearchViewModel)
                case displayFooterView
            }
        }
    }
}

// если мы хотим использовать UserDefaults, то нам нужно использовать классы вместо структур
/*
struct SearchViewModel {
    struct Cell: TrackCellViewModel {
        var iconUrlString: String
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: String?
    }
    
    let cells: [Cell]
}
*/

// если мы хотим использовать UserDefaults, то нам нужно использовать классы вместо структур
// Плюс добавить два протокола
class SearchViewModel: NSObject, NSCoding {
    let cells: [Cell]
        
    init(cells: [Cell]) {
        self.cells = cells
    }
    
    func encode(with coder: NSCoder) {
        // преобразует все свойства класса в формат UserDefaults
        coder.encode(cells, forKey: "cells")
    }
    
    required init?(coder: NSCoder) {
        cells = coder.decodeObject(forKey: "cells") as? [SearchViewModel.Cell] ?? []
    }

    // MARK: - Cell
    // @objc(_TtCC6IMusic15SearchViewModel4Cell) - это приходится добавлять из за рантайма object C.
    // раньше можно было просто так добавлять класс внуть класса, сейчас приходится добавлять вот такой авто ключ.
    @objc(_TtCC6IMusic15SearchViewModel4Cell)class Cell: NSObject, NSCoding, Identifiable {
        // TrackCellViewModel - удаляем этот протокол тут. Он болльше не нужен здесь
        
        var id = UUID()  // добавляем протокол Identifiable для того что бы использовать в SwiftUI List
        
        var iconUrlString: String
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: String?
        
        init(iconUrlString: String, trackName: String, collectionName: String, artistName: String, previewUrl: String?) {
            self.iconUrlString = iconUrlString
            self.trackName = trackName
            self.collectionName = collectionName
            self.artistName = artistName
            self.previewUrl = previewUrl
        }
        
        func encode(with coder: NSCoder) {
            coder.encode(iconUrlString, forKey: "iconUrlString")
            coder.encode(trackName, forKey: "trackName")
            coder.encode(collectionName, forKey: "collectionName")
            coder.encode(artistName, forKey: "artistName")
            coder.encode(previewUrl, forKey: "previewUrl")
        }
        
        required init?(coder: NSCoder) {
            iconUrlString = coder.decodeObject(forKey: "iconUrlString") as? String ?? ""
            trackName = coder.decodeObject(forKey: "trackName") as? String ?? ""
            collectionName = coder.decodeObject(forKey: "collectionName") as? String ?? ""
            artistName = coder.decodeObject(forKey: "artistName") as? String ?? ""
            previewUrl = coder.decodeObject(forKey: "previewUrl") as? String ?? ""
        }
    }
}
