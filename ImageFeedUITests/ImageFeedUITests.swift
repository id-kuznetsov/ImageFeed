//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Ilya Kuznetsov on 10.11.2024.
//

import XCTest

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
        loginTextField.typeText("Paste your email here")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("Paste your password here")
        
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
        
        XCTAssertTrue(app.staticTexts["Paste your name here"].exists)
        XCTAssertTrue(app.staticTexts["Paste your login here(@example)"].exists)
        
        
        app.buttons["Logout button"].tap()
        
        let alert = app.alerts["alert"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(app.staticTexts["Пока, пока!"].exists)
        let yesButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(yesButton.exists)
        yesButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        
        
    }
}
