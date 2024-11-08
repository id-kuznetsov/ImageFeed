//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: URL)
    func showExitAlert()
}
