//
//  MainTabBarController.swift
//  IMusic
//
//  Created by Sergey Lobanov on 27.10.2021.
//

import UIKit

protocol MainTabBarControllerDelegate: AnyObject {
    func minimizedTrackDetailController()
    func maximizedTrackDetailController(viewModel: SearchViewModel.Cell?)  // будет раскрывать контроллер. принимает информацию по конкретной ячейке
}

class MainTabBarController: UITabBarController {
    
    static let hightOfMinimizedTrackView: CGFloat = -64
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!

    let searchViewController: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(red: 255, green: 0, blue: 96, alpha: 1)
    
        // назначаем делегатов
        searchViewController.tabBarDelegate = self  // для протокола MainTabBarControllerDelegate
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchViewController
        
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
//        view.addSubview(trackDetailView) // таким образом получается эта вью над таббаром
        
        // мы хотим сделать так, что бы вьюшка была за таббаром, но выше других вию
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        // use auto layout
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false

        // добавив  constant: view.frame.height верхнюю границу помещаем вниз, что бы не было видно
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
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

    func viewAnimate(animations: @escaping () -> Void) {
        UIView.animate(withDuration: AnimationConfig.withDuration,
                       delay: AnimationConfig.delay,
                       usingSpringWithDamping: AnimationConfig.usingSpringWithDamping,
                       initialSpringVelocity: AnimationConfig.initialSpringVelocity,
                       options: AnimationConfig.options,
                       animations: { animations() },
                       completion: nil)
    }
}

extension MainTabBarController: MainTabBarControllerDelegate {
    func minimizedTrackDetailController() {
        // логика то, что экран уменьшается
        maximizedTopAnchorConstraint.isActive = false
        
        // нам надо сместить значение нижней границы на высоту телефона
        bottomAnchorConstraint.constant = view.frame.height
        
        minimizedTopAnchorConstraint.isActive = true
        
        viewAnimate {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 1
            self.trackDetailView.miniTrackView.alpha = 1
            self.trackDetailView.maximizedStackView.alpha = 0  // убираем большой плеер
        }
    }
    
    func maximizedTrackDetailController(viewModel: SearchViewModel.Cell?) {
        
        // логика то, что экран увеличивается
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0  // отменяем все смещение
        bottomAnchorConstraint.constant = 0 // отменяем все смещение
        
        viewAnimate {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 0  // скрываем tabBar
            self.trackDetailView.miniTrackView.alpha = 0 // убираем маленький плеер
            self.trackDetailView.maximizedStackView.alpha = 1
        }
        
        guard let viewModel = viewModel else { return }
        trackDetailView.set(viewModel: viewModel)
    }
}
