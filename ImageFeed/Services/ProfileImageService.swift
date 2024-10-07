//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 07.10.2024.
//

import Foundation

final class ProfileImageService {
    // MARK: - Constants
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    
    private let decoder = SnakeCaseJSONDecoder()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String? // TODO: возможно поменять на URL? И тут, и в модели
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    func makeProfileImageRequest(username: String) -> URLRequest {
        let profileImageGetURL = URL(string: "users/\(username)", relativeTo: Constants.defaultBaseURL)
        
        guard let url = profileImageGetURL else {
            preconditionFailure("Unable to construct URL for profile image request")
        }
        
        var request = URLRequest(url: url)
        
        guard let token = storage.token else {
            preconditionFailure("Unable to get token")
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = makeProfileImageRequest(username: username)
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(UserResult.self, from: data)
                    
                    avatarURL = response.profileImage.small
                    
                    guard let profileImageURL = self.avatarURL else {
                        print("Unable to get image")
                        return
                    }
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL]
                        )
                    
                    self.task = nil
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
