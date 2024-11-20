//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import XCTest

private enum personalData {
    static let email: String = "Paste your email here"
    static let password: String = "Paste your password here"
    static let name: String = "Paste your name here"
    static let login: String = "Paste your login here(@example)"
}

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(personalData.email)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText(personalData.password)
        
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["Like button"].tap()
        sleep(3)
        cellToLike.buttons["Like button"].tap()
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["Back button"].tap()
    }
    
    func testProfile() throws {
        sleep(1)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[personalData.name].exists)
        XCTAssertTrue(app.staticTexts[personalData.login].exists)
        
        
        app.buttons["Logout button"].tap()
        
        let alert = app.alerts["alert"]
        XCTAssertTrue(alert.exists)
        XCTAssertFalse(app.staticTexts[personalData.name].exists)
        XCTAssertFalse(app.staticTexts[personalData.login].exists)
        
        XCTAssertTrue(app.staticTexts["Пока, пока!"].exists)
        let yesButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(yesButton.exists)
        yesButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
