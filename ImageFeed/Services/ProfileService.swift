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
    
    func makeProfileRequest(token: String) -> URLRequest? {
        let profileGetURL = URL(string: "me", relativeTo: Constants.defaultBaseURL)
        
        guard let url = profileGetURL else {
            print("Unable to construct URL for profile Request")
            return nil
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
        
        guard let request = makeProfileRequest(token: token) else {
            print("Make request fail \(#file)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profileResult):
                self.profile = Profile(
                    username: profileResult.username,
                    name: profileResult.name ?? " ",
                    loginName: "@" + profileResult.username,
                    bio: profileResult.bio ?? " "
                    )
                guard let profileData = self.profile else {
                    print("Unable to construct Profile")
                    return
                }
                completion(.success(profileData))
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


