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
            "--setupTestEnvironment",
            "--testMockDevices",
            "--useFirebaseEmulator"
        ]
        app.launch()
    }
    
    func testHeartHealth() throws {
        let app = XCUIApplication()
        
        sleep(2)
        
        // Make sure we're on the Heart Health view
        try app.goTo(tab: "Heart Health")
        
        // There should not be any data displayed at first
        try app.testAllEmptyViews()
        
        // Add mock vitals to the user's collections in firestore
        try app.goTo(tab: "Home")
        try app.triggerMockMeasurement("Weight", expect: ["42 kg"])
        try app.triggerMockMeasurement("Blood Pressure", expect: ["103/64 mmHg", "62 BPM"])
        try app.goTo(tab: "Heart Health")
        
        // Make sure the vitals are correctly displayed
        try app.goTo(tab: "Weight", header: "Body Weight")
        
        // Make sure the measurement is displayed in "All Data" section
        XCTAssert(app.staticTexts["Weight Quantity: 92.6"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Weight Unit: lb"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Weight Date: Jun 5, 2024"].waitForExistence(timeout: 0.5))
        
        // Navigate to weekly data
        XCTAssert(app.staticTexts["Empty Body Weight Graph"].waitForExistence(timeout: 0.5))
        XCTAssert(app.buttons["Resolution Picker, Daily"].waitForExistence(timeout: 0.5))
        app.buttons["Resolution Picker, Daily"].tap()
        XCTAssert(app.buttons["Weekly"].waitForExistence(timeout: 0.5))
        app.buttons["Weekly"].tap()
        sleep(1)
        
        // Make sure the vitals graph is present
        XCTAssert(app.otherElements["Vitals Graph"].waitForExistence(timeout: 2.0))
        
        // Make sure the data appears in the list section
        XCTAssert(app.staticTexts["Average"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Overall Summary Quantity: 92.6"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Overall Summary Unit: lb"].waitForExistence(timeout: 0.5))
        
        // Make sure the overall average appears correctly
        let now = Date()
        let calendar = Calendar.current
        let weeklyDomainStart = try XCTUnwrap(calendar.date(byAdding: .month, value: -3, to: now))
        let displayRangeStart = try XCTUnwrap(calendar.dateInterval(of: .weekOfYear, for: weeklyDomainStart)?.start)
        let displayRangeEnd = try XCTUnwrap(calendar.dateInterval(of: .weekOfYear, for: now)?.end)
        let adjustedDisplayRangeEnd = displayRangeEnd.addingTimeInterval(-1)
        
        let formattedRange = (displayRangeStart..<adjustedDisplayRangeEnd).formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
        
        XCTAssert(app.staticTexts[formattedRange].waitForExistence(timeout: 0.5))
    }
}


extension XCUIApplication {
    fileprivate func triggerMockMeasurement(_ displayName: String, expect measurements: [String]) throws {
        XCTAssert(navigationBars.buttons["More"].exists)
        navigationBars.buttons["More"].tap()
        
        XCTAssert(buttons["Trigger \(displayName) Measurement"].waitForExistence(timeout: 0.5))
        buttons["Trigger \(displayName) Measurement"].tap()
        
        XCTAssert(staticTexts["Measurement Recorded"].waitForExistence(timeout: 2.0))
        for vital in measurements {
            XCTAssert(staticTexts[vital].exists)
        }

        XCTAssert(buttons["Discard"].exists)
        XCTAssert(buttons["Save"].exists)

        buttons["Save"].tap()
        sleep(1)

        XCTAssertFalse(alerts.element.exists)
    }
    
    
    fileprivate func goTo(tab tabName: String, header: String? = nil) throws {
        XCTAssert(buttons[tabName].waitForExistence(timeout: 1.0))
        buttons[tabName].tap()
        XCTAssert(staticTexts[header ?? tabName].waitForExistence(timeout: 1.0))
    }
}


extension XCUIApplication {
    fileprivate func testAllEmptyViews() throws {
        try testEmptyVitals(for: "Body Weight", pickerLabel: "Weight")
        try testEmptyVitals(for: "Heart Rate", pickerLabel: "HR")
        try testEmptyVitals(for: "Blood Pressure", pickerLabel: "BP")
        try testEmptySymptomScores()
        // Should end at symptoms view with Overall symptoms
    }
    
    
    fileprivate func testEmptyVitals(for vitalType: String, pickerLabel: String) throws {
        XCTAssert(buttons[pickerLabel].waitForExistence(timeout: 0.5))
        buttons[pickerLabel].tap()
        
        XCTAssert(staticTexts[vitalType].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Empty \(vitalType) Graph"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["About \(vitalType)"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(vitalType) Description"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Empty \(pickerLabel) List"].waitForExistence(timeout: 0.5))
    }
    
    fileprivate func testEmptySymptomScores() throws {
        XCTAssert(buttons["Symptoms"].waitForExistence(timeout: 0.5))
        buttons["Symptoms"].tap()
        
        let symptomTypes = [
            "Overall",
            "Physical Limits",
            "Social Limits",
            "Quality of Life",
            "Specific Symptoms",
            "Dizziness"
        ]
        let symptomLabels = [
            "Overall",
            "Physical",
            "Social",
            "Quality",
            "Specific",
            "Dizziness"
        ]
        
        let numTypes = symptomTypes.count
        
        // Iterate over each symptom type and check that each is empty
        for idx in 0..<numTypes {
            let nextIdx = (idx + 1) % numTypes
            
            XCTAssert(buttons["\(symptomTypes[idx]) Score, Symptoms Picker Chevron"].waitForExistence(timeout: 0.5))
            images["Symptoms Picker Chevron"].tap()
            
            XCTAssert(buttons["\(symptomLabels[nextIdx])"].waitForExistence(timeout: 0.5))
            buttons["\(symptomLabels[nextIdx])"].tap()
            
            try testEmptyForSpecificType(scoreType: symptomTypes[nextIdx])
        }
    }
    
    private func testEmptyForSpecificType(scoreType: String) throws {
        XCTAssert(staticTexts["Empty Symptoms Graph"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(scoreType) Score Description"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["About \(scoreType) Score"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Empty Symptoms List"].waitForExistence(timeout: 0.5))
    }
}
