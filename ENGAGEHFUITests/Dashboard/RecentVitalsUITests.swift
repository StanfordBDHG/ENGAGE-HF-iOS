//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest


@MainActor
final class RecentVitalsUITests: XCTestCase {
    private var expectedFormattedMeasurementDate: String {
        let expectedDateComponents = DateComponents(year: 2024, month: 6, day: 5, hour: 12, minute: 33, second: 11)
        let expectedDate = Calendar.current.date(from: expectedDateComponents) ?? .now
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy, h:mm a"
        return formatter.string(from: expectedDate)
    }
    
    
    override func setUp() async throws {
        try await super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testMockDevices", "--setupTestEnvironment", "--useFirebaseEmulator"]
        app.launch()
    }

    func testWeight() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        let expectedWeight = Locale.current.measurementSystem == .us ? "92.6" : "42.0"
        let weightUnit = Locale.current.measurementSystem == .us ? "lb" : "kg"
        
        // Delete all previous measurements
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        
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
        XCTAssert(app.staticTexts["Weight Date: \(expectedFormattedMeasurementDate)"].exists)
        
        app.staticTexts["Weight Quantity: \(expectedWeight)"].tap()
        XCTAssert(app.staticTexts["Body Weight"].waitForExistence(timeout: 2.0))
    }
    
    func testHeartRateAndBloodPressure() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        // Delete previous measurements
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        
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
        XCTAssert(app.staticTexts["Recent Vitals"].waitForExistence(timeout: 2.0))
        
        let heartRateQuantityText = "Heart Rate Quantity: 62"
        XCTAssert(app.staticTexts[heartRateQuantityText].exists)
        XCTAssert(app.staticTexts["Heart Rate Unit: BPM"].exists)
        XCTAssert(app.staticTexts["Heart Rate Date: \(expectedFormattedMeasurementDate)"].exists)
        
        app.staticTexts[heartRateQuantityText].tap()
        XCTAssert(app.staticTexts["Heart Rate"].waitForExistence(timeout: 2.0))
        
        app.goTo(tab: "Home")
        XCTAssert(app.staticTexts["Recent Vitals"].waitForExistence(timeout: 2.0))
        
        let bloodPressureQuantityText = "Blood Pressure Quantity: 103/64"
        XCTAssert(app.staticTexts[bloodPressureQuantityText].exists)
        XCTAssert(app.staticTexts["Blood Pressure Unit: mmHg"].exists)
        XCTAssert(app.staticTexts["Blood Pressure Date: \(expectedFormattedMeasurementDate)"].exists)
        
        app.staticTexts[bloodPressureQuantityText].tap()
        XCTAssert(app.staticTexts["Blood Pressure"].waitForExistence(timeout: 2.0))
    }
}
