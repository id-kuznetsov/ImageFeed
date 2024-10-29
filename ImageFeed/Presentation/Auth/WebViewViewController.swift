//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 19.09.2024.
//

import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    // MARK: - Public Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private lazy var backButton: UIButton = {
        guard let buttonImage = UIImage(systemName: "chevron.backward") else { return UIButton() }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(self.didTapBackButton)
        )
        button.tintColor = .ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .ypBlack
        return progressView
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebViewInterface()
        
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        loadAuthView()
    }
    
    
    // MARK: - Actions
    
    @objc
    private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    
    private func setWebViewInterface() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate(
            backButtonConstraints() +
            progressViewConstraints() +
            webViewConstraints()
        )
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        updateProgress()
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    // MARK: - Constraints
    
    private func backButtonConstraints() -> [NSLayoutConstraint] {
        [backButton.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
         backButton.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant: 9),
         backButton.widthAnchor.constraint(equalToConstant: 24),
         backButton.heightAnchor.constraint(equalToConstant: 24)
        ]
    }
    
    private func progressViewConstraints() -> [NSLayoutConstraint] {
        [progressView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
         progressView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
         progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
        ]
    }
    
    private func webViewConstraints() -> [NSLayoutConstraint] {
        [webView.leadingAnchor.constraint(equalTo:view.leadingAnchor),
         webView.trailingAnchor.constraint(equalTo:view.trailingAnchor),
         webView.topAnchor.constraint(equalTo: view.topAnchor),
         webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }
}
// MARK: - Extension

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

