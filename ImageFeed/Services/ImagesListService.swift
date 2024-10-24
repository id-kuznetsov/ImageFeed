//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 24.10.2024.
//

import Foundation

final class ImagesListService {
    
    // MARK: - Constants
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    // MARK: - Initializers
    
    
    
    // MARK: - Public Methods
    func makePhotosRequest() -> URLRequest? {
        let photoGetURL = URL(string: "photos", relativeTo: Constants.defaultBaseURL)
        guard let photoGetURL else {
            print("Unable to construct URL for photos Request")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: photoGetURL, resolvingAgainstBaseURL: true) else {
            print("Unsplash URL for photos request is wrong")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: lastLoadedPage?.description),
        ]
        
        guard let url = urlComponents.url else {
            print("Unable to construct URL for photo request")
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
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makePhotosRequest() else {
            print("Make photos request fail \(#file)")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photosData):
                DispatchQueue.main.async {
                    photosData.forEach {
                        self.photos.append(
                            Photo(
                                id: $0.id,
                                size: CGSize(width: $0.width, height: $0.height),
                                createdAt: Date(), //TODO: разобраться с форматом даты
                                welcomeDescription: $0.description,
                                thumbImageURL: $0.urls.thumb,
                                largeImageURL: $0.urls.full,
                                isLiked: $0.likedByUser
                            )
                        )
                    }
                }
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": ImagesListService.didChangeNotification]
                        )
                    
                    self.task = nil
                    self.lastLoadedPage = nextPage
                    
                case .failure(let error):
                    print("Error in \(#function) \(#file): \(error.localizedDescription)")
                }
            }
            self.task = task
            task.resume()
        }
    }
