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
    private var didFetchProfile = false
    
    private lazy var alertPresenter: AlertPresenterProtocol? = {
        let presenter = AlertPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    private lazy var splashImageView: UIImageView = {
        let splashImage = UIImageView()
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        splashImage.image = UIImage(systemName: "launch_screen_logo")
        return splashImage
    }()
    
    // MARK: - lifycycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSplashView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        guard let token = storage.token,  else {
        //            showAuthViewController()
        //            return
        //        }
        
        //        if !didFetchProfile {
        //            fetchProfile(token: token)
        //        }
        if let token = storage.token, !didFetchProfile {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
            
        }
    }
    
    // MARK: - Private Methods
    
    private func setSplashView() {
        view.backgroundColor = .ypBlack
        view.addSubview(splashImageView)
        
        NSLayoutConstraint.activate(splashImageViewConstraints())
    }
    
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
        didFetchProfile = true
        UIBlockingProgressHUD.show()
        print("UIBlockingProgressHUD is shown \(#file) \(#line)")
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            print("UIBlockingProgressHUD is dismissed \(#file) \(#line)")
            
            switch result {
            case .success(let profile):
                switchToTabBarController()
                profileImageService.fetchProfileImageURL(username: profile.username ) { _ in }
            case .failure(let error):
                print("Error in \(#function) \(#file): \(error.localizedDescription)")
                showError()
            }
            
        }
    }
    
    private func showError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "OK",
            completion: {}
        )
        alertPresenter?.showResultAlert(alertModel)
    }
    
    private func showAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func splashImageViewConstraints() -> [NSLayoutConstraint] {
        [splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }
    
}

// MARK: - extension

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        guard let token = storage.token else {
            return
        }
        fetchProfile(token: token)
        didFetchProfile = true
        vc.dismiss(animated: true)
        
        switchToTabBarController()
    }
}

extension SplashViewController: AlertPresenterDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}

