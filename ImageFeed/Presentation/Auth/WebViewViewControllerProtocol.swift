//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 07.11.2024.
//

import Foundation

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
