// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  HomeViewUITests.swift
//  ENGAGEHFUITests
//
//  Created by Nick Riedman on 4/3/24.
//

import XCTest

class HomeViewUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--disableFirebase"]
        app.launch()
    }
    
    // Make sure the correct tabs show and that they go to the correct view
    func testHomeTabs() throws {
        let app = XCUIApplication()
        
        XCTAssertEqual(app.state, .runningForeground)
        XCTAssertEqual(app.tabs["Home"].label, "Home")
        app.tabs["Home"].tap()
        app.tabs["Home"].tap()
        
        XCTAssertEqual(app.tabs["Heart Health"].label, "Heart Health")
        app.tabs["Heart Health"].tap()
        app.tabs["Heart Health"].tap()
        
        XCTAssertEqual(app.tabs["Medications"].label, "Medications")
        app.tabs["Medications"].tap()
        app.tabs["Medications"].tap()
        
        XCTAssertEqual(app.tabs["Education"].label, "Education")
        app.tabs["Education"].tap()
        app.tabs["Education"].tap()
    }
}
