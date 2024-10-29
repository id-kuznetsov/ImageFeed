//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 09.10.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(_ alertModel: AlertModel)  {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
                alertModel.completion()
            }
        
        alert.addAction(action)
        
        if let cancelButtonText = alertModel.cancelButtonText {
            let cancelAction = UIAlertAction(
                title: cancelButtonText,
                style: .cancel
            ) { _ in
                alertModel.cancelCompletion?()
            }
            alert.addAction(cancelAction)
        }

        alert.view.accessibilityIdentifier = "alert"
        
        delegate?.showAlert(alert)
    }    
}
