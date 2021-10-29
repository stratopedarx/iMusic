//
//  SearchPresenter.swift
//  IMusic
//
//  Created by Sergey Lobanov on 29.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
    func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
    weak var viewController: SearchDisplayLogic?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        switch response {
        case .some:
            print("presenter .some")
        case .presentTracks:
            print("presenter .presentTracks")
            viewController?.displayData(viewModel: Search.Model.ViewModel.ViewModelData.displayTracks)
        }
    }
}
