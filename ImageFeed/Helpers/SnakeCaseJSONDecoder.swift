//
//  SnakeCaseJSONDecoder.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 24.09.2024.
//

import Foundation

final class SnakeCaseJSONDecoder: JSONDecoder, @unchecked Sendable {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
