//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class RecentVitalsUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testMockDevices", "--setupTestEnvironment", "--useFirebaseEmulator"]
        app.launch()
    }

    func testWeight() throws {
        let app = XCUIApplication()
        
        let expectedWeight = Locale.current.measurementSystem == .us ? "92.6" : "42"
        let weightUnit = Locale.current.measurementSystem == .us ? "lb" : "kg"
        
        // Make sure we're on the home screen
        XCTAssert(app.buttons["Home"].waitForExistence(timeout: 2.0))
        app.buttons["Home"].tap()
        
        XCTAssert(app.navigationBars.buttons["More"].exists)
        app.navigationBars.buttons["More"].tap()

        
        // Trigger a mock weight measurement
        XCTAssert(app.buttons["Trigger Weight Measurement"].waitForExistence(timeout: 0.5))
        app.buttons["Trigger Weight Measurement"].tap()
        
        XCTAssert(app.staticTexts["Measurement Recorded"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["42 kg"].exists)

        XCTAssert(app.buttons["Discard"].exists)
        XCTAssert(app.buttons["Save"].exists)

        app.buttons["Save"].tap()
        sleep(1)

        XCTAssertFalse(app.alerts.element.exists)
        
        
        // Weight measurement has been successfully saved, and should be represented in the dashboard
        XCTAssert(app.staticTexts["Recent Vitals"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Weight Quantity: \(expectedWeight)"].exists)
        XCTAssert(app.staticTexts["Weight Unit: \(weightUnit)"].exists)
        XCTAssert(app.staticTexts["Weight Date: 6/5/2024, 12:33 PM"].exists)
    }
    
    func testHeartRateAndBloodPressure() throws {
        let app = XCUIApplication()
        
        // Make sure we're on the home screen
        XCTAssert(app.buttons["Home"].waitForExistence(timeout: 2.0))
        app.buttons["Home"].tap()
        
        XCTAssert(app.navigationBars.buttons["More"].exists)
        app.navigationBars.buttons["More"].tap()

        
        // Trigger a mock blood pressure measurement
        XCTAssert(app.buttons["Trigger Blood Pressure Measurement"].waitForExistence(timeout: 0.5))
        app.buttons["Trigger Blood Pressure Measurement"].tap()
        
        XCTAssert(app.staticTexts["Measurement Recorded"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["103/64 mmHg"].exists)
        XCTAssert(app.staticTexts["62 BPM"].exists)

        XCTAssert(app.buttons["Discard"].exists)
        XCTAssert(app.buttons["Save"].exists)

        app.buttons["Save"].tap()
        sleep(1)

        XCTAssertFalse(app.alerts.element.exists)
        
        
        // Measurement has been successfully saved, and should be represented in the dashboard
        XCTAssert(app.staticTexts["Recent Vitals"].waitForExistence(timeout: 0.5))
        
        XCTAssert(app.staticTexts["Heart Rate Quantity: 62"].exists)
        XCTAssert(app.staticTexts["Heart Rate Unit: BPM"].exists)
        XCTAssert(app.staticTexts["Heart Rate Date: 6/5/2024, 12:33 PM"].exists)
        
        XCTAssert(app.staticTexts["Blood Pressure Quantity: 103/64"].exists)
        XCTAssert(app.staticTexts["Blood Pressure Unit: mmHg"].exists)
        XCTAssert(app.staticTexts["Blood Pressure Date: 6/5/2024, 12:33 PM"].exists)
    }
}
