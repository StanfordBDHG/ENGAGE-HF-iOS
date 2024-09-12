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
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
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
        testedIndex: Int
    ) throws {
        // Get the initial values from each toggle
        var initialValues: [String] = []
        for idx in labels.indices {
            let toggle = switches[labels[idx]]
            XCTAssert(toggle.exists, "\(labels[idx]) toggle not found.")
            initialValues.append(try XCTUnwrap(toggle.value as? String, "Failed to unwrap initial \(labels[idx]) toggle value."))
        }
        
        let testedToggle = switches[labels[testedIndex]]
        XCTAssertTrue(testedToggle.exists)
        
        // Test toggling the toggle
        testedToggle.descendants(matching: .switch).firstMatch.tap()
    
        for idx in labels.indices {
            if idx == testedIndex {
                // Make sure the tapped toggle changed it's value
                let toggledValue = try XCTUnwrap(testedToggle.value as? String, "Failed to unwrap initial \(labels[idx]) toggle value.")
                let initialValue = initialValues[idx]
                XCTAssertNotEqual(
                    initialValue,
                    toggledValue,
                    "Toggled \(labels[idx]) but toggled value \(toggledValue) did not change from initial value \(initialValue)."
                )
            } else {
                // Make sure the other toggles did not change their values.
                let auxilliaryToggle = switches[labels[idx]]
                XCTAssert(auxilliaryToggle.exists)
                
                let toggledValue = try XCTUnwrap(auxilliaryToggle.value as? String, "Failed to unwrap value for \(labels[idx])")
                let initialValue = initialValues[idx]
                XCTAssertEqual(
                    toggledValue,
                    initialValues[idx],
                    "\(labels[idx]) toggle changed values from \(initialValue) to \(toggledValue) unexpectedly."
                )
            }
        }
        
        // Return the tested toggle to the initial state
        var count = 0
        let countLimit = 3
        let initialValue = initialValues[testedIndex]
        while try XCTUnwrap(testedToggle.value as? String, "Failed to unwrap toggle value for resetting.") != initialValue {
            testedToggle.descendants(matching: .switch).firstMatch.tap()
            
            XCTAssertLessThan(count, countLimit, "Failed to reset \(labels[testedIndex]) toggle to initial value \(initialValue)")
            count += 1
        }
    }
}
