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
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: URL?
    let largeImageURL: URL?
    let isLiked: Bool
    
    init(id: String, size: CGSize, createdAt: String?, welcomeDescription: String?, thumbImageURL: URL?, largeImageURL: URL?, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt
        self.welcomeDescription = result.description
        self.thumbImageURL = URL(string: result.urls.thumb)
        self.largeImageURL = URL(string: result.urls.full)
        self.isLiked = result.likedByUser
    }
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
