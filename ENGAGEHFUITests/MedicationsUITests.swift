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
        app.images["Medication Label: improvementAvailable"].tap()
        
        let medicationDescription = app.staticTexts["You are eligible for a new dosage."]
        XCTAssert(medicationDescription.waitForExistence(timeout: 0.5))
        XCTAssert(medicationDescription.isHittable)
        
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: improvementAvailable"].tap()
        
        XCTAssertFalse(medicationDescription.waitForExistence(timeout: 0.5))
        XCTAssertFalse(medicationDescription.isHittable)
    }
    
    func testWithNoDosageInformation() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        XCTAssert(app.images["Medication Label: notStarted"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: notStarted"].tap()
        
        XCTAssertFalse(app.staticTexts["Current Dose:"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.staticTexts["Target Dose:"].waitForExistence(timeout: 0.5))
        XCTAssert(app.staticTexts["Not started yet. No action required."].waitForExistence(timeout: 0.5))
    }
    
    func testMultiIngredientDoseSummary() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        // Multi-ingredient, "twice daily"
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: improvementAvailable"].tap()
        
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
        app.images["Medication Label: personalTargetDoseReached"].tap()
        
        XCTAssert(app.staticTexts["2.5"].waitForExistence(timeout: 0.5), "First component of current dose not found.")
        XCTAssert(app.staticTexts["5"].waitForExistence(timeout: 0.5), "Second component of current dose not found.")
        XCTAssert(app.staticTexts["mg"].firstMatch.waitForExistence(timeout: 0.5), "Units not found.")
        XCTAssert(app.staticTexts["daily"].firstMatch.waitForExistence(timeout: 0.5), "\"Daily\" quantifier not found.")
    }
    
    func testMidRangeGauge() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        XCTAssert(app.images["Medication Label: personalTargetDoseReached"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: personalTargetDoseReached"].tap()
        
        let halfFilledGauge = app.otherElements["Current, Target"]
        XCTAssert(halfFilledGauge.waitForExistence(timeout: 0.5))
        XCTAssert(try XCTUnwrap(halfFilledGauge.value) as? String == "50%", "Value not correct in half filled gauge.")
    }
    
    func testLowRangeGauges() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: improvementAvailable"].tap()
        
        let emptyGauge = app.otherElements["Current, Target"]
        XCTAssert(emptyGauge.waitForExistence(timeout: 0.5))
        XCTAssert(try XCTUnwrap(emptyGauge.value) as? String == "0%", "Value not correct in empty gauge.")
        
        XCTAssert(app.images["Medication Label: improvementAvailable"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: improvementAvailable"].tap()
        
        XCTAssert(app.images["Medication Label: morePatientObservationsRequired"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: morePatientObservationsRequired"].tap()
        
        let lessThanEmptyGauge = app.otherElements["Current, Target"]
        XCTAssert(lessThanEmptyGauge.waitForExistence(timeout: 0.5))
        XCTAssert(try XCTUnwrap(lessThanEmptyGauge.value) as? String == "0%", "Value not correct in less than empty gauge.")
    }
    
    func testHighRangeGauge() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Medications")
        XCTAssert(app.buttons["More"].waitForExistence(timeout: 0.5), "No \"More\" Button Found.")
        app.buttons["More"].tap()
        
        XCTAssert(app.buttons["Add Medications"].waitForExistence(timeout: 0.5), "No \"Add Medications\" Button Found.")
        app.buttons["Add Medications"].tap()
        
        XCTAssert(app.images["Medication Label: targetDoseReached"].waitForExistence(timeout: 0.5))
        app.images["Medication Label: targetDoseReached"].tap()
        
        let fullGauge = app.otherElements["Current"]
        XCTAssert(fullGauge.waitForExistence(timeout: 0.5), "Full gauge not found.")
        XCTAssert(try XCTUnwrap(fullGauge.value) as? String == "100%", "Value not correct in full gauge.")
    }
}
