//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 20.09.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Constants
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Public Properties
    
    var token: String? {
        get {
            storage.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else {
                print("Invalid format token")
                return
            }
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    // MARK: - Private properties
    
    private let storage = KeychainWrapper.standard
    private enum Keys: String {
        case token
    }
}
