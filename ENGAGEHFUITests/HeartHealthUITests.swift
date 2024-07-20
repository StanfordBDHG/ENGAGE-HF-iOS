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
            "--useFirebaseEmulator"
        ]
        app.launch()
    }
    
    func testEmptyHeartHealth() throws {
        let app = XCUIApplication()
        
        // Make sure we're on the Heart Health view
        XCTAssert(app.buttons["Heart Health"].waitForExistence(timeout: 1.0))
        app.buttons["Heart Health"].tap()
        XCTAssert(app.staticTexts["Heart Health"].waitForExistence(timeout: 1.0))
        
        try app.testEmptySymptomScores()
        try app.testEmptyVitals(for: "Body Weight", pickerLabel: "Weight")
        try app.testEmptyVitals(for: "Heart Rate", pickerLabel: "HR")
        try app.testEmptyVitals(for: "Blood Pressure", pickerLabel: "BP")
    }
}


extension XCUIApplication {
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
