//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            preconditionFailure("Base URL is wrong")
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            preconditionFailure("Unable to construct URL for Request")
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(
        code: String,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    OAuth2TokenStorage.shared.token = token
                    handler(.success(data))
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

