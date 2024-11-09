//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var exitAlertCalled: Bool = false
    var viewUpdateAvatarCalled: Bool = false
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
        
    }
    
    func updateAvatar(url: URL) {
        viewUpdateAvatarCalled = true
    }
    
    func showExitAlert() {
        exitAlertCalled = true
    }
    
    
}
