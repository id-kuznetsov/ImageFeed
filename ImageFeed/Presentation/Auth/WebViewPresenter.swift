//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Ilya Kuznetsov on 07.11.2024.
//

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {

    // MARK: - Public Properties
    
    weak var view: WebViewViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private let authHelper: AuthHelperProtocol
    
    // MARK: - Lifecycle
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        
        didUpdateProgressValue(0)
        
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
