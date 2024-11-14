//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 01.09.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    // MARK: - Public Properties
  
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Private Properties

    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageCache = ImageCache.default
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProfileInfoCell.self, forCellReuseIdentifier: ProfileInfoCell.reuseIdentifier)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = .ypBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var emptyFavouritesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var emptyFavouritesImageView: UIImageView = {
        let favouritesImageView = UIImageView()
        favouritesImageView.image = UIImage(systemName: "square.3.layers.3d.down.right")
        favouritesImageView.tintColor = .ypWhite
        favouritesImageView.contentMode = .scaleAspectFit
        favouritesImageView.translatesAutoresizingMaskIntoConstraints = false
        return favouritesImageView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileView()
        presenter?.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.updateLikedPhotos()
            }
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presenter?.updateLikedPhotos()
        }

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func configProfileInfoCell(for cell: ProfileInfoCell, with profile: Profile, avatarURL: URL) {
        cell.configProfileInfo(with: profile, avatarURL: avatarURL)
    }
    
    func configLikedCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.configLikedCell(cell: cell, indexPath: indexPath)
    }
    
    func blockInteraction(_ state: Bool) {
        if state {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }

    func showExitAlert() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttonText: "Нет",
            cancelButtonText: "Да",
            completion: { [weak self] in
                guard let self else { return }
                self.updateAvatarInProfileCell()
                self.dismiss(animated: true)
            },
            cancelCompletion: { [weak self] in
                guard let self else { return }
                self.imageCache.clearCache()
                self.presenter?.logout()
            }
        )
        AlertPresenter.showAlert(alertModel, delegate: self)
    }
    
    func showError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось изменить лайк",
            buttonText: "OK",
            completion: {}
        )
        AlertPresenter.showAlert(alertModel, delegate: self)
    }
    
    // MARK: - Private Methods

    private func updateAvatarInProfileCell() {
        let profileIndexPath = IndexPath(row: 0, section: 0)
        
        if let profileInfoCell = tableView.cellForRow(at: profileIndexPath) as? ProfileInfoCell {
            guard let profile = presenter?.loadProfile(),
                  let avatarURL = presenter?.loadAvatarURL() else {
                print("No profile data \(#function) \(#file)")
                return
            }
            configProfileInfoCell(for: profileInfoCell, with: profile, avatarURL: avatarURL)
            profileInfoCell.hideProfileInfo(false)
        }
    }
    
    private func setProfileView() {
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
    
    private func emptyFavouritesStackViewConstraints() -> [NSLayoutConstraint] {
        [emptyFavouritesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//         emptyFavouritesStackView.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor),
         emptyFavouritesStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
         emptyFavouritesStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
         emptyFavouritesStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.leadingSize)
        ]
    }
    
    private func emptyFavouritesImageViewConstraints() -> [NSLayoutConstraint] {
        [emptyFavouritesImageView.widthAnchor.constraint(equalToConstant: Constants.emptyFavouritesSize),
         emptyFavouritesImageView.heightAnchor.constraint(equalToConstant: Constants.emptyFavouritesSize)]
    }
}

// MARK: - Extensions

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileInfoCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let profileInfoCell = cell as? ProfileInfoCell else {
                assertionFailure("Construct profile cell failed")
                return ProfileInfoCell()
            }

            profileInfoCell.delegate = self
            guard let profile = presenter?.loadProfile(),
                  let avatarURL = presenter?.loadAvatarURL() else {
                print("No profile data \(#function) \(#file)")
                return ProfileInfoCell()
            }
            
            configProfileInfoCell(for: profileInfoCell, with: profile, avatarURL: avatarURL)
            
            return profileInfoCell
        } else {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.loadNextPage(indexPath: indexPath)
    }
}

// MARK: UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 220
        } else {
            guard let image = presenter?.getPhoto(for: indexPath.row - 1) else {
                return 200
            }
           
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
}

extension ProfileViewController: ProfileInfoCellDelegate {
    func profileInfoDidTapExit() {
        presenter?.didTapLogout()
    }
}

extension ProfileViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(for: indexPath.row, in: cell)
    }
}

extension ProfileViewController {
    private enum Constants {
        static let profileImageSize: CGFloat = 70
        static let buttonsSize: CGFloat = 70
        static let emptyFavouritesSize: CGFloat = 115
        
        static let imageTopConstraint: CGFloat = 4
        static let imageBottomConstraint: CGFloat = 4
        static let leadingSize: CGFloat = 16
        static let trailingSize: CGFloat = 16
    }
}

// MARK: AlertPresenterDelegate

extension ProfileViewController: AlertPresenterDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}
