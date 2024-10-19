//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 06.10.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
        ProgressHUD.mediaSize = 51
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
