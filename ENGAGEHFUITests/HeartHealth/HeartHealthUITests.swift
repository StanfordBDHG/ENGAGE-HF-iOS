//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class HeartHealthUITests: XCTestCase {
    @MainActor
    override func setUp() async throws {
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
    
    func testSymptomScores() throws {
        let app = XCUIApplication()
        
        app.goTo(tab: "Heart Health")
        app.testEmptySymptomScores()
    }
    
    func testEmptyBodyWeight() throws {
        let app = XCUIApplication()
        
        // Clear out any data present before continuing
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        app.testEmptyVitals(for: "Body Weight", pickerLabel: "Weight")
    }
    
    func testEmptyHeartRate() throws {
        let app = XCUIApplication()
        
        // Clear out any data present before continuing
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        app.testEmptyVitals(for: "Heart Rate", pickerLabel: "HR")
    }
    
    func testEmptyBloodPressure() throws {
        let app = XCUIApplication()
        
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        app.testEmptyVitals(for: "Blood Pressure", pickerLabel: "BP")
    }
    
    func testWithWeightSample() throws {
        let app = XCUIApplication()
        
        let expectedWeight = Locale.current.measurementSystem == .us ? "92.6" : "42.0"
        let expectedUnit = Locale.current.measurementSystem == .us ? "lb" : "kg"
        
        // Start fresh
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        
        // Trigger a measurement
        app.goTo(tab: "Home")
        app.triggerMockMeasurement("Weight", expect: ["42 kg"])
        app.goTo(tab: "Heart Health")
        
        // Test to make sure the graph appears
        try app.testGraphWithSamples(
            id: ("Weight", "Body Weight"),
            expectedQuantity: (expectedWeight, expectedUnit)
        )
        
        // Test to make sure the All Data section has an item in it
        app.staticTexts["About Body Weight"].swipeUp()
        XCTAssertFalse(app.staticTexts["Empty Weight List"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Weight Quantity: \(expectedWeight)"].exists)
        XCTAssert(app.staticTexts["Weight Unit: \(expectedUnit)"].exists)
        XCTAssert(app.staticTexts["Weight Date: Jun 5, 2024"].exists)
        
        // Make sure the empty views return when we delete the data
        app.deleteAllMeasurements("Weight", header: "Body Weight")
        app.testEmptyVitals(for: "Body Weight", pickerLabel: "Weight")
    }
    
    func testWithHeartRateSample() throws {
        let app = XCUIApplication()

        // Start fresh
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        
        // Trigger a measurement
        app.goTo(tab: "Home")
        app.triggerMockMeasurement("Blood Pressure", expect: ["103/64 mmHg", "62 BPM"])
        app.goTo(tab: "Heart Health")
        
        // Test to make sure the graph appears
        try app.testGraphWithSamples(
            id: ("HR", "Heart Rate"),
            expectedQuantity: ("62", "BPM")
        )
        
        // Test to make sure the All Data section has an item in it
        app.staticTexts["About Heart Rate"].swipeUp()
        XCTAssertFalse(app.staticTexts["Empty HR List"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["HR Quantity: 62"].exists)
        XCTAssert(app.staticTexts["HR Unit: BPM"].exists)
        XCTAssert(app.staticTexts["HR Date: Jun 5, 2024"].exists)
        
        // Make sure the empty views return when we delete the data
        app.deleteAllMeasurements("HR", header: "Heart Rate")
        app.testEmptyVitals(for: "Heart Rate", pickerLabel: "HR")
    }
    
    func testWithBloodPressureSample() throws {
        let app = XCUIApplication()
        
        // Start fresh
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        
        // Trigger a measurement
        app.goTo(tab: "Home")
        app.triggerMockMeasurement("Blood Pressure", expect: ["103/64 mmHg", "62 BPM"])
        app.goTo(tab: "Heart Health")
        
        // Test to make sure the graph appears
        try app.testGraphWithSamples(
            id: ("BP", "Blood Pressure"),
            expectedQuantity: ("103/64", "mmHg")
        )
        
        // Test to make sure the All Data section has an item in it
        app.staticTexts["About Blood Pressure"].swipeUp()
        XCTAssertFalse(app.staticTexts["Empty BP List"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["BP Quantity: 103/64"].exists)
        XCTAssert(app.staticTexts["BP Unit: mmHg"].exists)
        XCTAssert(app.staticTexts["BP Date: Jun 5, 2024"].exists)
        
        // Make sure the empty views return when we delete the data
        app.deleteAllMeasurements("BP", header: "Blood Pressure")
        app.testEmptyVitals(for: "Blood Pressure", pickerLabel: "BP")
    }
}


extension XCUIApplication {
    private func getExpectedDateRanges() throws -> [String] {
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
        
        return [weeklyRange, monthlyRange]
    }
    
    
    fileprivate func testGraphWithSamples(
        id: (short: String, full: String),
        expectedQuantity: (value: String, unit: String)
    ) throws {
        let expectedRanges = try getExpectedDateRanges()
        
        // Verify that each graph appears correctly
        for (resolution, expectedRange) in zip(["Weekly", "Monthly"], expectedRanges) {
            let pickerID = resolution == "Weekly" ? "Daily" : "Weekly"
            
            testGraph(
                id: id,
                expectedQuantity: expectedQuantity,
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
    ) {
        // Make sure the vitals are correctly displayed
        goToHeartHealth(segment: id.short, header: id.full)
        
        staticTexts["About \(id.full)"].swipeUp()
        swipeUp()
        
        // Make sure the measurement is displayed in "All Data" section
        XCTAssert(staticTexts["\(id.short) Quantity: \(expectedQuantity.value)"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(id.short) Unit: \(expectedQuantity.unit)"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(id.short) Date: Jun 5, 2024"].waitForExistence(timeout: 0.5))
        
        swipeDown()
        swipeDown()
        
        // Navigate to weekly data
        XCTAssert(buttons["Resolution Picker, \(pickerID)"].waitForExistence(timeout: 0.5))
        buttons["Resolution Picker, \(pickerID)"].tap()
        XCTAssert(buttons[dateInfo.granularity].waitForExistence(timeout: 0.5))
        buttons[dateInfo.granularity].tap()
        sleep(1)
        
        // Make sure the vitals graph is present
        XCTAssert(otherElements["Vitals Graph"].waitForExistence(timeout: 2.0))
        
        // The following two assertions would make sure that the value is actually shown as the title of the
        // chart. Unfortunately, the test data is always from Jun 5, 2024 and the tests are run with the current time.
        // Therefore, the values will not actually be part of the chart at all and therefore, these assertions currently
        // fail.
        //
        // XCTAssert(staticTexts["Overall Summary Quantity: \(expectedQuantity.value)"].waitForExistence(timeout: 5.0))
        // XCTAssert(staticTexts["Overall Summary Unit: \(expectedQuantity.unit)"].waitForExistence(timeout: 5.0))
        
        // Make sure the overall average appears correctly
        XCTAssert(staticTexts[dateInfo.range].waitForExistence(timeout: 0.5))
    }
    
    
    func triggerMockMeasurement(_ displayName: String, expect measurements: [String]) {
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
}


extension XCUIApplication {
    fileprivate func testEmptyVitals(for vitalType: String, pickerLabel: String) {
        XCTAssert(buttons[pickerLabel].waitForExistence(timeout: 0.5))
        buttons[pickerLabel].tap()
                
        XCTAssert(staticTexts["Overall Summary Quantity: No Data"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["About \(vitalType)"].waitForExistence(timeout: 0.5))
        staticTexts["About \(vitalType)"].swipeUp()
        XCTAssert(staticTexts["\(vitalType) Description"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["Empty \(pickerLabel) List"].waitForExistence(timeout: 0.5))
        swipeDown()
    }
    
    fileprivate func testEmptySymptomScores() {
        XCTAssert(buttons["Symptoms"].firstMatch.waitForExistence(timeout: 0.5))
        buttons["Symptoms"].firstMatch.tap()
        
        let symptomTypes = [
            "Overall",
            "Physical Limits",
            "Social Limits",
            "Quality of Life",
            "Symptom Frequency",
            "Dizziness"
        ]
        let symptomLabels = [
            "Overall",
            "Physical",
            "Social",
            "Quality of Life",
            "Symptoms",
            "Dizziness"
        ]
        
        let numTypes = symptomTypes.count
        
        // Iterate over each symptom type and check that each is empty
        for idx in 0..<numTypes {
            let nextIdx = (idx + 1) % numTypes
            
            XCTAssert(buttons["\(symptomTypes[idx]) Score, Symptoms Picker Chevron"].waitForExistence(timeout: 0.5))
            images["Symptoms Picker Chevron"].tap()
            
            XCTAssert(buttons["\(symptomLabels[nextIdx])"].firstMatch.waitForExistence(timeout: 0.5))
            buttons["\(symptomLabels[nextIdx])"].firstMatch.tap()
            
            testEmptyForSpecificType(scoreType: symptomTypes[nextIdx])
        }
    }
    
    private func testEmptyForSpecificType(scoreType: String) {
        XCTAssert(staticTexts["Overall Summary Quantity: No Data"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(scoreType) Score Description"].waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["About \(scoreType) Score"].waitForExistence(timeout: 0.5))
        staticTexts["About \(scoreType) Score"].swipeUp()
        XCTAssert(staticTexts["Empty Symptoms List"].waitForExistence(timeout: 0.5))
        swipeDown()
    }
}
