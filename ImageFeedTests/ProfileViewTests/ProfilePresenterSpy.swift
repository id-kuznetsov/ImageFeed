//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 09.11.2024.
//

import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {

    
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var logoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func loadProfile() -> ImageFeed.Profile? {
        nil
    }
    
    func loadAvatarURL() -> URL? {
        nil
    }
    
    func updateLikedPhotos() {}
    
    func getPhoto(for index: Int) -> ImageFeed.Photo {
        Photo(
            id: "test",
            size: CGSize.zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: nil,
            largeImageURL: nil,
            isLiked: false
        )
    }
    
    func numberOfRows() -> Int {
        0
    }
    
    func loadNextPage(indexPath: IndexPath) {}
    func didTapLike(for index: Int, in cell: ImageFeed.ImagesListCell) {}
    func logout() {}
    
    func didTapLogout() {
        logoutCalled = true
        view?.showExitAlert()
    }

}
