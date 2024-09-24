//
//  Constants.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 19.09.2024.
//

import Foundation

enum Constants {
    static let accessKey = "ej-XzwMrTTUmvG9_5tdREQjSpZq5FZiMi9SEz2_BOQ4"
    static let secretKey = "g02jJ4bZGXYIb6qX0YUo-EqITnAh417zE5o4gdeBRG0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
    static let unsplashGetTokenURLString = "https://unsplash.com/oauth/token"
}
