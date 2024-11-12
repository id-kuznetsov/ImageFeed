//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var likePhotoCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updatePhotos() {}
    func loadNextPage(indexPath: IndexPath) {}
    
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
    
    func numberOfPhotos() -> Int {
        return 10
    }
    
    func didTapLike(for index: Int, in cell: ImageFeed.ImagesListCell) {}
    
    func updateLike(for index: Int, isLiked: Bool) {
        likePhotoCalled = true
    }
}
