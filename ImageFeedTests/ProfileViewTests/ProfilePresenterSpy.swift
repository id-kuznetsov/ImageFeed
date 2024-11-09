//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 09.11.2024.
//

import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var logoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func loadProfile() {
        
    }
    
    func loadAvatar() {
        
    }
    
    func didTapLogout() {
        logoutCalled = true
        view?.showExitAlert()
    }
    
    func logout() {
        
    }
    
    
}
