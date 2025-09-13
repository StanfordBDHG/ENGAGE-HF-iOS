// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class HomeViewUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--setupTestEnvironment"]
        app.launch()
        
                try await Task.sleep(for: .seconds(2))
        
        addNotificatinosUIInterruptionMonitor()
    }
    
    // Make sure the Dashboard view UI functions correctly
    func testDashboard() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        // Test Home tab button
        XCTAssert(app.buttons["Home"].exists)
        app.buttons["Home"].tap()
        
        // Make sure greeting and title appear, indicating we're in the correct view
        XCTAssert(app.staticTexts["Home"].exists)
        
        // Firebase not disabled, so make sure the account button appears and is hittable
        XCTAssert(app.buttons["Your Account"].exists && app.buttons["Your Account"].isHittable)
        app.buttons["Your Account"].tap()
    }
}
