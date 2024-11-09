//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testNumberOfRowsCalled() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        let numberOfRows = presenter.numberOfPhotos()
        
        // Then
        XCTAssertEqual(numberOfRows, 10)
    }
    
    func testGetPhoto() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        let photo = presenter.getPhoto(for: 0)
        let testPhoto = Photo(
            id: "test",
            size: CGSize.zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: nil,
            largeImageURL: nil,
            isLiked: false
        )
        
        // Then
        XCTAssertEqual(photo.id, testPhoto.id)
        XCTAssertEqual(photo.size, testPhoto.size)
        XCTAssertEqual(photo.isLiked, testPhoto.isLiked)
        
    }
    
    func testLikePhoto() {
        // Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        presenter.updateLike(for: 0, isLiked: false)
        
        // Then
        XCTAssertTrue(presenter.likePhotoCalled)
    }
    
    func testViewControllerCallsUpdateTableView() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        
        // When
        viewController.updateTableViewAnimated(from: 0, to: 10)
        
        // Then
        XCTAssertTrue(viewController.tableViewUpdateAnimatedCalled)
    }

}
