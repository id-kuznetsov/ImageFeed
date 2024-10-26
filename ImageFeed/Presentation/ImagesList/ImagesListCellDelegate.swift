//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 27.10.2024.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
