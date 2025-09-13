//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class MessagesUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--useFirebaseEmulator",
            "--setupTestEnvironment",
            "--setupTestMessages",
            "--setupTestVideos",
            "--testMockDevices"
        ]
        app.launch()
    }
    
    func testProcessingState() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        let moreButton = app.buttons["More"]
        XCTAssert(moreButton.waitForExistence(timeout: 0.5), "More button not found")
        moreButton.tap()
        
        XCTAssert(app.buttons["Trigger Blood Pressure Measurement"].waitForExistence(timeout: 0.5))
        app.buttons["Trigger Blood Pressure Measurement"].tap()
        
        // Verify measurements appear and save them
        XCTAssert(app.staticTexts["Measurement Recorded"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["103/64 mmHg"].exists)
        XCTAssert(app.staticTexts["62 BPM"].exists)
        
        app.buttons["Save"].tap()
        sleep(1)
        
        // Verify processing state appears on related message
        let vitalsMessage = app.otherElements["Message Card - Vitals"]
        XCTAssert(vitalsMessage.exists)
        XCTAssert(vitalsMessage.staticTexts["Processing 2 measurements..."].exists)
        
        // Start questionnaire
        let questionnaireMessage = app.otherElements["Message Card - Symptom Questionnaire"]
        XCTAssert(questionnaireMessage.exists)
        XCTAssert(questionnaireMessage.isHittable)
        
        questionnaireMessage.tap()
        sleep(1)
        
        // First submit to get to the form
        let submitButton = app.buttons["ORKContinueButton.Next"]
        XCTAssert(submitButton.waitForExistence(timeout: 0.5), "Initial submit button not found")
        submitButton.tap()
        
        // Fill out form using StaticText
        app.staticTexts["Yes"].tap()
        app.staticTexts["Vanilla"].tap()
        app.staticTexts["Sprinkles"].tap()
        
        // Final submit
        let finalSubmitButton = app.buttons["ORKContinueButton.Next"]
        XCTAssert(finalSubmitButton.waitForExistence(timeout: 0.5), "Final submit button not found")
        finalSubmitButton.tap()
        sleep(1)

        // Verify processing states are cleared
        XCTAssert(vitalsMessage.staticTexts["Processing 2 measurements..."].exists)
        XCTAssert(questionnaireMessage.staticTexts["Processing questionnaire..."].exists)
    }
    
    func testDismissMessages() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
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
        app.goTo(tab: "Home")
        XCTAssertFalse(app.otherElements["Message Card - Medication Uptitration"].exists)
        
        
        // Make sure the non-dismissible message is not dismissed on tap
        let vitalsMessage = app.otherElements["Message Card - Vitals"]
        XCTAssert(vitalsMessage.exists)
        XCTAssert(vitalsMessage.isHittable)
        
        vitalsMessage.tap()
        sleep(1)
        app.goTo(tab: "Home")
        XCTAssert(app.otherElements["Message Card - Vitals"].exists)
    }
    
    func testPlayVideoAction() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
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
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
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
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
        let medicationUptitrationMessage = app.otherElements["Message Card - Medication Uptitration"]
        XCTAssert(medicationUptitrationMessage.exists)
        XCTAssert(medicationUptitrationMessage.isHittable)
        
        medicationUptitrationMessage.tap()
        sleep(1)
        
        XCTAssert(app.staticTexts["Medications"].exists)
    }
    
    func testSeeHeartHealthAction() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
        let vitalsMessage = app.otherElements["Message Card - Vitals"]
        XCTAssert(vitalsMessage.exists)
        XCTAssert(vitalsMessage.isHittable)
        
        vitalsMessage.tap()
        sleep(1)
        
        XCTAssert(app.staticTexts["Heart Health"].exists)
    }
    
    func testUnsupportedAction() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
        let unknownActionMessage = app.otherElements["Message Card - Unknown"]
        XCTAssert(unknownActionMessage.exists)
        
        unknownActionMessage.tap()
        sleep(1)
        
        XCTAssert(app.otherElements["Message Card - Unknown"].exists)
    }
    
    func testMessagesAppear() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        app.goTo(tab: "Home")
        
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
