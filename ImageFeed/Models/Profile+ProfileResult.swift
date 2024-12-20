//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 06.10.2024.
//

import Foundation

struct Profile {
    let username, name, loginName, bio: String
    let totalLikes: Int
}

struct ProfileResult: Decodable {
    let username: String
    let name, firstname, lastname: String?
    let bio: String?
    let totalLikes: Int?
}
