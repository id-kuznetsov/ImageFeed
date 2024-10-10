//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation

private enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response,error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("HTTP Error with status code: \(statusCode), Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))
                    )
                }
            } else if let error = error {
                print("URL Request Error: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))
                )
            } else {
                print("URLSession Error: No data or error received.")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)
                )
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let decoder = SnakeCaseJSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(T.self, from: data)
                    fulfillCompletionOnTheMainThread(.success(response))
                }
                catch {
                    print("Decode error in \(#function): \(error.localizedDescription), Response: \(String(data: data, encoding: .utf8) ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            case .failure(let error):
                print("Error in \(#function) \(#file): \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        return task
    }
}

