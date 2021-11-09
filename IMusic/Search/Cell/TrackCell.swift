//
//  TrackCell.swift
//  IMusic
//
//  Created by Sergey Lobanov on 31.10.2021.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

class TrackCell: UITableViewCell {
    static let reuseId = "TrackCell"
    
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var collectionNameLabel: UILabel!
    
    @IBOutlet private weak var addTrackButton: UIButton!
    var cell: SearchViewModel.Cell?
    
    // вызывается этот метод, если только ячейка сконфигурирована черех xib файл
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    // в эту функцию можно передать searchViewModel, но это будет не совсем верно, потому что в той модели
    // у нас может быть много данных, которые нам не нужны для настройки xib, поэтому следуя приницу 4 из солид
    // принцип разделения интерфейсов. Интресфейсы должны обладать только той информацией, которая им нужна
    // Говорит о том, что этой ячейке нет смысла знать о каких-то парамеотрах, которые она не собирается использовать
    // Как это сделать? Использовать протокол (TrackCellViewModel)
    // func set(viewModel: TrackCellViewModel) { -- сначала сделали так, но потом указали другой тип для UserDefaults
    func set(viewModel: SearchViewModel.Cell) {
        cell = viewModel  // хотим сохранять это свойство в UserDefaults
        
        // проверяем добавлен ли трек в UserDefaults
        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavourite = savedTracks.firstIndex(where: {
            $0.trackName ==  cell?.trackName && $0.artistName == cell?.artistName }) != nil
        if hasFavourite {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        
        guard let url = URL(string: viewModel.iconUrlString) else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    // этот метод вызываю, потому что ячейка в таблице переиспользуется
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackImageView.image = nil
    }
    
    @IBAction func addTrackAction(_ sender: UIButton) {
        print("addTrackAction")
        // как работать со стандартными типами
        //        let defaults = UserDefaults.standard
        //        defaults.set(25, forKey: "Age")
        //        defaults.set("Hello", forKey: "String")
        
        guard let cell = cell else { return }
        addTrackButton.isHidden = true
        
        let defaults = UserDefaults.standard
        // достаем то, что уже есть в нашей базе
        var listOfTracks = defaults.savedTracks()
        
        // добавляем новый трек в нащ список и сохраянем этот список
        listOfTracks.append(cell)
        
        // как работать со своими типами. Архивируем.
        // Наши модель данных должна быть классом, а не структурой
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            print("Saved successfully")
            
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
        
    }
}
