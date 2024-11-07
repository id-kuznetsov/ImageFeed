//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 01.09.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageCache = ImageCache.default
    
    private lazy var profileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.backgroundColor = .ypBlack
        profileImage.layer.masksToBounds = true
        profileImage.frame.size = CGSize(width: 70, height: 70)
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.image = UIImage(systemName: "person.crop.circle.fill")
        profileImage.tintColor = .ypGrey
        return profileImage
    }()
    
    private lazy var profileInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        return nameLabel
    }()
    
    private lazy var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.textColor = .ypGrey
        loginLabel.font = .systemFont(ofSize: 13)
        return loginLabel
    }()
    
    private lazy var bioLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.textColor = .ypWhite
        statusLabel.font = .systemFont(ofSize: 13)
        return statusLabel
    }()
    
    private lazy var exitButton: UIButton = {
        guard let buttonImage = UIImage(systemName: "ipad.and.arrow.forward") else { return UIButton() }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(self.didLogoutButtonTapped)
        )
        button.tintColor = .ypRed
        return button
    }()
    
    private lazy var favouritesLabel: UILabel = {
        let favouritesLabel = UILabel()
        favouritesLabel.text = "Избранное"
        favouritesLabel.textColor = .ypWhite
        favouritesLabel.font = .boldSystemFont(ofSize: 23)
        return favouritesLabel
    }()
    
    private lazy var favouritesCountLabel: UILabel = {
        let favouritesLabel = UILabel()
        favouritesLabel.textColor = .ypWhite
        favouritesLabel.font = .systemFont(ofSize: 13)
        favouritesLabel.textAlignment = .center
        favouritesLabel.translatesAutoresizingMaskIntoConstraints = false
        return favouritesLabel
    }()
    
    private lazy var favouritesBackgroundView: UIView = {
        let favouritesBackgroundView = UIView()
        favouritesBackgroundView.backgroundColor = .ypBlue
        favouritesBackgroundView.layer.cornerRadius = 11
        favouritesBackgroundView.layer.masksToBounds = true
        favouritesBackgroundView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return favouritesBackgroundView
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
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Actions
    
    @objc
    private func didLogoutButtonTapped() {
        profileInfoStackView.isHidden = true
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .ypGrey
        showExitAlert()
        
    }
    
    // MARK: - Private Methods
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        bioLabel.text = profile.bio
        favouritesCountLabel.text = "\(profile.totalLikes)"
    }
    
    private func updateAvatar() {
        imageCache.clearCache()
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return
        }
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url,
                                     placeholder: UIImage(systemName: "person.crop.circle.fill"),
                                     options:[.fromMemoryCacheOrRefresh]
        ){ result in
            switch result {
            case .success(let value):
                print("Image loaded from \(value.cacheType)")
                print("Image source:\(value.source)")
            case .failure(let error):
                print("Failed updateAvatar with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func showExitAlert() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttonText: "Нет",
            cancelButtonText: "Да",
            completion: { [weak self] in
                guard let self else { return }
                self.updateAvatar()
                profileInfoStackView.isHidden = false
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
    
    private func setProfileView() {
        guard let profile = profileService.profile else {
            print("No profile data")
            return
        }
        updateProfileDetails(profile: profile)
        
        view.backgroundColor = .ypBlack
        addLabelsInProfileInfoStackView()
        favouritesBackgroundView.addSubview(favouritesCountLabel)
        addFavouritesPlaceHolder()
        
        [profileImageView, exitButton, profileInfoStackView, favouritesLabel, favouritesBackgroundView, emptyFavouritesStackView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
            profileImageViewConstraints() +
            exitButtonViewConstraints() +
            profileStackViewConstraints() +
            favouritesLabelViewConstraints() +
            favouritesCountLabelViewConstraints() +
            favouritesBackgroundViewConstraints() +
            emptyFavouritesStackViewConstraints() +
            emptyFavouritesImageViewConstraints()
        )
        
        if profile.totalLikes == 0 {
            favouritesBackgroundView.isHidden = true
        }
    }
    
    private func addLabelsInProfileInfoStackView() {
        profileInfoStackView.addArrangedSubview(nameLabel)
        profileInfoStackView.addArrangedSubview(loginLabel)
        profileInfoStackView.addArrangedSubview(bioLabel)
    }
    
    private func addFavouritesPlaceHolder() {
        emptyFavouritesStackView.addArrangedSubview(emptyFavouritesImageView)
    }
    
    
    // MARK: - Constraints
    
    private func profileImageViewConstraints() -> [NSLayoutConstraint] {
        [profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize),
         profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
         profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
         profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ]
    }
    private func exitButtonViewConstraints() -> [NSLayoutConstraint] {
        [exitButton.widthAnchor.constraint(equalToConstant: Constants.buttonsSize),
         exitButton.heightAnchor.constraint(equalToConstant: Constants.buttonsSize),
         exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
         exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ]
    }
    
    private func profileStackViewConstraints() -> [NSLayoutConstraint] {
        [profileInfoStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
         profileInfoStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ]
    }
    
    private func favouritesLabelViewConstraints() -> [NSLayoutConstraint] {
        [favouritesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
         favouritesLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 100),
         favouritesLabel.heightAnchor.constraint(equalToConstant: 22)
        ]
    }
    
    private func favouritesCountLabelViewConstraints() -> [NSLayoutConstraint] {
        [favouritesCountLabel.leadingAnchor.constraint(equalTo: favouritesBackgroundView.layoutMarginsGuide.leadingAnchor),
         favouritesCountLabel.trailingAnchor.constraint(equalTo: favouritesBackgroundView.layoutMarginsGuide.trailingAnchor),
         favouritesCountLabel.topAnchor.constraint(equalTo: favouritesBackgroundView.layoutMarginsGuide.topAnchor),
         favouritesCountLabel.bottomAnchor.constraint(equalTo: favouritesBackgroundView.layoutMarginsGuide.bottomAnchor)
        ]
    }
    
    private func favouritesBackgroundViewConstraints() -> [NSLayoutConstraint] {
        [favouritesBackgroundView.leadingAnchor.constraint(equalTo: favouritesLabel.trailingAnchor, constant: 8),
         favouritesBackgroundView.centerYAnchor.constraint(equalTo: favouritesLabel.centerYAnchor),
         favouritesBackgroundView.heightAnchor.constraint(equalToConstant: 22)
        ]
    }
    
    private func emptyFavouritesStackViewConstraints() -> [NSLayoutConstraint] {
        [emptyFavouritesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         emptyFavouritesStackView.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor),
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

extension ProfileViewController {
    private enum Constants {
        static let profileImageSize: CGFloat = 70
        static let buttonsSize: CGFloat = 70
        static let leadingSize: CGFloat = 16
        static let emptyFavouritesSize: CGFloat = 115
    }
}

// MARK: AlertPresenterDelegate

extension ProfileViewController: AlertPresenterDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}


