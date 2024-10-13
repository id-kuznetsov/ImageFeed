//
//  UserResult.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 07.10.2024.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
}

struct ProfileImage: Decodable {
    let small, medium, large: String
}


