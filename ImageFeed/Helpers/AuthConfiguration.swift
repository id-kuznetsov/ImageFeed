//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 19.09.2024.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let getTokenURLString: String
    let authURLString: String
    
    static var standard: AuthConfiguration {
        .init(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            getTokenURLString: Constants.unsplashGetTokenURLString,
            authURLString: Constants.unsplashAuthorizeURLString
        )
    }
}
