//
//  Photo+PhotoResult.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 24.10.2024.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL?
    let largeImageURL: URL?
    let isLiked: Bool
}

struct LikeResult: Decodable {
    let photo: PhotoResult
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width, height: Int
    let likedByUser: Bool
    let description: String?
    let urls: Urls
}

struct Urls: Decodable {
    let raw, full, regular, small: String
    let thumb: String
}
