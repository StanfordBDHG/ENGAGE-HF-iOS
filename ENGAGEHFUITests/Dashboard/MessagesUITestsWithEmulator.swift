//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class MessagesUITestsWithEmulator: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [
            "--assumeOnboardingComplete",
            "--setupTestEnvironment",
            "--useFirebaseEmulator"
        ]
        app.launch()
    }

    func testMessagesFromEmulator() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.otherElements["Message Card - Welcome"].waitForExistence(timeout: 2.0))
    }
}
