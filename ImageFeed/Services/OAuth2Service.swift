//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation

final class OAuth2Service {
    // MARK: - Constants
    
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    
    private let decoder = SnakeCaseJSONDecoder()
    
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
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    OAuth2TokenStorage.shared.token = token
                    print("Записали токен")
                    handler(.success(token))
                }
                catch {
                    print(error.localizedDescription)
                    handler(.failure(error))
                }
            case .failure(let error):
                print(error.localizedDescription)
                handler(.failure(error))
            }
        }
        task.resume()
    }
    
}

