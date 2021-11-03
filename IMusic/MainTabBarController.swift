//
//  MainTabBarController.swift
//  IMusic
//
//  Created by Sergey Lobanov on 27.10.2021.
//

import UIKit

protocol MainTabBarControllerDelegate: AnyObject {
    func minimizedTrackDetailController()
}

class MainTabBarController: UITabBarController {
    
    static let hightOfMinimizedTrackView: CGFloat = -64
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!

    let searchViewController: SearchViewController = SearchViewController.loadFromStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(red: 255, green: 0, blue: 96, alpha: 1)
        
        setupTrackDetailView()
        
        let libraryViewController = ViewController()
        
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

// здесь будем добавлять анимацию (когда сворачиваем трек). Эта анимация будет на всех экранах
private extension MainTabBarController {
    func setupTrackDetailView() {
        print("setupTrackDetailView")
        
        let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
        trackDetailView.backgroundColor = .green
        
        // назначаем делегатов
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchViewController

//        view.addSubview(trackDetailView) // таким образом получается эта вью над таббаром
        
        // мы хотим сделать так, что бы вьюшка была за таббаром, но выше других вию
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        // use auto layout
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(
            equalTo: tabBar.topAnchor, constant: MainTabBarController.hightOfMinimizedTrackView)
        
        // при сворачивании окна, у нас теперь всё уезжает просто вниз. Опускается на высоту данного экрана.
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true

        maximizedTopAnchorConstraint.isActive = true
//        trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true  // при таком использовании будет много ошибок в компиляторе, так как экран скукоживается при сворачивании. Что бы этого не было мы опускаем экран на всю высоту при сворачивании.
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}

extension MainTabBarController: MainTabBarControllerDelegate {
    func minimizedTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: { self.view.layoutIfNeeded() },  // очень часто обноваляется благодаря этой функции
                       completion: nil)
    }
}
