//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class HeartHealthUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = [
            "--skipOnboarding",
            "--setupTestingEnvironment",
            "--testMockDevices",
            "--useFirebaseEmulator",
            "--setupMockVitals"
        ]
        app.launch()
    }

    func testEmptyViews() throws {
        let app = XCUIApplication()
        
        // Make sure we're on the Heart Health view
        XCTAssert(app.buttons["Heart Health"].waitForExistence(timeout: 2.0))
        app.buttons["Heart Health"].tap()
        XCTAssert(app.staticTexts["Heart Health"].waitForExistence(timeout: 1.0))
        
        XCTAssert(app.staticTexts["No recent symptom scores available."].waitForExistence(timeout: 1.0))
        XCTAssert(app.staticTexts["Overall Score Description"].waitForExistence(timeout: 1.0))
        XCTAssert(app.staticTexts["About Overall Score"].waitForExistence(timeout: 1.0))
        XCTAssert(app.staticTexts["Empty Symptoms"].waitForExistence(timeout: 1.0))
        
        
    }
    
    private func testEmptySymptoms() throws {
        
    }
}
