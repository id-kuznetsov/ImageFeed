//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.10.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
