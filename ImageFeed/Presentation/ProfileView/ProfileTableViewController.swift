//
//  ProfileTableViewController.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 06.11.2024.
//

import UIKit
import Kingfisher

class ProfileTableViewController: UIViewController {
   
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let imagesListService = ImagesListService.shared
    private var likedPhotos: [Photo] = []
    private var imageCache = ImageCache.default
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            ProfileViewCell.self,
            forCellReuseIdentifier: ProfileViewCell.reuseIdentifier
        )
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )
        tableView.backgroundColor = .ypBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Initializers

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
        guard let username = profileService.profile?.username else { return }
        imagesListService.fetchLikedPhotosNextPage(username: username)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    // MARK: - Public Methods

    // MARK: - Private Methods
    
    private func updateTableViewAnimated() {
        let oldCount = likedPhotos.count
        let newCount = imagesListService.likedPhotos.count
        likedPhotos = imagesListService.likedPhotos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    private func setTableView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            [tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }
    private func showLikeError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось изменить лайк",
            buttonText: "OK",
            completion: {}
        )
        AlertPresenter.showAlert(alertModel, delegate: self)
    }
    
    private func showExitAlert() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttonText: "Нет",
            cancelButtonText: "Да",
            completion: { [weak self] in
                guard let self else { return }
                if let profileCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileViewCell {
                    profileCell.cancelExit()
                }
                self.dismiss(animated: true)
            },
            cancelCompletion: { [weak self] in
                guard let self else { return }
                self.imageCache.clearCache()
                self.profileLogoutService.logout()
            }
        )
        AlertPresenter.showAlert(alertModel, delegate: self)
    }
}

// MARK: - Extensions

extension ProfileTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        likedPhotos.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileViewCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let profileViewCell = cell as? ProfileViewCell else {
                assertionFailure("Construct profile cell failed")
                return ProfileViewCell()
            }
            
            profileViewCell.delegate = self
            
            //            configCell(for: profileViewCell, with: indexPath)
            return profileViewCell
        } else { // TODO: если пустая
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let imageListCell = cell as? ImagesListCell else {
                assertionFailure("Construct cell failed")
                return ImagesListCell()
            }
            
            imageListCell.delegate = self
            
            configLikedCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 221
        } else {
            let image = likedPhotos[indexPath.row - 1]
            
            let insets = UIEdgeInsets(
                top: Constants.imageTopConstraint,
                left: Constants.leadingSize,
                bottom: Constants.imageBottomConstraint,
                right: Constants.trailingSize
            )
            let imageWidth = image.size.width - insets.left - insets.right
            let imageCellWidth = tableView.bounds.width
            let scaleFactor = imageCellWidth / imageWidth
            let imageCellHeight = image.size.height * scaleFactor + insets.left + insets.right
            
            return imageCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == likedPhotos.count {
            guard let username = profileService.profile?.username else { return }
            imagesListService.fetchLikedPhotosNextPage(username: username)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImage = SingleImageViewController()
        singleImage.delegate = self
        singleImage.indexPath = indexPath
        guard let largeImageURL = likedPhotos[indexPath.row - 1].largeImageURL else { return }
        let isLiked = likedPhotos[indexPath.row].isLiked
        let photoID = likedPhotos[indexPath.row].id
        singleImage.setImageFromURL(fullImageURL: largeImageURL, isLiked: isLiked, photoID: photoID)
        singleImage.modalPresentationStyle = .overFullScreen
        present(singleImage, animated: true)
    }
}

extension ProfileTableViewController {
    func configLikedCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.configLikedCell(cell: cell, indexPath: indexPath)
    }
}

// MARK: AlertPresenterDelegate

extension ProfileTableViewController: AlertPresenterDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}

// MARK: ProfileViewCellDelegate

extension ProfileTableViewController: ProfileViewCellDelegate {
    func profileViewCellDidTapExit(_ cell: ProfileViewCell) {
        showExitAlert()
    }
}

// MARK: ImagesListCellDelegate

extension ProfileTableViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = likedPhotos[indexPath.row - 1]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.likedPhotos = self.imagesListService.likedPhotos
                cell.setIsLiked(self.likedPhotos[indexPath.row - 1].isLiked)
            case .failure:
                showLikeError()
            }
        }
    }
}

extension ProfileTableViewController: SingleImageViewControllerDelegate {
    func didUpdateLikeStatus(for indexPath: IndexPath, isLiked: Bool) {
        let photo = likedPhotos[indexPath.row - 1]
        let newPhoto = Photo(
                 id: photo.id,
                 size: photo.size,
                 createdAt: photo.createdAt,
                 welcomeDescription: photo.welcomeDescription,
                 thumbImageURL: photo.thumbImageURL,
                 largeImageURL: photo.largeImageURL,
                 isLiked: !photo.isLiked
             )
        self.likedPhotos[indexPath.row - 1] = newPhoto
        // TODO: проверить тут, не меняется лайк
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.setIsLiked(isLiked)
        }
    }
}

extension ProfileTableViewController {
    private enum Constants {
        static let imageTopConstraint: CGFloat = 4
        static let imageBottomConstraint: CGFloat = 4
        static let leadingSize: CGFloat = 16
        static let trailingSize: CGFloat = 16
    }
}
