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
    private(set) var likedPhotos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var lastLoadedLikedPhotosPage: Int?
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var likedPhotosTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else {
            print("Fetch photos task is already in progress")
            return
        }
        
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
                    self.photos.append(Photo(from: $0)
                    )
                }
                
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
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
    
    func fetchLikedPhotosNextPage(username: String) {
        assert(Thread.isMainThread)
        
        guard likedPhotosTask == nil else {
            print("Fetch liked photos task is already in progress")
            return
        }
        
        let nextPage = (lastLoadedLikedPhotosPage ?? 0) + 1
        
        guard let request = makeLikedPhotosRequest(page: nextPage.description, username: username) else {
            print("Make liked photos request fail \(#file)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photosData):
                photosData.forEach {
                    self.likedPhotos.append(Photo(from: $0)
                    )
                }
                
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                
                self.likedPhotosTask = nil
                self.lastLoadedLikedPhotosPage = nextPage
            case .failure(let error):
                print("Error in \(#function) \(#file): \(error.localizedDescription)")
            }
        }
        self.likedPhotosTask = task
        task.resume()
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
                
//                if let index = self.likedPhotos.firstIndex(where: { $0.id == photoId }) {
//                    
//                }
                
                
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
        likedPhotos.removeAll()
        lastLoadedPage = nil
    }
    
    // MARK: - Private Methods
  
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
        
        return createRequest(withURL: url)
    }
    
    private func makeLikedPhotosRequest(page: String, username: String) -> URLRequest? {
        let likedPhotosURL = URL(string: "users/\(username)/likes", relativeTo: Constants.defaultBaseURL)
        guard let likedPhotosURL else {
            print("Unable to construct URL for liked photos request")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: likedPhotosURL, resolvingAgainstBaseURL: true) else {
            print("Unsplash URL for liked photos request is wrong")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: page)
        ]
        
        guard let url = urlComponents.url else {
            print("Unable to construct URL for photo request")
            return nil
        }
        
        return createRequest(withURL: url)
    }
    
    private func makeLikeRequest(photoID: String, isLike: Bool) -> URLRequest? {
        let likeURL = URL(string: "photos/\(photoID)/like", relativeTo: Constants.defaultBaseURL)
        guard let likeURL else {
            print("Unable to construct URL for photos Request")
            return nil
        }

        let method = isLike ? "POST" : "DELETE"
        
        return createRequest(withURL: likeURL, httpMethod: method)
    }
    
    private func createRequest(withURL url: URL, httpMethod: String = "GET") -> URLRequest? {
        guard let token = storage.token else {
            print("Unable to get token")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}


