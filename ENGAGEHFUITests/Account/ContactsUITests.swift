//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class ContactsUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--setupTestEnvironment",
            "--setupTestUserMetaData",
            "--useFirebaseEmulator"
        ]
        app.launch()
    }

    
    func testContactsView() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Home")
        
        XCTAssertTrue(app.navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        app.navigationBars.buttons["Your Account"].tap()
        
        XCTAssert(app.buttons["Contacts"].waitForExistence(timeout: 0.5))
        app.buttons["Contacts"].tap()
        
        XCTAssert(app.navigationBars.staticTexts["Contacts"].exists)
        XCTAssertFalse(app.staticTexts["No Contacts Available"].exists)
        XCTAssert(app.staticTexts["Contact: Leland Stanford Jr."].exists)
        XCTAssert(app.staticTexts["Site Lead at Stanford University"].exists)
    }
}
