//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: (any ImageFeed.ImagesListPresenterProtocol)?
    var tableViewUpdateAnimatedCalled: Bool = false
    
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {
        tableViewUpdateAnimatedCalled = true
    }
    
    func blockInteraction(_ state: Bool) {}
    func showError() {}
}
