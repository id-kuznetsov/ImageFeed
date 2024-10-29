//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 19.09.2024.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let oauth2Service = OAuth2Service.shared
    
    private lazy var alertPresenter: AlertPresenterProtocol? = {
        let presenter = AlertPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    private lazy var authLogoImageView: UIImageView = {
        let authLogo = UIImageView()
        authLogo.translatesAutoresizingMaskIntoConstraints = false
        authLogo.image = UIImage(named: "auth_screen_logo")
        return authLogo
    }()
    
    private lazy var entryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.cornerRadius = 16
        
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        
        button.addTarget(self, action: #selector(didEntryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAuthView()
    }
    
    // MARK: - Actions
    
    @objc
    private func didEntryButtonTapped() {
        showWebView()
    }

    // MARK: - Private Methods
    
    private func setAuthView() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(authLogoImageView)
        view.addSubview(entryButton)
        
        NSLayoutConstraint.activate(
            authLogoImageViewConstraints() +
            entryButtonConstraints()
        )
    }
    
    private func showWebView() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
    }
    
    private func showAuthError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "OK",
            completion: {}
        )
        alertPresenter?.showAlert(alertModel)
    }
    
    // MARK: - Constraints
    
    private func authLogoImageViewConstraints() -> [NSLayoutConstraint] {
        [authLogoImageView.widthAnchor.constraint(equalToConstant: 60),
         authLogoImageView.heightAnchor.constraint(equalToConstant: 60),
         authLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
         authLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ]
    }
    
    private func entryButtonConstraints() -> [NSLayoutConstraint] {
        [entryButton.heightAnchor.constraint(equalToConstant: 48),
         entryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         entryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
         entryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ]
    }
}
// MARK: - Extension
// MARK: WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        print("UIBlockingProgressHUD is shown \(#file) \(#line)")
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            print("UIBlockingProgressHUD is dismissed \(#file) \(#line)")
            switch result {
            case .success(_):
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print(error)
                showAuthError()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

// MARK: AlertPresenterDelegate

extension AuthViewController: AlertPresenterDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}

