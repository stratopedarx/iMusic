//
//  UserDefaults.swift
//  IMusic
//
//  Created by Sergey Lobanov on 08.11.2021.
//

import Foundation


extension UserDefaults {
    static let favouriteTrackKey = "favouriteTrackKey"
    
    func savedTracks() -> [SearchViewModel.Cell] {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: UserDefaults.favouriteTrackKey) as? Data,
           let decodedTracks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? [SearchViewModel.Cell] {
            print("Loaded successfully")
            return decodedTracks
        } else {
            return []
        }
    }
}
