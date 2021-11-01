//
//  SearchInteractor.swift
//  IMusic
//
//  Created by Sergey Lobanov on 29.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var networkService = NetworkService()
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        switch request {
        case .getTracks(let searchText):
            // это делается для отображения индикатора загрузки
            presenter?.presentData(response: Search.Model.Response.ResponseType.presentFooterView)
            
            networkService.fetchTracks(searchText: searchText) { [weak self] searchResponse in
                guard let self = self else { return }
                let response = Search.Model.Response.ResponseType.presentTracks(searchResponse: searchResponse)
                self.presenter?.presentData(response: response)
            }
        }
    }
}
