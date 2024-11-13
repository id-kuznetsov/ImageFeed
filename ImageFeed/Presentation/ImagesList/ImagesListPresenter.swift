//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.11.2024.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(from: oldCount, to: newCount)
        }
    }
    
    func loadNextPage(indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func numberOfPhotos() -> Int {
        photos.count
    }
    
    func getPhoto(for index: Int) -> Photo {
        photos[index]
    }
    
    func didTapLike(for index: Int, in cell: ImagesListCell) {
        let photo = photos[index]
        view?.blockInteraction(true)
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            view?.blockInteraction(false)
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[index].isLiked)
            case .failure:
                view?.showError()
            }
        }
    }
    
    func updateLike(for index: Int, isLiked: Bool) {
        let photo = photos[index]
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
    }
}

extension ImagesListPresenter {
    private enum Constants {
        static let imageTopConstraint: CGFloat = 4
        static let imageBottomConstraint: CGFloat = 4
        static let leadingSize: CGFloat = 16
        static let trailingSize: CGFloat = 16
    }
}
