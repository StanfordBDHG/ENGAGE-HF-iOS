//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class MedicationsUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--setupTestEnvironment", "--useFirebaseEmulator", "--setupTestMedications"]
        app.launch()
    }
    
    
    func testMoreInformationButton() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Medications")
        
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        XCTAssert(app.images["Sacubitril-Valsartan More Information"].waitForExistence(timeout: 0.5))
        app.images["Sacubitril-Valsartan More Information"].tap()
        
        sleep(1)
        
        XCTAssert(app.buttons["Education"].exists)
    }
    
    func testEmptyMedications() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.staticTexts["No medication recommendations"].waitForExistence(timeout: 0.5))
    }
    
    func testMedicationCardExtension() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        
        let medicationDescription = app.staticTexts["You are eligible for a new dosage."]
        XCTAssert(medicationDescription.waitForExistence(timeout: 0.5))
        XCTAssert(medicationDescription.isHittable)
        XCTAssert(app.otherElements["Sacubitril-Valsartan Dosage Gauge"].waitForExistence(timeout: 0.5))
        
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: improvementAvailable"].tap()
        
        XCTAssertFalse(medicationDescription.waitForExistence(timeout: 0.5))
        XCTAssertFalse(medicationDescription.isHittable)
        XCTAssertFalse(app.otherElements["Sacubitril-Valsartan Dosage Gauge"].waitForExistence(timeout: 0.5))
    }
    
    func testWithEmptyCurrentSchedule() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        app.swipeUp()
        
        XCTAssert(app.images["Medication Label: notStarted"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Not Started"].waitForExistence(timeout: 0.5))
    }
    
    func testMultiIngredientDoseSummary() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        // Multi-ingredient, "twice daily"
        XCTAssert(app.staticTexts["Sacubitril-Valsartan Schedule Summary"].firstMatch.exists)
        
        XCTAssert(app.staticTexts["24/26"].waitForExistence(timeout: 0.5), "Multi-ingredient current dose not found.")
        XCTAssert(app.staticTexts["twice daily"].firstMatch.waitForExistence(timeout: 0.5), "\"Twice Daily\" current dose not found.")
        
        XCTAssert(app.staticTexts["97/103"].waitForExistence(timeout: 0.5), "Multi-ingredient target dose not found.")
    }
    
    func testMultiScheduleDoseSummary() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        // Single ingredient, multiple schedules, "daily"
        XCTAssert(app.images["Medication Label: personalTargetDoseReached"].waitForExistence(timeout: 0.5))
        
        XCTAssert(app.staticTexts["2.5"].waitForExistence(timeout: 0.5), "First component of current dose not found.")
        XCTAssert(app.staticTexts["5"].waitForExistence(timeout: 0.5), "Second component of current dose not found.")
        XCTAssert(app.staticTexts["mg"].firstMatch.waitForExistence(timeout: 0.5), "Units not found.")
        XCTAssert(app.staticTexts["daily"].firstMatch.waitForExistence(timeout: 0.5), "\"Daily\" quantifier not found.")
    }
    
    func testFrequencyStyling() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        // Once daily
        app.swipeUp()
        XCTAssert(app.images["Medication Label: targetDoseReached"].firstMatch.waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["daily"].firstMatch.waitForExistence(timeout: 0.5), "No \"daily\" quantifier found.")
        
        // Twice daily
        app.swipeDown()
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["twice daily"].firstMatch.waitForExistence(timeout: 0.5), "No \"twice daily\" quantifier found.")
        
        // Non-integer frequency
        XCTAssert(app.images["Medication Label: morePatientObservationsRequired"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["1.5x daily"].firstMatch.waitForExistence(timeout: 0.5), "No \"1.5x daily\" quantifier found.")
    }
    
    func testMidRangeGauge() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        app.swipeUp()
        
        let halfFilledGauge = app.otherElements["Empagliflozin Dosage Gauge"]
        XCTAssert(halfFilledGauge.waitForExistence(timeout: 0.5))
        XCTAssertEqual(halfFilledGauge.label, "Current, Target", "Label not correct in half filled gauge")
        XCTAssertEqual(try XCTUnwrap(halfFilledGauge.value) as? String, "75%", "Value not correct in half filled gauge.")
    }
    
    func testMinimumScheduleGauge() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        let minimalGauge = app.otherElements["Sacubitril-Valsartan Dosage Gauge"]
        XCTAssert(minimalGauge.waitForExistence(timeout: 0.5))
        XCTAssertEqual(minimalGauge.label, "Current, Target", "Label not correct in minimum schedule gauge.")
        XCTAssertEqual(try XCTUnwrap(minimalGauge.value) as? String, "25%", "Value not correct in minimum schedule gauge.")
    }
    
    func testEmptyGauge() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        let emptyGauge = app.otherElements["Spironolactone Dosage Gauge"]
        XCTAssert(emptyGauge.waitForExistence(timeout: 0.5))
        XCTAssertEqual(emptyGauge.label, "Current, Target", "Label not correct in empty gauge.")
        XCTAssertEqual(try XCTUnwrap(emptyGauge.value) as? String, "0%", "Value not correct in empty gauge.")
        
        // Make sure the app shows that the patient has not started the medication
        XCTAssert(app.staticTexts["Not Started"].exists)
    }
    
    func testHighRangeGauge() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        app.swipeUp()
        
        let fullGauge = app.otherElements["Carvedilol Dosage Gauge"]
        XCTAssert(fullGauge.waitForExistence(timeout: 0.5), "Full gauge not found.")
        XCTAssertEqual(fullGauge.label, "Current, Target", "Label not correct for full gauge.")
        XCTAssertEqual(try XCTUnwrap(fullGauge.value) as? String, "100%", "Value not correct in full gauge.")
    }
}
