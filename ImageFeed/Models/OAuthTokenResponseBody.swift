//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken, tokenType, scope: String
    let createdAt: Int
}
