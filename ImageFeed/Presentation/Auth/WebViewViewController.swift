//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 19.09.2024.
//

import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {

    // MARK: - Public Properties
    
    var presenter: WebViewPresenterProtocol?
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
        
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Public Methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
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

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
            return nil
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
}

