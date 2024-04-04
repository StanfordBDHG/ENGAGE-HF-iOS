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
    
    // Make sure the Dashboard view UI functions correctly
    func testDashboard() throws {
        let app = XCUIApplication()
        let tabBar = app.tabBars["Tab Bar"]
        
        // Test Home tab button
        XCTAssert(tabBar.buttons["Home"].exists)
        tabBar.buttons["Home"].tap()
        
        // Make sure greeting and title appear, indicating we're in the correct view
        XCTAssert(app.staticTexts["DASHBOARD_GREETING"].exists)
        XCTAssert(app.staticTexts["ENGAGE-HF: Home"].exists)
        
        // Make sure the date appears
        XCTAssert(app.staticTexts["DASHBOARD_DATE"].exists)
        
        // Todo: Test to make sure the date is correct
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        XCTAssertEqual(app.staticTexts["DASHBOARD_DATE"].label, dateFormatter.string(from: currentDate))
        
        // Make sure the account button appears and is hittable
        XCTAssert(app.buttons["DASHBOARD_ACC_BTN"].exists && app.buttons["DASHBOARD_ACC_BTN"].isHittable)
    }
    
    // Test the Heart Health View
    func testHeartHealth() throws {
        let app = XCUIApplication()
        let tabBar = app.tabBars["Tab Bar"]
        
        // Make sure the Heart Health tab button appears and takes us to correct screen
        XCTAssert(tabBar.buttons["Heart Health"].exists)
        tabBar.buttons["Heart Health"].tap()
        
        // Make sure filler text appears
        XCTAssert(app.staticTexts["HH"].exists)
    }
    
    // Test the Medications view
    func testMedications() throws {
        let app = XCUIApplication()
        let tabBar = app.tabBars["Tab Bar"]
        
        // Make sure the Medications tab button appears and takes us to the correct screen
        XCTAssert(tabBar.buttons["Medications"].exists)
        tabBar.buttons["Medications"].tap()
        
        // Make sure the filler text appears
        XCTAssert(app.staticTexts["MED"].exists)
    }
    
    // Test the Education view
    func testEducation() throws {
        let app = XCUIApplication()
        let tabBar = app.tabBars["Tab Bar"]
        
        // Make sure the Education tab button appears and takes us to the correct screen
        XCTAssert(tabBar.buttons["Education"].exists)
        tabBar.buttons["Education"].tap()
        
        // Make sure the filler text appears
        XCTAssert(app.staticTexts["EDU"].exists)
    }
}
