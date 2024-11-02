//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 27.10.2024.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Constants
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Private Properties
    
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Public Methods
    
    func logout() {
        cleanProfile()
        cleanImageList()
        cleanCookies()
        switchToSplashViewController()
    }
    
    // MARK: - Private Methods
    
    private func cleanProfile() {
        storage.clearTokenStorage()
        
        let allValues = UserDefaults.standard.dictionaryRepresentation()
        allValues.keys.forEach{ key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    private func cleanImageList() {
        ImagesListService.shared.removeAllImages()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
}

