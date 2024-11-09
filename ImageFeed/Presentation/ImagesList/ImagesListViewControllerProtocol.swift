//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.11.2024.
//

import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol?  { get set }

    func updateTableViewAnimated(from oldCount: Int, to newCount: Int)
    func blockInteraction(_ state: Bool)
    func showError()
}
