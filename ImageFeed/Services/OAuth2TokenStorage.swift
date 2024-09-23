//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation

final class OAuth2TokenStorage {
    // MARK: - Constants
    static let shared = OAuth2TokenStorage()
    // MARK: - Public Properties
    var token: String? {
        get {
            storage.string(forKey: Keys.token.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    // MARK: - Private properties
    private let storage = UserDefaults.standard
    private enum Keys: String {
        case token
    }
}
