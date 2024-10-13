//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 21.09.2024.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
