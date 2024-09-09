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
    
    private func setProfileView() {
        view.backgroundColor = .ypBlack
        
        [profileImageView, exitButton, nameLabel, loginLabel, statusLabel, favouritesLabel, emptyFavouritesImageView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
            profileImageViewConstraints() + 
            exitButtonViewConstraints() +
            nameLabelViewConstraints() +
            loginLabelViewConstraints() +
            statusLabelViewConstraints() +
            favouritesLabelViewConstraints() +
            emptyFavouritesImageViewConstraints()
        )
    }
    // MARK: - constraints
    private func profileImageViewConstraints() -> [NSLayoutConstraint] {
        [profileImageView.widthAnchor.constraint(equalToConstant: 70),
         profileImageView.heightAnchor.constraint(equalToConstant: 70),
         profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ]
    }
    private func exitButtonViewConstraints() -> [NSLayoutConstraint] {
        [exitButton.widthAnchor.constraint(equalToConstant: 44),
         exitButton.heightAnchor.constraint(equalToConstant: 44),
         exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
         exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ]
    }
    private func nameLabelViewConstraints() -> [NSLayoutConstraint] {
        [nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ]
    }
    
    private func loginLabelViewConstraints() -> [NSLayoutConstraint] {
        [loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ]
    }
    
    private func statusLabelViewConstraints() -> [NSLayoutConstraint] {
        [statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         statusLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ]
    }
    
    private func favouritesLabelViewConstraints() -> [NSLayoutConstraint] {
        [favouritesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
         favouritesLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24)
        ]
    }
    
    private func emptyFavouritesImageViewConstraints() -> [NSLayoutConstraint] {
        // расчет расстояния между верхом
        [emptyFavouritesImageView.widthAnchor.constraint(equalToConstant: 115),
         emptyFavouritesImageView.heightAnchor.constraint(equalTo: emptyFavouritesImageView.widthAnchor, multiplier: 1),
         emptyFavouritesImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         emptyFavouritesImageView.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor, constant: 100)
        ]
    }
    
    
    
    // MARK: - actions
    @objc
    private func didLogoutButtonTapped() {
        
    }
}
