//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class BloodPressureCuffTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--testMockDevices", "--setupTestEnvironment"]
        app.launch()
    }


    func testReceiveMeasurement() throws {
        let app = XCUIApplication()


        XCTAssert(app.buttons["Home"].waitForExistence(timeout: 2.0))
        app.buttons["Home"].tap()


        XCTAssert(app.navigationBars.buttons["More"].exists)
        app.navigationBars.buttons["More"].tap()


        XCTAssert(app.buttons["Trigger Blood Pressure Measurement"].waitForExistence(timeout: 0.5))
        app.buttons["Trigger Blood Pressure Measurement"].tap()

        XCTAssert(app.staticTexts["Measurement Recorded"].waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["103/64 mmHg"].exists)
        XCTAssert(app.staticTexts["62 BPM"].exists)

        XCTAssert(app.buttons["Discard"].exists)
        XCTAssert(app.buttons["Save"].exists)

        app.buttons["Save"].tap()
        sleep(6)

        // We currently consider the test to be successful give that there wasn't any error saving the measurement to firestore.
        // Additional assertions can be added once the UI PR is merged and data is actually displayed in the app.
        XCTAssertFalse(app.alerts.element.exists)
    }
}
