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
    let cancelButtonText: String?
    let completion: () -> Void
    let cancelCompletion: (() -> Void)?
    
    init(
        title: String,
        message: String,
        buttonText: String,
        cancelButtonText: String? = nil,
        completion: @escaping () -> Void,
        cancelCompletion: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.cancelButtonText = cancelButtonText
        self.completion = completion
        self.cancelCompletion = cancelCompletion
    }
}
