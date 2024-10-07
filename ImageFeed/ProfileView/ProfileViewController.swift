//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 01.09.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let profileService = ProfileService.shared
    
    private lazy var profileImageView: UIImageView = {
        let profileImage = UIImageView()
        profileImage.image = UIImage(named: "avatar")
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
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        return nameLabel
    }()
    
    private lazy var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.text = "@ekaterina_nov"
        loginLabel.textColor = .ypGrey
        loginLabel.font = .systemFont(ofSize: 13)
        return loginLabel
    }()
    
    private lazy var bioLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = "Hello, world!"
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
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileView()
        

    }
    
    // MARK: - actions
    
    @objc
    private func didLogoutButtonTapped() {
        profileInfoStackView.isHidden = true
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .ypGrey
        let allValues = UserDefaults.standard.dictionaryRepresentation()
        allValues.keys.forEach{ key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        bioLabel.text = profile.bio
    }
    
    private func setProfileView() {
        guard let profile = profileService.profile else {
            print("No profile data")
            return
        }
        updateProfileDetails(profile: profile)
        
        view.backgroundColor = .ypBlack
        addLabelsInProfileInfoStackView()
        addFavouritesPlaceHolder()
        
        [profileImageView, exitButton, profileInfoStackView, favouritesLabel, emptyFavouritesStackView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
            profileImageViewConstraints() +
            exitButtonViewConstraints() +
            profileStackViewConstraints() +
            favouritesLabelViewConstraints() +
            emptyFavouritesStackViewConstraints() +
            emptyFavouritesImageViewConstraints()
        )
    }
    
    private func addLabelsInProfileInfoStackView() {
        profileInfoStackView.addArrangedSubview(nameLabel)
        profileInfoStackView.addArrangedSubview(loginLabel)
        profileInfoStackView.addArrangedSubview(bioLabel)
    }
    
    private func addFavouritesPlaceHolder() {
        emptyFavouritesStackView.addArrangedSubview(emptyFavouritesImageView)
    }
    
    
    // MARK: - constraints
    
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
         favouritesLabel.heightAnchor.constraint(equalToConstant: 23)
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

// MARK: - extensions

extension ProfileViewController {
    private enum Constants {
        static let profileImageSize: CGFloat = 70
        static let buttonsSize: CGFloat = 70
        static let leadingSize: CGFloat = 16
        static let emptyFavouritesSize: CGFloat = 115
    }
}


