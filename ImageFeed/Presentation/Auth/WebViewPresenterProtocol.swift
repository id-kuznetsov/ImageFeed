//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 07.11.2024.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}
