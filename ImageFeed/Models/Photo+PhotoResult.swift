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
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt, updatedAt: Date
    let width, height: Int
    let color, blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String
    let urls: Urls
}

struct Urls: Decodable {
    let raw, full, regular, small: String
    let thumb: String
}
