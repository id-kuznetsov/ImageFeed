//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 06.10.2024.
//

import Foundation

final class ProfileService {
    // MARK: - Constants
    
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    
    private let decoder = SnakeCaseJSONDecoder()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func makeProfileRequest(token: String) -> URLRequest {
        let profileGetURL = URL(string: "me", relativeTo: Constants.defaultBaseURL)
        
        guard let url = profileGetURL else {
            preconditionFailure("Unable to construct URL for profile Request")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = makeProfileRequest(token: token)
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do { // TODO: искать ошибку тут
                    
                    let response = try self.decoder.decode(ProfileResult.self, from: data)
                    self.profile = Profile(
                        name: response.name ?? " ",
                        loginName: "@" + response.username,
                        bio: response.bio ?? " "
                    )
                    guard let profileData = self.profile else {
                        print("Unable to construct Profile")
                        return
                    }
                    completion(.success(profileData))
                    print("\(profileData)")
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


