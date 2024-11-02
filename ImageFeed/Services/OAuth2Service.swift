//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Constants
    
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    
    private let decoder = SnakeCaseJSONDecoder()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(
        code: String,
        handler: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Make request fail \(#file)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch result {
            case .success(let data):
                let token = data.accessToken
                OAuth2TokenStorage.shared.token = token
                handler(.success(token))
                self.task = nil
                self.lastCode = nil
            case .failure(let error):
                print("Error in \(#function) \(#file): \(error.localizedDescription)")
                handler(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
  
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashGetTokenURLString) else {
            print("Unsplash get token URL is wrong")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("Unable to construct URL for Request")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        return request
    }
}



