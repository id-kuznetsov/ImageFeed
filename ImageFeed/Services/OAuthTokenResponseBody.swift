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

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
