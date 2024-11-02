//
//  AlertPresenterProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.10.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    static func showAlert(_ alertModel: AlertModel, delegate: AlertPresenterDelegate)
}
