//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--assumeOnboardingComplete", "--setupTestEnvironment", "--useFirebaseEmulator"]
        app.launch()
    }

    func testInAppLogon() throws {
        let app = XCUIApplication()

        _ = app.staticTexts["Home"].waitForExistence(timeout: 10)

        XCTAssert(app.buttons["Home"].waitForExistence(timeout: 2.0))
        app.buttons["Home"].tap()


        XCTAssertTrue(app.navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        app.navigationBars.buttons["Your Account"].tap()

        XCTAssert(app.buttons["Logout"].waitForExistence(timeout: 2))
        app.buttons["Logout"].tap()

        let alert = "Are you sure you want to logout?"
        XCTAssert(app.alerts[alert].waitForExistence(timeout: 6.0))
        app.alerts[alert].buttons["Logout"].tap()

        XCTAssert(app.textFields["E-Mail Address"].waitForExistence(timeout: 10))
        try app.textFields["E-Mail Address"].enter(value: "test@engage.stanford.edu")

        XCTAssert(app.secureTextFields["Password"].waitForExistence(timeout: 2))
        try app.secureTextFields["Password"].enter(value: "123456789")

        XCTAssertTrue(app.buttons["Login"].waitForExistence(timeout: 0.5))
        app.buttons["Login"].tap()

        // ensure home view is in focus
        let tabBar = app.tabBars["Tab Bar"]
        XCTAssert(tabBar.buttons["Home"].waitForExistence(timeout: 2))
        tabBar.buttons["Home"].tap()
    }
    
    func testAddPhoneNumber() throws {
        let app = XCUIApplication()

        _ = app.staticTexts["Home"].waitForExistence(timeout: 10)

        XCTAssert(app.navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        app.navigationBars.buttons["Your Account"].tap()

        XCTAssertTrue(app.buttons["Phone Numbers"].exists)
        app.buttons["Phone Numbers"].tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Add Phone Number"].exists)
        app.navigationBars.buttons["Add Phone Number"].tap()
        
        let phoneNumber = "6502345678"
        let phoneField = app.textFields["Phone Number"]
        XCTAssertTrue(phoneField.exists)
        phoneField.tap()
        phoneField.typeText(phoneNumber)

        XCTAssert(app.buttons["Send Verification Message"].waitForExistence(timeout: 2))
        app.buttons["Send Verification Message"].tap()

        let otc = "012345"
        let codeField = app.textFields["Verification code entry"]
        XCTAssertTrue(codeField.waitForExistence(timeout: 2.0))
        
        for key in otc.enumerated() {
            app.keys["\(key.element)"].tap()
        }

        XCTAssertTrue(app.buttons["Verify Phone Number"].waitForExistence(timeout: 2))
        app.buttons["Verify Phone Number"].tap()
    }
}
