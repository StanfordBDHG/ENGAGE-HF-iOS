//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Tries to navigate to a tab by clicking on a button in the current view with label "id", and verifies the correct arrival by looking for a header with label "header" or "id" if no header given.
    func goTo(tab tabName: String, header: String? = nil) {
        XCTAssert(buttons[tabName].waitForExistence(timeout: 6.0), "No button found for tab \(tabName)")
        buttons[tabName].tap()
        swipeDown()
        XCTAssert(staticTexts[header ?? tabName].waitForExistence(timeout: 1.0))
    }
    
    func goToHeartHealth(segment: String, header: String) {
        goTo(tab: "Heart Health")
        XCTAssert(buttons[segment].waitForExistence(timeout: 6.0), "No button found for segment \(segment)")
        buttons[segment].tap()
        staticTexts["About \(header)"].swipeDown()
        XCTAssert(staticTexts[header].waitForExistence(timeout: 1.0))
    }
}
