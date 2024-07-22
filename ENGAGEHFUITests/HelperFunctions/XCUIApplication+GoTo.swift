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
    func goTo(tab tabName: String, header: String? = nil) throws {
        XCTAssert(buttons[tabName].waitForExistence(timeout: 1.0))
        buttons[tabName].tap()
        XCTAssert(staticTexts[header ?? tabName].waitForExistence(timeout: 1.0))
    }
}
