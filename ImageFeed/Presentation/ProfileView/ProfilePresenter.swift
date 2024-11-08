//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
  
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties

    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        loadProfile()
        loadAvatar()
    }
    
    func loadProfile() {
        guard let profile = profileService.profile else {
            print("No profile data")
            return
        }
        view?.updateProfileDetails(profile: profile)
    }
    
    func loadAvatar() {
        guard let profileImageURL = imageService.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return
        }
        view?.updateAvatar(url: url)
    }
    
    func didTapLogout() {
        view?.showExitAlert()
    }
    
    func logout() {
        profileLogoutService.logout()
    }
}
