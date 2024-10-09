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
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: Constants.unsplashGetTokenURLString) else {
            preconditionFailure("Unsplash get token URL is wrong")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            preconditionFailure("Unable to construct URL for Request")
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        return request
    }
    
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
        
        let request = makeOAuthTokenRequest(code: code)
        
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch result {
            case .success(let data):
                let token = data.accessToken
                OAuth2TokenStorage.shared.token = token
                print("Записали токен \(token)")
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
}



