//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func loadProfile()
    func loadAvatar()
    func didTapLogout()
    func logout()
}
