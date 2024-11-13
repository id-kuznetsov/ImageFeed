//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

final class AuthHelper: AuthHelperProtocol {
    
    private let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        
        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.clientID, value: configuration.accessKey),
            URLQueryItem(name: Constants.redirectURIString, value: configuration.redirectURI),
            URLQueryItem(name: Constants.responseType, value: "code"),
            URLQueryItem(name: Constants.scope, value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
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
