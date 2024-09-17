//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Attempts to delete all measurements of a given type by navigating to Heart Health view, then deleting the items in the All Data section of the page
    func deleteAllMeasurements(_ id: String, header: String) throws {
        try goTo(tab: "Heart Health")
        try goTo(tab: id, header: header)
        
        staticTexts["About \(header)"].swipeUp()
        
        var dataPresent = !staticTexts["Empty \(id) List"].exists
        var totalRows = 0
        
        while dataPresent {
            swipeUp()
            staticTexts["Measurement Row"].firstMatch.swipeLeft()
            if buttons["Delete"].waitForExistence(timeout: 0.5) {
                buttons["Delete"].tap()
            }
            
            dataPresent = !staticTexts["Empty \(id) List"].waitForExistence(timeout: 0.5)
            XCTAssert(totalRows < 10)
            totalRows += 1
        }
        
        swipeDown()
    }
}
