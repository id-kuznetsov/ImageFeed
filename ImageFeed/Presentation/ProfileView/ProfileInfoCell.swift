//
//  ProfileInfoCell.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 13.11.2024.
//

import UIKit

final class ProfileInfoCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "ProfileViewCell"
    
    // MARK: - Properties
    
    weak var delegate: ProfileInfoCellDelegate?
    
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
        button.accessibilityIdentifier = ("Logout button")
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
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ypBlack
        backgroundColor = .clear
        selectionStyle = .none
        setProfileCellUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    // MARK: - Actions
    
    @objc
    private func didLogoutButtonTapped() {
        hideProfileInfo(true)
        delegate?.profileInfoDidTapExit()
    }
    
    func configProfileInfo(with profile: Profile, avatarURL: URL) {
        updateProfileDetails(profile: profile)
        updateAvatar(url: avatarURL)
    }

    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        bioLabel.text = profile.bio
        favouritesCountLabel.text = "\(profile.totalLikes)"
    }
    
    func updateAvatar(url: URL) {
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: url,
                                     placeholder: UIImage(systemName: "person.crop.circle.fill"),
                                     options: [.fromMemoryCacheOrRefresh]
        ){ result in
            switch result {
            case .success(let value):
                print("Image loaded from \(value.cacheType)")
            case .failure(let error):
                print("Failed updateAvatar with error: \(error.localizedDescription)")
            }
        }
    }
    
    func hideProfileInfo(_ state: Bool) {
        if state {
            profileInfoStackView.isHidden = state
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            profileImageView.tintColor = .ypGrey
        } else {
            profileInfoStackView.isHidden = state
        }
    }
    
    func setProfileCellUI() {
        contentView.backgroundColor = .ypBlack
        addLabelsInProfileInfoStackView()
        favouritesBackgroundView.addSubview(favouritesCountLabel)
        
        [profileImageView, exitButton, profileInfoStackView, favouritesLabel, favouritesBackgroundView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
            profileImageViewConstraints() +
            exitButtonViewConstraints() +
            profileStackViewConstraints() +
            favouritesLabelViewConstraints() +
            favouritesCountLabelViewConstraints() +
            favouritesBackgroundViewConstraints()
        )
    }
    
    private func addLabelsInProfileInfoStackView() {
        profileInfoStackView.addArrangedSubview(nameLabel)
        profileInfoStackView.addArrangedSubview(loginLabel)
        profileInfoStackView.addArrangedSubview(bioLabel)
    }

    // MARK: - Constraints

    private func profileImageViewConstraints() -> [NSLayoutConstraint] {
        [profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize),
         profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
         profileImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
         profileImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16)
        ]
    }
    private func exitButtonViewConstraints() -> [NSLayoutConstraint] {
        [exitButton.widthAnchor.constraint(equalToConstant: Constants.buttonsSize),
         exitButton.heightAnchor.constraint(equalToConstant: Constants.buttonsSize),
         exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
         exitButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ]
    }
    
    private func profileStackViewConstraints() -> [NSLayoutConstraint] {
        [profileInfoStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
         profileInfoStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ]
    }
    
    private func favouritesLabelViewConstraints() -> [NSLayoutConstraint] {
        [favouritesLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingSize),
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

}

extension ProfileInfoCell {
    private enum Constants {
        static let profileImageSize: CGFloat = 70
        static let buttonsSize: CGFloat = 70
        static let leadingSize: CGFloat = 16
        static let emptyFavouritesSize: CGFloat = 115
    }
}

