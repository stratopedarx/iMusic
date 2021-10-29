//
//  UIViewController + Storyboard.swift
//  IMusic
//
//  Created by Sergey Lobanov on 29.10.2021.
//

import UIKit

// помогает загрузить вьюКонтроллер, который находится в сториборде. Ищет по имени сториборд, если находит, то подгружает.
extension UIViewController {
    
    class func loadFromStoryboard<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("No initial view controller in \(name) storyboard")
        }
    }
}

