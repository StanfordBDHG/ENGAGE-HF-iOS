//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class AddMeasurementUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--setupTestEnvironment", "--useFirebaseEmulator"]
        app.launch()
    }

    func testAddingBodyWeight() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Heart Health")
        
        let expectedUnit = Locale.current.measurementSystem == .us ? "lb" : "kg"
        let inputs = [(expectedUnit, "100")]
        let expectedQuantity = "100.0"
        
        try app.testAddMeasurement(
            id: ("Weight", "Body Weight"),
            inputs: inputs,
            expectedQuantity: (expectedQuantity, expectedUnit)
        )
    }
    
    func testAddingHeartRate() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Heart Health")
        
        let expectedUnit = "BPM"
        let inputs = [(expectedUnit, "60")]
        let expectedQuantity = ("60", expectedUnit)
        
        try app.testAddMeasurement(
            id: ("HR", "Heart Rate"),
            inputs: inputs,
            expectedQuantity: expectedQuantity
        )
    }
    
    func testAddingBloodPressure() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Heart Health")
        
        let inputs = [("Systolic", "120"), ("Diastolic", "60")]
        let expectedQuantity = ("120/60", "mmHg")
        
        try app.testAddMeasurement(
            id: ("BP", "Blood Pressure"),
            inputs: inputs,
            expectedQuantity: expectedQuantity
        )
    }
    
    func testSymptomsAddingDisabled() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Heart Health")
        try app.goTo(tab: "Symptoms", header: "Overall Score")
        
        XCTAssertFalse(app.buttons["Add Measurement: Symptom Score"].exists)
    }
}


extension XCUIApplication {
    fileprivate func testAddMeasurement(
        id: (short: String, full: String),
        inputs: [(label: String, value: String)],
        expectedQuantity: (value: String, unit: String)
    ) throws {
        try goTo(tab: id.short, header: id.full)
        
        buttons["Add Measurement: \(id.short)"].tap()
        XCTAssert(staticTexts[id.full].waitForExistence(timeout: 0.5))
        XCTAssert(buttons["Cancel"].exists)
        
        let addButton = buttons["Add"]
        XCTAssert(addButton.exists && !addButton.isEnabled)
        
        for (count, input) in inputs.enumerated() {
            XCTAssert(staticTexts[input.label].exists)
            
            let inputField = textFields["Input: \(input.label)"]
            XCTAssert(inputField.exists)
            inputField.tap()
            inputField.typeText(input.value)
            
            // Add button shouldn't be enabled until all fields are full
            if count < inputs.count - 1 {
                XCTAssertFalse(addButton.isEnabled)
            }
        }
        
        XCTAssert(addButton.isEnabled)
        addButton.tap()
        
        swipeUp()
        
        let currentDate = Date().formatted(date: .abbreviated, time: .omitted)
        XCTAssert(staticTexts["\(id.short) Date: \(currentDate)"].firstMatch.waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(id.short) Unit: \(expectedQuantity.unit)"].firstMatch.waitForExistence(timeout: 0.5))
        XCTAssert(staticTexts["\(id.short) Quantity: \(expectedQuantity.value)"].firstMatch.waitForExistence(timeout: 0.5))
    }
}
