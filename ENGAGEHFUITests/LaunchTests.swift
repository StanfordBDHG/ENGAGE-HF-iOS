//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


// Based off of https://github.com/CS342/2024-Intake/blob/main/IntakeUITests/LaunchTests.swift
@MainActor
final class LaunchTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launch()
    }
    
    func testApplicationLaunch() throws {
        let app = XCUIApplication()
        XCTAssertEqual(app.state, .runningForeground)
    }
}
