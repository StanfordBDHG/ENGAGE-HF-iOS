//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class ContactsUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--setupTestEnvironment",
            "--setupTestUserMetaData",
            "--useFirebaseEmulator"
        ]
        app.launch()
        
        addNotificatinosUIInterruptionMonitor()
        
        try await Task.sleep(for: .seconds(2))
    }

    
    func testContactsView() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Home")
        
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
