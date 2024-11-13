//
//  AuthHelperProtocol.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 08.11.2024.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
