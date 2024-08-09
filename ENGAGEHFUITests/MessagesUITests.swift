//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class MessagesUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--useFirebaseEmulator",
            "--setupTestEnvironment",
            "--setupTestMessages",
            "--setupTestVideos"
        ]
        app.launch()
    }
    
    func testDismissMessages() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        // Directly dismiss by tapping dismiss button
        let medicationChangeMessage = app.otherElements["Message Card - Medication Change"]
        XCTAssert(medicationChangeMessage.exists)
        
        medicationChangeMessage.buttons["Dismiss Button"].tap()
        sleep(1)
        XCTAssertFalse(app.otherElements["Message Card - Medication Change"].exists, "Tapped dismiss but message is still present.")
        
        
        // Indirectly dismiss by completing action
        let uptitrationMessage = app.otherElements["Message Card - Medication Uptitration"]
        XCTAssert(uptitrationMessage.exists)
        XCTAssert(uptitrationMessage.isHittable)
        
        uptitrationMessage.tap()
        sleep(1)
        try app.goTo(tab: "Home")
        XCTAssertFalse(app.otherElements["Message Card - Medication Uptitration"].exists)
        
        
        // Make sure the non-dismissible message is not dismissed on tap
        let vitalsMessage = app.otherElements["Message Card - Vitals"]
        XCTAssert(vitalsMessage.exists)
        XCTAssert(vitalsMessage.isHittable)
        
        vitalsMessage.tap()
        sleep(1)
        try app.goTo(tab: "Home")
        XCTAssert(app.otherElements["Message Card - Vitals"].exists)
    }
    
    func testPlayVideoAction() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        let medicationChangeMessage = app.otherElements["Message Card - Medication Change"]
        XCTAssert(medicationChangeMessage.exists)
        XCTAssert(medicationChangeMessage.isHittable)
        
        medicationChangeMessage.tap()
        sleep(1)
        
        // Make sure we arrive at the video player view
        XCTAssert(app.staticTexts["No Description"].exists)
        
        // Make sure we navigate back to education tab from video player view
        XCTAssert(app.buttons["Education"].exists)
        app.navigationBars.buttons["Education"].tap()
        XCTAssert(app.staticTexts["Education"].waitForExistence(timeout: 1))
    }
    
    func testCompleteQuestionnaireAction() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        let questionnaireMessage = app.otherElements["Message Card - Symptom Questionnaire"]
        XCTAssert(questionnaireMessage.exists)
        XCTAssert(questionnaireMessage.isHittable)
        
        questionnaireMessage.tap()
        sleep(1)
        
        XCTAssert(app.buttons["Cancel"].exists)
        XCTAssert(app.staticTexts["Form Example"].exists)
    }
    
    func testSeeMedicationsAction() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        let medicationUptitrationMessage = app.otherElements["Message Card - Medication Uptitration"]
        XCTAssert(medicationUptitrationMessage.exists)
        XCTAssert(medicationUptitrationMessage.isHittable)
        
        medicationUptitrationMessage.tap()
        sleep(1)
        
        XCTAssert(app.staticTexts["Medications"].exists)
    }
    
    func testSeeHeartHealthAction() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        let vitalsMessage = app.otherElements["Message Card - Vitals"]
        XCTAssert(vitalsMessage.exists)
        XCTAssert(vitalsMessage.isHittable)
        
        vitalsMessage.tap()
        sleep(1)
        
        XCTAssert(app.staticTexts["Heart Health"].exists)
    }
    
    func testUnsupportedAction() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        let unknownActionMessage = app.otherElements["Message Card - Unknown"]
        XCTAssert(unknownActionMessage.exists)
        
        unknownActionMessage.tap()
        sleep(1)
        
        XCTAssert(app.otherElements["Message Card - Unknown"].exists)
    }
    
    func testMessagesAppear() throws {
        let app = XCUIApplication()
        try app.goTo(tab: "Home")
        
        let medicationChangeMessage = app.otherElements["Message Card - Medication Change"]
        XCTAssert(medicationChangeMessage.exists)
        
        try validateMessageCard(
            card: medicationChangeMessage,
            expectedTitle: "Medication Change",
            expectedDescription: "Your medication has been changed. Watch the video for more information.",
            expectedAction: "Play Video",
            isDismissible: true
        )
        
        let uptitrationMessage = app.otherElements["Message Card - Medication Uptitration"]
        XCTAssert(uptitrationMessage.exists)
        
        try validateMessageCard(
            card: uptitrationMessage,
            expectedTitle: "Medication Uptitration",
            expectedDescription: nil,
            expectedAction: "See Medications",
            isDismissible: true
        )
        
        let vitalsMessage = app.otherElements["Message Card - Vitals"]
        XCTAssert(vitalsMessage.exists)
        
        try validateMessageCard(
            card: vitalsMessage,
            expectedTitle: "Vitals",
            expectedDescription: "Please take blood pressure and weight measurements.",
            expectedAction: "See Heart Health",
            isDismissible: false
        )
        
        let unknownMessage = app.otherElements["Message Card - Unknown"]
        XCTAssert(unknownMessage.exists)
        
        try validateMessageCard(
            card: unknownMessage,
            expectedTitle: "Unknown",
            expectedDescription: nil,
            expectedAction: "",
            isDismissible: false
        )
    }
    
    
    private func validateMessageCard(
        card: XCUIElement,
        expectedTitle: String,
        expectedDescription: String?,
        expectedAction: String,
        isDismissible: Bool
    ) throws {
        let expectedCardLabel = """
        Message: \(expectedTitle), \
        description: \(expectedDescription ?? "none"), \
        action: \(expectedAction).
        """
        XCTAssertEqual(expectedCardLabel, card.label)
        
        XCTAssert(card.images[expectedAction + " Symbol"].exists)
        XCTAssert(card.staticTexts[expectedTitle].exists)
        
        if !expectedAction.isEmpty {
            XCTAssert(card.staticTexts[expectedAction].exists)
        } else {
            XCTAssertFalse(card.staticTexts["Message Action"].exists)
        }
        
        if let expectedDescription {
            XCTAssert(card.staticTexts[expectedDescription].exists)
        } else {
            XCTAssertFalse(card.staticTexts["Message Description"].exists)
        }
        
        XCTAssertEqual(card.buttons["Dismiss Button"].exists, isDismissible)
    }
}
