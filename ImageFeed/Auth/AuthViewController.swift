//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 19.09.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Private properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
    }
    // MARK: - Public Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "chevron.backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "chevron.backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}
// MARK: - extension
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                print(token)
            case .failure(let error):
                print(error)
            }
        }
        webViewViewControllerDidCancel(vc)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    
}
