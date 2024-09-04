//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Tries to navigate to a tab by clicking on a button in the current view with label `tabName`
    func goTo(tab tabName: String) throws {
        XCTAssert(buttons[tabName].waitForExistence(timeout: 1.0), "No button found for tab \(tabName)")
        buttons[tabName].tap()
        swipeDown()
    }
}
