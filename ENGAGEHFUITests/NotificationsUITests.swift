//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class NotificationsUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--useFirebaseEmulator", "--setupTestEnvironment"]
        app.launch()
    }
    
    func testNotificationsLoaded() {
        let app = XCUIApplication()
        
        XCTAssert(app.buttons["Home"].waitForExistence(timeout: 2.0))
        app.buttons["Home"].tap()
        
        XCTAssert(app.staticTexts["MOCK NOTIFICATION 1"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["MOCK NOTIFICATION 2"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["MOCK NOTIFICATION 3"].waitForExistence(timeout: 2.0))
        
        XCTAssert(app.buttons["Show more"].firstMatch.waitForExistence(timeout: 2.0))
        let showMoreButton = app.buttons["Show more"].firstMatch
        showMoreButton.tap()
        
        XCTAssert(app.buttons["Show less"].firstMatch.waitForExistence(timeout: 2.0))
        let showLessButton = app.buttons["Show less"].firstMatch
        showLessButton.tap()
        
        // If "show more" appears again, expandable texts likely functions correctly
        XCTAssert(app.buttons["Show more"].firstMatch.waitForExistence(timeout: 2.0))
        
        
        XCTAssert(app.buttons["XButton"].firstMatch.waitForExistence(timeout: 2.0))
        app.buttons["XButton"].firstMatch.tap()
        
        XCTAssert(app.buttons["XButton"].firstMatch.waitForExistence(timeout: 2.0))
        app.buttons["XButton"].firstMatch.tap()
        
        XCTAssert(app.buttons["XButton"].firstMatch.waitForExistence(timeout: 2.0))
        app.buttons["XButton"].firstMatch.tap()
        
        // All the notifications are dismissed, so notifications section should no longer exist
        XCTAssertFalse(app.staticTexts["Notifications"].waitForExistence(timeout: 2.0))
    }
}
