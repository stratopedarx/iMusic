//
//  SearchViewController.swift
//  IMusic
//
//  Created by Sergey Lobanov on 27.10.2021.
//

import UIKit
import Alamofire

struct TrackModel {
    var trackName: String
    var artistName: String
}


class SearchViewController: UITableViewController {
    
    private var timer: Timer?
    let searchController = UISearchController(searchResultsController: nil)
    
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupSearchBar()
        
        // ячейку надо зарегестрировать у конкретного tableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        let track = tracks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(track.trackName ?? "Unknown track name")\n\(track.artistName ?? "Unknown artist name")"
        cell.textLabel?.numberOfLines = 2
        content.image = UIImage(named: "Image")
        cell.contentConfiguration = content
        
        return cell
    }
}

// что бы мы могли обработать то, что мы пишем в поисковом окне, надо нащ контроллер подписать под один делегат
//  что бы компилятор понял кто будет выполнять этот метод,  `searchController.searchBar.delegate = self`
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // делаем искусственную задержку, что бы запрос не отправлялся при вводе каждого символа
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            let url = "https://itunes.apple.com/search"
            let parametrs = ["term": searchText, "limit": "10"]
            
            AF.request(url,
                       method: .get,
                       parameters: parametrs,
                       encoding: URLEncoding.default,
                       headers: nil).response { response in
                if let error = response.error {
                    print("error received requesting data \(error.localizedDescription)")
                    return
                }
                
                guard let data = response.data else { return }
                
                let decoder = JSONDecoder()
                do {
                    let objects = try decoder.decode(SearchResponse.self, from: data)
                    self.tracks = objects.results
                    self.tableView.reloadData()
                    print("objects: \(objects)")
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                }
            }
        })
    }
}
