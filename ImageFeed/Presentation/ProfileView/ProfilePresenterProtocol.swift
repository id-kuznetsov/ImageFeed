//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func loadProfile() -> Profile?
    func loadAvatarURL() -> URL?
    func didTapLogout()
    func logout()
    
    
    func updateLikedPhotos()
    func getPhoto(for index: Int) -> Photo
    func numberOfRows() -> Int
    func loadNextPage(indexPath: IndexPath)
    func didTapLike(for index: Int, in cell: ImagesListCell)
    func updateLike(for index: Int, isLiked: Bool)
}
