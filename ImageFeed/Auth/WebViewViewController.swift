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
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    // MARK: - Public Properties
    weak var delegate: WebViewViewControllerDelegate?
    // MARK: - IBOutlet
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    // MARK: - Private Properties
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        loadAuthView()
        
    }
    // MARK: - Public Methods
    
    // MARK: - IBAction
    
    // MARK: - Private Methods
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
// MARK: - extension
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: process code
            decisionHandler(.cancel) //3
        } else {
            decisionHandler(.allow) //4
        }
    }
}
