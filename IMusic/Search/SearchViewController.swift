//
//  SearchViewController.swift
//  IMusic
//
//  Created by Sergey Lobanov on 29.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchDisplayLogic: AnyObject {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    @IBOutlet private weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    private var searchViewModel = SearchViewModel(cells: [])
    private var timer: Timer?
    private lazy var footerView = FooterView()  // прогоняем эту вью через весь цикл clean architecture
    
    
    // MARK: Object lifecycle
    // так как загружаем не из xib файла, а из сториборд, то эти инициализаторы нам не понадобятся
    /*
     override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
     super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
     setup()
     }
     
     required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
     setup()
     }
     */
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = SearchInteractor()
        let presenter             = SearchPresenter()
        let router                = SearchRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: Routing
    
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupTableView()
        setupSearchBar()
        // по дефолту загрузим главный экран
        searchBar(searchController.searchBar, textDidChange: "Red")
        
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        // ячейку надо зарегестрировать у конкретного tableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        // регистрируем новую ячейку, которую добавили через xib файл
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        
        // удаляем все пустые ячейки
        // в этом же вью можем реализовать индикатор загрузки. сделаем это в отдельном файле
        tableView.tableFooterView = footerView
    }
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            self.tableView.reloadData()
            footerView.hideLoader()
        case .displayFooterView:
            footerView.showLoader()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
        let cellViewModel = searchViewModel.cells[indexPath.row]
        cell.set(viewModel: cellViewModel)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = searchViewModel.cells[indexPath.row]
        
        // мы хотим что бы появлялось модальное окно TrackDetailView. Оно должно быть поверх всех экранов.
        // по иерархии новый экран должен находиться сверху. За текущий контроллер отвечает свойство window.
        // с помощью данного свойста мы можем сказать, что хотим наложить новый экран по верх всех.
        // keyWindow - то окно, на котором мы сейчас находимся
        let window = getKeyWindow()
        // из ниб файла загружаем View.
        let trackDetailsView: TrackDetailView = TrackDetailView.loadFromNib()
        trackDetailsView.set(viewModel: cellViewModel)
        trackDetailsView.delegate = self
    
        window.addSubview(trackDetailsView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // стандартная высота как в Apple music
        return 84
    }
    
    // в header поместим label
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search term above..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

    // делаем для того, что бы надпись "Please enter search term above..." убиралась при вводе
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchViewModel.cells.count > 0 ? 0 : 250
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            let request = Search.Model.Request.RequestType.getTracks(searchText: searchText)
            self.interactor?.makeRequest(request: request)
        })
    }
}


// MARK: - Helpers
private extension SearchViewController {
    func getKeyWindow() -> UIWindow {
        return UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }!
    }
}

// MARK: - TrackMovingDelegate

extension SearchViewController: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        // 1. Понать какой индекс патх
        // 2. Передвинуть и проверить существует или нет
        // 3. Находим информацию.
        // 4. Убираем выделение с одной ячейки и выделяем новую
        // 5. Возвращаем информацию
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        tableView.deselectRow(at: indexPath, animated: true)  // снимаем выделение
        var nextIndexPath: IndexPath
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            // что бы с последнего индекса переходило на первый
            if nextIndexPath.row == searchViewModel.cells.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = searchViewModel.cells.count - 1
            }
        }

        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)  // выделяем новую ячейку
        let cellViewModel = searchViewModel.cells[nextIndexPath.row]
        return cellViewModel
    }
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        print("go back")
        return getTrack(isForwardTrack: false)
    }

    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        print("go forward")
        return getTrack(isForwardTrack: true)
    }
}
