//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class NotificationSettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--setupTestEnvironment",
            "--setupTestUserMetaData",
            "--useFirebaseEmulator"
        ]
        app.launch()
    }

    func testNotificationSettings() throws {
        let app = XCUIApplication()
        
        try app.goTo(tab: "Home")
        
        XCTAssertTrue(app.navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        app.navigationBars.buttons["Your Account"].tap()
        
        XCTAssertTrue(app.buttons["Notifications"].waitForExistence(timeout: 0.5))
        app.buttons["Notifications"].tap()
        
        
        let allLabels = [
            "Appointments",
            "Survey",
            "Vitals",
            "Medications",
            "Recommendations",
            "Weight Trends"
        ]
        
        for idx in allLabels.indices {
            try app.validateSwitch(labels: allLabels, testedIndex: idx)
        }
    }
}


extension XCUIApplication {
    fileprivate func validateSwitch(
        labels: [String],
        testedIndex: Int,
        expectedInitialValue: String = "0",
        expectedToggledValue: String = "1"
    ) throws {
        let testedToggle = switches[labels[testedIndex]]
        
        // Make sure the toggle starts at the correct value
        XCTAssertTrue(testedToggle.exists)
        
        let discoveredInitialValue = try XCTUnwrap(testedToggle.value as? String, "Failed to unwrap toggle value.")
        XCTAssertEqual(
            discoveredInitialValue,
            expectedInitialValue,
            "\(labels[testedIndex]) toggle initialized to \(discoveredInitialValue) when it should be \(expectedInitialValue)."
        )
        
        // Make sure that tapping the toggle flips its value, but doesn't change any of the other toggles
        testedToggle.descendants(matching: .switch).firstMatch.tap()
        
        for idx in labels.indices {
            if idx == testedIndex {
                XCTAssertEqual(try XCTUnwrap(testedToggle.value as? String, "Failed to unwrap toggle value."), expectedToggledValue)
            } else {
                let auxilliaryToggle = switches[labels[idx]]
                XCTAssert(auxilliaryToggle.exists)
                XCTAssertEqual(try XCTUnwrap(auxilliaryToggle.value as? String, "Failed to unwrap toggle value."), expectedInitialValue)
            }
        }
        
        // Return the tested toggle to the initial state
        var count = 0
        let countLimit = 3
        while try XCTUnwrap(testedToggle.value as? String, "Failed to unwrap toggle value.") != expectedInitialValue, count < countLimit {
            testedToggle.descendants(matching: .switch).firstMatch.tap()
            XCTAssertLessThan(count, countLimit, "Failed to reset toggle to initial value \(expectedInitialValue)")
            
            count += 1
        }
    }
}
