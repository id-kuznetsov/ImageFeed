//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.11.2024.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func updatePhotos()
    func loadNextPage(indexPath: IndexPath)
    func getPhoto(for index: Int) -> Photo
    func numberOfPhotos() -> Int
    func didTapLike(for index: Int, in cell: ImagesListCell)
    func updateLike(for index: Int, isLiked: Bool)
}
