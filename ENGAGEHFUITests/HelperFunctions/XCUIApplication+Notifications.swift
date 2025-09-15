//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCTestCase {
    @MainActor
    func addNotificatinosUIInterruptionMonitor() {
        addUIInterruptionMonitor(withDescription: "Notification permission requests.") { element -> Bool in
            let allowButton = element.buttons["Allow"].firstMatch
            if element.elementType == .alert && allowButton.exists {
                allowButton.tap()
                return true
            } else {
                return false
            }
        }
    }
}
