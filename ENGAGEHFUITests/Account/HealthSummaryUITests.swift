//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class HealthSummaryUITests: XCTestCase {
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

    
    func testHealthSummaryView() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Home")
        
        XCTAssertTrue(app.navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        app.navigationBars.buttons["Your Account"].tap()
        
        XCTAssert(app.buttons["Health Summary"].waitForExistence(timeout: 0.5))
        app.buttons["Health Summary"].tap()
        
        XCTAssertTrue(app.segmentedControls.buttons["PDF"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["QR Code"].exists)
        
        XCTAssertTrue(app.navigationBars.buttons["Share Link"].waitForExistence(timeout: 5))
        
        app.segmentedControls.buttons["QR Code"].tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Share Link"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Health Summary QR Code"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["One-time Code"].waitForExistence(timeout: 2))
    }
}
