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
    static let shared = ImagesListService()
    
    // MARK: - Private Properties
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private let isoFormatter = ISO8601DateFormatter()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    private func makePhotosRequest(page: String) -> URLRequest? {
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
            URLQueryItem(name: "page", value: page)
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
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage.description) else {
            print("Make photos request fail \(#file)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photosData):
                photosData.forEach {
                    self.photos.append(
                        Photo(
                            id: $0.id,
                            size: CGSize(width: $0.width, height: $0.height),
                            createdAt: self.isoFormatter.date(from: $0.createdAt ?? "") ?? Date(),
                            welcomeDescription: $0.description,
                            thumbImageURL: URL(string: $0.urls.thumb),
                            largeImageURL: URL(string: $0.urls.full),
                            isLiked: $0.likedByUser
                        )
                    )
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
    
    private func makeLikeRequest(photoID: String, isLike: Bool) -> URLRequest? {
        let likeURL = URL(string: "photos/\(photoID)/like", relativeTo: Constants.defaultBaseURL)
        guard let likeURL else {
            print("Unable to construct URL for photos Request")
            return nil
        }
        
        var request = URLRequest(url: likeURL)
        
        guard let token = storage.token else {
            print("Unable to get token")
            return nil
        }
        
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        likeTask?.cancel()

        guard let request = makeLikeRequest(photoID: photoId, isLike: isLike) else {
            print("Make like request fail \(#file)")
            return
        }
        
        let likeTask = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            switch result {
            case .success( _):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                   let photo = self.photos[index]

                   let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt, 
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )

                    self.photos[index] = newPhoto
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": ImagesListService.didChangeNotification]
                        )
                    completion(.success(()))
                }
            case .failure(let error):
                print("Error in \(#function) \(#file): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.likeTask = likeTask
        likeTask.resume()
    }
    
    func removeAllImages() {
        photos.removeAll()
        lastLoadedPage = nil
    }
}
