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
    private(set) var avatarURL: String?
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func makeProfileImageRequest(username: String) -> URLRequest? {
        let profileImageGetURL = URL(string: "users/\(username)", relativeTo: Constants.defaultBaseURL)
        
        guard let url = profileImageGetURL else {
            print("Unable to construct URL for profile image request")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        guard let token = storage.token else {
            print("Unable to get token")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeProfileImageRequest(username: username) else {
            print("Make request fail \(#file)")
            return
        }
        
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profileImageData):
                self.avatarURL = profileImageData.profileImage.medium
                
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
                
            case .failure(let error):
                print("Error in \(#function) \(#file): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}
