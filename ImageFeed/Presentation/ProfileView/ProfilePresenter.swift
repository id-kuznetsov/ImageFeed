//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {

    
    
    // MARK: - Public Properties
  
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties

    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let imagesListService = ImagesListService.shared
    private var likedPhotos: [Photo] = []
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        guard let username = profileService.profile?.username else {
            print("No profile data \(#function) \(#file)")
            return
        }
        imagesListService.fetchLikedPhotosNextPage(username: username)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLikeChangeNotification(_:)),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

    }
    
    func loadProfile() -> Profile? {
        guard let profile = profileService.profile else {
            print("No profile data \(#function) \(#file)")
            return nil
        }
        return profile
    }
    
    func loadAvatarURL() -> URL? {
        guard let profileImageURL = imageService.avatarURL else {
            return nil
        }
        return URL(string: profileImageURL)
    }
    
    func updateLikedPhotos() {
        let oldCount = likedPhotos.count
        let newCount = imagesListService.likedPhotos.count
        likedPhotos = imagesListService.likedPhotos
        if oldCount != newCount {
            view?.updateTableViewAnimated(from: oldCount, to: newCount)
        }
    }
    
    func getPhoto(for index: Int) -> Photo {
        likedPhotos[index]
    }
    
    func numberOfRows() -> Int {
        likedPhotos.count + 1
    }
    
    func loadNextPage(indexPath: IndexPath) {
        if indexPath.row + 1 == likedPhotos.count {
            guard let username = profileService.profile?.username else {
                print("No username data \(#function) \(#file)")
                return
            }
            imagesListService.fetchLikedPhotosNextPage(username: username)
        }
    }
    
    func didTapLike(for index: Int, in cell: ImagesListCell) {
        let photo = likedPhotos[index]
        view?.blockInteraction(true)
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            view?.blockInteraction(false)
            switch result {
            case .success:
                self.likedPhotos = self.imagesListService.likedPhotos
                cell.setIsLiked(self.likedPhotos[index].isLiked)
            case .failure:
                view?.showError()
            }
        }
    }
    
    func updateLike(for index: Int, isLiked: Bool) {
        let photo = likedPhotos[index]
        let newPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: !photo.isLiked
        )
        self.likedPhotos[index] = newPhoto
    }
    
    func didTapLogout() {
        view?.showExitAlert()
    }
    
    func logout() {
        profileLogoutService.logout()
    }
    
    
    
    @objc
    private func handleLikeChangeNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let updatedPhoto = userInfo["updatedPhoto"] as? Photo,
              let index = likedPhotos.firstIndex(where: { $0.id == updatedPhoto.id }) else { return }
        
        likedPhotos[index] = updatedPhoto

        view?.updateCell(at: index)
        
        guard let likesCount = profileService.profile?.totalLikes else {
            print("No likes data \(#function) \(#file)")
            return
        }
        
        if updatedPhoto.isLiked {
            profileService.updateTotalLikes(likesCount + 1)
            view?.updateLikeCount(likesCount + 1)
        } else {
            profileService.updateTotalLikes(likesCount - 1)
            view?.updateLikeCount(likesCount - 1)
        }
    }
}
