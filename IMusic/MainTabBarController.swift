//
//  MainTabBarController.swift
//  IMusic
//
//  Created by Sergey Lobanov on 27.10.2021.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(red: 255, green: 0, blue: 96, alpha: 1)
        
        let libraryViewController = ViewController()
        
        let searchViewController: SearchViewController = SearchViewController.loadFromStoryboard()
        
        viewControllers = [
            generateViewController(
                rootViewController: searchViewController,
                image: UIImage(named: "search")!,
                title: "Search"),
            generateViewController(
                rootViewController: libraryViewController,
                image: UIImage(named: "library")!,
                title: "Library")
        ]
    }
    
    private func generateViewController(
        rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
            let navigationViewController = UINavigationController(rootViewController: rootViewController)
            navigationViewController.tabBarItem.image = image
            navigationViewController.tabBarItem.title = title
            rootViewController.navigationItem.title = title
            navigationViewController.navigationBar.prefersLargeTitles = true
            return navigationViewController
        }
}
