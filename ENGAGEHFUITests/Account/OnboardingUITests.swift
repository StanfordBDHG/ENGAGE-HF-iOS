// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
// Based on: https://github.com/StanfordBDHG/PediatricAppleWatchStudy/pull/54/
//

import XCTest


final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        addUIInterruptionMonitor(withDescription: "Notification permission requests.") { element -> Bool in
            let allowButton = element.buttons["Allow"].firstMatch
            if element.elementType == .alert && allowButton.exists {
                allowButton.tap()
                return true
            } else {
                return false
            }
        }
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--useFirebaseEmulator"]
        app.launch()
    }
    
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        let email = "leland@stanford.edu"
        let password = "12345678"
        
        try app.navigateOnboardingFlow(email: email, password: password)
        app.assertOnboardingComplete()
        
        try app.assertAccountInformation(email: email)
    }
}


extension XCUIApplication {
    fileprivate func navigateOnboardingFlow(
        email: String,
        password: String,
        repeated skipOnRepeat: Bool = false
    ) throws {
        // Welcome
        try navigateWelcome()
        
        // Interesting Modules
        try navigateInterestingModules()
        
        // Account
        try navigateAccount(email: email, password: password)
        
        // Invitation Code
        try navigateInvitationCode(code: "PATIENT1")
        
        if !skipOnRepeat {
            // Notifications
            try navigateNotifications()
        }
    }
    
    private func navigateWelcome() throws {
        XCTAssert(staticTexts["Welcome to ENGAGE-HF"].waitForExistence(timeout: 5))
        
        XCTAssert(buttons["Learn More"].waitForExistence(timeout: 2))
        buttons["Learn More"].tap()
    }
    
    private func navigateInterestingModules() throws {
        XCTAssert(staticTexts["Key Features"].waitForExistence(timeout: 5))
        
        for _ in 0..<5 {
            XCTAssert(buttons["Next"].waitForExistence(timeout: 2) && buttons["Next"].isHittable)
            buttons["Next"].tap()
        }
    }
    
    private func navigateAccount(email: String, password: String) throws {
        XCTAssert(staticTexts["Your Account"].waitForExistence(timeout: 5))
        
        if buttons["Logout"].waitForExistence(timeout: 2.0) {
            buttons["Logout"].tap()
        }
        
        XCTAssert(buttons["Signup"].waitForExistence(timeout: 2) && buttons["Signup"].isHittable)
        buttons["Signup"].tap()
        
        try createAccount(email: email, password: password)
    }
    
    private func createAccount(email: String, password: String) throws {
        XCTAssert(staticTexts["Create a new Account"].waitForExistence(timeout: 5))
        
        // Add email
        XCTAssert(collectionViews.textFields["E-Mail Address"].exists)
        collectionViews.textFields["E-Mail Address"].tap()
        collectionViews.textFields["E-Mail Address"].typeText(email)
        
        // Add password
        XCTAssert(collectionViews.secureTextFields["Password"].exists)
        collectionViews.secureTextFields["Password"].tap()
        collectionViews.secureTextFields["Password"].typeText(password)
        
        // Sign up
        XCTAssert(collectionViews.buttons["Signup"].waitForExistence(timeout: 2)
                  && collectionViews.buttons["Signup"].isEnabled)
        collectionViews.buttons["Signup"].tap()
        
        sleep(3)
    }
    
    private func navigateInvitationCode(code: String) throws {
        XCTAssert(staticTexts["Invitation Code"].waitForExistence(timeout: 5))
        
        XCTAssert(textFields["Invitation Code"].exists)
        textFields["Invitation Code"].tap()
        textFields["Invitation Code"].typeText(code)
        
        XCTAssert(buttons["Redeem Invitation Code"].waitForExistence(timeout: 2)
                  && buttons["Redeem Invitation Code"].isEnabled)
        buttons["Redeem Invitation Code"].tap()
    }
    
    private func navigateNotifications() throws {
        XCTAssert(staticTexts["Notifications"].waitForExistence(timeout: 5))
        
        XCTAssert(buttons["Allow Notifications"].waitForExistence(timeout: 2))
        buttons["Allow Notifications"].tap()
        
        if !staticTexts["Home"].waitForExistence(timeout: 10) {
            XCTAssert(buttons["Skip"].waitForExistence(timeout: 0.5), "No skip notifications button.")
            buttons["Skip"].tap()
        }
    }
    
    fileprivate func assertOnboardingComplete() {
        let tabBar = tabBars["Tab Bar"]
                
        // Regression test: make sure the videos appeared correctly
        XCTAssert(tabBar.buttons["Education"].waitForExistence(timeout: 2))
        tabBar.buttons["Education"].tap()
        XCTAssertFalse(staticTexts["No Educational Videos"].exists)
        
        // Navigate back to home page
        XCTAssert(tabBar.buttons["Home"].waitForExistence(timeout: 0.5))
        tabBar.buttons["Home"].tap()
        
        XCTAssert(staticTexts["Home"].waitForExistence(timeout: 4))
    }
    
    fileprivate func assertAccountInformation(email: String) throws {
        XCTAssertTrue(navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        navigationBars.buttons["Your Account"].tap()
        
        XCTAssert(staticTexts["Account Overview"].waitForExistence(timeout: 5))
        XCTAssert(staticTexts[email].waitForExistence(timeout: 5))
        
        XCTAssertTrue(navigationBars.buttons["Close"].waitForExistence(timeout: 0.5))
        navigationBars.buttons["Close"].tap()

        XCTAssertTrue(navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        navigationBars.buttons["Your Account"].tap()
        
        XCTAssertTrue(navigationBars.buttons["Edit"].waitForExistence(timeout: 2))
        navigationBars.buttons["Edit"].tap()

        XCTAssertTrue(navigationBars.buttons["Cancel"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(navigationBars.buttons["Close"].exists)

        XCTAssertFalse(buttons["Delete Account"].exists)
        XCTAssertTrue(buttons["Logout"].exists)
    }
}
