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
        
        let expectedWeight = Locale.current.measurementSystem == .us ? "92.6" : "42"
        let weightUnit = Locale.current.measurementSystem == .us ? "lb" : "kg"
        
        // Make sure we're on the Heart Health view
        try app.goTo(tab: "Heart Health")
        
        // Clear out any data present before continuing
        try app.deleteAllMeasurements("Weight", header: "Body Weight", expectedDate: "Jun 5, 2024")
        try app.deleteAllMeasurements("HR", header: "Heart Rate", expectedDate: "Jun 5, 2024")
        try app.deleteAllMeasurements("BP", header: "Blood Pressure", expectedDate: "Jun 5, 2024")
        
        try app.testAllEmptyViews()
        
        // Add mock vitals to the user's collections in firestore
        try app.goTo(tab: "Home")
        try app.triggerMockMeasurement("Weight", expect: ["42 kg"])
        try app.triggerMockMeasurement("Blood Pressure", expect: ["103/64 mmHg", "62 BPM"])
        try app.goTo(tab: "Heart Health")
        
        // Make sure the graphs displayed
        try app.testHeartHealthWithHKSamples(expectedWeight: expectedWeight, weightUnit: weightUnit)
        
        try app.deleteAllMeasurements("Weight", header: "Body Weight", expectedDate: "Jun 5, 2024")
        try app.deleteAllMeasurements("HR", header: "Heart Rate", expectedDate: "Jun 5, 2024")
        try app.deleteAllMeasurements("BP", header: "Blood Pressure", expectedDate: "Jun 5, 2024")
        
        // Make sure the views are empty again
        try app.testAllEmptyViews()
    }
}


extension XCUIApplication {
    fileprivate func testHeartHealthWithHKSamples(expectedWeight: String, weightUnit: String) throws {
        let now = Date()
        let calendar = Calendar.current
        
        let weeklyDomainStart = try XCTUnwrap(calendar.date(byAdding: .month, value: -3, to: now))
        let weekRangeStart = try XCTUnwrap(calendar.dateInterval(of: .weekOfYear, for: weeklyDomainStart)?.start)
        let weekRangeEnd = try XCTUnwrap(calendar.dateInterval(of: .weekOfYear, for: now)?.end)
        let adjustedWeekRangeEnd = weekRangeEnd.addingTimeInterval(-1)
        
        let weeklyRange = (weekRangeStart..<adjustedWeekRangeEnd).formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
        
        let monthlyDomainStart = try XCTUnwrap(calendar.date(byAdding: .month, value: -6, to: now))
        let monthRangeStart = try XCTUnwrap(calendar.dateInterval(of: .month, for: monthlyDomainStart)?.start)
        let monthRangeEnd = try XCTUnwrap(calendar.dateInterval(of: .month, for: now)?.end)
        let adjustedMonthRangeEnd = monthRangeEnd.addingTimeInterval(-1)
        
        let monthlyRange = (monthRangeStart..<adjustedMonthRangeEnd).formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
        
        // Verify that each graph appears correctly
        for (resolution, expectedRange) in [("Weekly", weeklyRange), ("Monthly", monthlyRange)] {
            let pickerID = resolution == "Weekly" ? "Daily" : "Weekly"
            
            try testGraph(
                id: ("Weight", "Body Weight"),
                expectedQuantity: (expectedWeight, weightUnit),
                dateInfo: (resolution, expectedRange),
                pickerID: pickerID
            )
            try testGraph(
                id: ("HR", "Heart Rate"),
                expectedQuantity: ("62", "BPM"),
                dateInfo: (resolution, expectedRange),
                pickerID: pickerID
            )
            try testGraph(
                id: ("BP", "Blood Pressure"),
                expectedQuantity: ("103/64", "mmHg"),
                dateInfo: (resolution, expectedRange),
                pickerID: pickerID
            )
        }
    }
    
    
    fileprivate func testGraph(
        id: (short: String, full: String),
        expectedQuantity: (value: String, unit: String),
        dateInfo: (granularity: String, range: String),
        pickerID: String
    ) throws {
        // Make sure the vitals are correctly displayed
        try goTo(tab: id.short, header: id.full)
        
        // Make sure the measurement is displayed in "All Data" section
        XCTAssert(staticTexts["\(id.short) Quantity: \(expectedQuantity.value)"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(id.short) Unit: \(expectedQuantity.unit)"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(id.short) Date: Jun 5, 2024"].waitForExistence(timeout: 0.5))
        
        // Navigate to weekly data
        XCTAssert(buttons["Resolution Picker, \(pickerID)"].waitForExistence(timeout: 0.5))
        buttons["Resolution Picker, \(pickerID)"].tap()
        XCTAssert(buttons[dateInfo.granularity].waitForExistence(timeout: 0.5))
        buttons[dateInfo.granularity].tap()
        sleep(1)
        
        // Make sure the vitals graph is present
        XCTAssert(otherElements["Vitals Graph"].waitForExistence(timeout: 2.0))
        
        // Make sure the data appears in the list section
        XCTAssert(staticTexts["Average"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Overall Summary Quantity: \(expectedQuantity.value)"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Overall Summary Unit: \(expectedQuantity.unit)"].waitForExistence(timeout: 0.5))
        
        // Make sure the overall average appears correctly
        XCTAssert(staticTexts[dateInfo.range].waitForExistence(timeout: 0.5))
    }
    
    fileprivate func deleteAllMeasurements(_ id: String, header: String, expectedDate: String) throws {
        try goTo(tab: id, header: header)
        
        var dataPresent = !staticTexts["Empty \(id) List"].exists
        var totalRows = 0
        
        while dataPresent {
            swipeUp()
            staticTexts["\(id) Date: \(expectedDate)"].firstMatch.swipeLeft()
            if buttons["Delete"].waitForExistence(timeout: 0.5) {
                buttons["Delete"].tap()
            }
            
            dataPresent = !staticTexts["Empty \(id) List"].waitForExistence(timeout: 0.5)
            XCTAssert(totalRows < 10)
            totalRows += 1
        }
    }
    
    
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
