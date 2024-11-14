//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func configProfileInfoCell(for cell: ProfileInfoCell, with profile: Profile, avatarURL: URL)
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int)
    func blockInteraction(_ state: Bool)
    func showExitAlert()
    func showError()
}
