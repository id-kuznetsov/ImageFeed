//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.11.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogoutCalled() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // When
        presenter.didTapLogout()
        
        // Then
        XCTAssertTrue(presenter.logoutCalled)
    }
    
    func testExitAllertCalled() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.didTapLogout()
        
        // Then
        XCTAssertTrue(viewController.exitAlertCalled)
    }
    
    func testUpdateAvatar() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let testURL = URL(string: "https://example.com")!
        
        // When
        viewController.updateAvatar(url: testURL)
        
        // Then
        XCTAssertTrue(viewController.viewUpdateAvatarCalled)
    }

}
