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
        
        XCTAssert(app.buttons["Show more"].waitForExistence(timeout: 2.0))
        let buttonContainer = app.descendants(matching: .any).containing(.button, identifier: "Show more").element(boundBy: 1)
        let showMoreButton = buttonContainer.buttons["Show more"]
        showMoreButton.tap()
        
        XCTAssert(buttonContainer.buttons["Show less"].waitForExistence(timeout: 2.0))
        let showLessButton = buttonContainer.buttons["Show less"]
        showLessButton.tap()
        
        // If "show more" appears again, expandable texts likely functions correctly
        XCTAssert(buttonContainer.buttons["Show more"].waitForExistence(timeout: 2.0))
        
        
        XCTAssert(app.buttons["XButton"].waitForExistence(timeout: 2.0))
        app.buttons["XButton"].tap()
        
        XCTAssert(app.buttons["XButton"].waitForExistence(timeout: 2.0))
        app.buttons["XButton"].tap()
        
        XCTAssert(app.buttons["XButton"].waitForExistence(timeout: 2.0))
        app.buttons["XButton"].tap()
        
        // All the notifications are dismissed, so notifications section should no longer exist
        XCTAssertFalse(app.staticTexts["Notifications"].waitForExistence(timeout: 2.0))
    }
}
