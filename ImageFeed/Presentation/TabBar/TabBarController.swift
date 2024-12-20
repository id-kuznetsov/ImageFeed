//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 10.10.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesListViewController = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
        
        setAppearance()
    }
    
    // MARK: - Private Methods
    
    private func setAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack
        appearance.stackedLayoutAppearance.selected.iconColor = .ypWhite

        tabBar.standardAppearance = appearance
    }
}
