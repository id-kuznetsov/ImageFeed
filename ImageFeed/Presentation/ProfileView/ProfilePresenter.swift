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
    
    func didTapLogout() {
        view?.showExitAlert()
    }
    
    func logout() {
        profileLogoutService.logout()
    }
}
