// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class HomeViewUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--setupTestEnvironment"]
        app.launch()
    }
    
    // Make sure the Dashboard view UI functions correctly
    func testDashboard() throws {
        let app = XCUIApplication()
        
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
