//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    func blockInteraction(_ state: Bool) {}
    
    func showError() {}
    
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var exitAlertCalled: Bool = false
    var viewUpdateAvatarCalled: Bool = false
    
    func updateProfileDetails(profile: ImageFeed.Profile) {}
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {}
    func configProfileInfoCell(for cell: ImageFeed.ProfileInfoCell, with profile: ImageFeed.Profile, avatarURL: URL) {}
    
    func updateAvatar(url: URL) {
        viewUpdateAvatarCalled = true
    }
    
    func showExitAlert() {
        exitAlertCalled = true
    }
}