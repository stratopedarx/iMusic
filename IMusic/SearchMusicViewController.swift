//
//  SearchViewController.swift
//  IMusic
//
//  Created by Sergey Lobanov on 27.10.2021.
//

// это класс от самой первой реализации. Не удаляю его для примера.

import UIKit
import Alamofire

class SearchMusicViewController: UITableViewController {
    
    var networkService = NetworkService()
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
extension SearchMusicViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // делаем искусственную задержку, что бы запрос не отправлялся при вводе каждого символа
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            
            // `{ searchResults in` - делая вот так, происходит утечка памяти. networkService имеет жесткую ссылку
            // на наш SearchViewController. И наоборот, объект SearchViewController имеет жесткую ссылку на networkService
            // что бы это испроавить прописываем [weak self]. Таким образом мы говорим, что один из элементов будет weak
            // print("out Self: \(self)") - object SearchViewController
            self.networkService.fetchTracks(searchText: searchText) { [weak self] searchResults in
                guard let self = self else { return }
                // print("in Self: \(self)") -  - object SearchViewController. the same object
                self.tracks = searchResults?.results ?? []
                self.tableView.reloadData()
            }
        }
    }
}

