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

    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!

    // вызывается этот метод, если только ячейка сконфигурирована черех xib файл
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    
    // в эту функцию можно передать searchViewModel, но это будет не совсем верно, потому что в той модели
    // у нас может быть много данных, которые нам не нужны для настройки xib, поэтому следуя приницу 4 из солид
    // принцип разделения интерфейсов. Интресфейсы должны обладать только той информацией, которая им нужна
    // Говорит о том, что этой ячейке нет смысла знать о каких-то парамеотрах, которые она не собирается использовать
    // Как это сделать? Использовать протокол
    func set(viewModel: TrackCellViewModel) {
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
}
