//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 21.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"
    
    // MARK: - lifycycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = storage.token else {
           performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            return
        }
        
        fetchProfile(token: token)
    }
    
    // MARK: - Private Methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                switchToTabBarController()
                profileImageService.fetchProfileImageURL(username: profile.name ) { _ in }
            case .failure(let error):
                print(error)
                // TODO: обработать ошибку
            }
            
        }
    }
    
}

// MARK: - extension

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token: token)
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
