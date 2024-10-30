//
//  SingleImageViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 30.10.2024.
//

import Foundation

protocol SingleImageViewControllerDelegate: AnyObject {
    func didUpdateLikeStatus(for indexPath: IndexPath, isLiked: Bool)
}
