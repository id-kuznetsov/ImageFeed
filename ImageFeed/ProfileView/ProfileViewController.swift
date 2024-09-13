//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 01.09.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Private properties
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
    
    private lazy var statusLabel: UILabel = {
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
    
    private lazy var emptyFavouritesImageView: UIImageView = {
        let favouritesImageView = UIImageView()
        favouritesImageView.image = UIImage(systemName: "square.3.layers.3d.down.right")
        favouritesImageView.tintColor = .ypWhite
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
        loginLabel.removeFromSuperview()
        nameLabel.removeFromSuperview()
        statusLabel.removeFromSuperview()
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .ypGrey
    }
    
    private func setProfileView() {
        view.backgroundColor = .ypBlack
        profileInfoStackView.addArrangedSubview(nameLabel)
        profileInfoStackView.addArrangedSubview(loginLabel)
        profileInfoStackView.addArrangedSubview(statusLabel)
        
        [profileImageView, exitButton, profileInfoStackView, favouritesLabel, emptyFavouritesImageView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
            profileImageViewConstraints() +
            exitButtonViewConstraints() +
            profileStackViewConstraints() +
            favouritesLabelViewConstraints() +
            emptyFavouritesImageViewConstraints()
        )
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
         favouritesLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 100)
        ]
    }
    
    private func emptyFavouritesImageViewConstraints() -> [NSLayoutConstraint] {
        [emptyFavouritesImageView.widthAnchor.constraint(equalToConstant: 115),
         emptyFavouritesImageView.heightAnchor.constraint(equalTo: emptyFavouritesImageView.widthAnchor, multiplier: 1),
         emptyFavouritesImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         emptyFavouritesImageView.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor, constant: 100)
        ]
    }
    
}
// MARK: - extensions

extension ProfileViewController {
    private enum Constants {
        static let profileImageSize: CGFloat = 70
        static let buttonsSize: CGFloat = 70
        static let leadingSize: CGFloat = 16
    }
}


