//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 10.10.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
                       title: "",
                       image: UIImage(named: "tab_editorial_active"),
                       selectedImage: nil
                   )
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
                       title: "",
                       image: UIImage(named: "tab_profile_active"),
                       selectedImage: nil
                   )
        
        self.viewControllers = [imagesListViewController, profileViewController]
        
    }
}
