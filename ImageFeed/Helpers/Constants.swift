//
//  Constants.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 12.11.2024.
//

import Foundation

enum Constants {
    static let accessKey = "ej-XzwMrTTUmvG9_5tdREQjSpZq5FZiMi9SEz2_BOQ4"
    static let secretKey = "g02jJ4bZGXYIb6qX0YUo-EqITnAh417zE5o4gdeBRG0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let clientID = "client_id"
    static let redirectURIString = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")!
    static let unsplashGetTokenURLString = "https://unsplash.com/oauth/token"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
