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
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--useFirebaseEmulator"]
        app.launch()
    }
    
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        let email = "leland@stanford.edu"
        
        try app.navigateOnboardingFlow(email: email)
        app.assertOnboardingComplete()
        
        try app.assertAccountInformation(email: email)
    }
}


extension XCUIApplication {
    fileprivate func navigateOnboardingFlow(
        email: String = "leland@stanford.edu",
        repeated skipOnRepeat: Bool = false
    ) throws {
        // Welcome
        try navigateWelcome()
        
        // Interesting Modules
        try navigateInterestingModules()
        
        // Invitation Code
        try navigateInvitationCode(code: "ENGAGETEST2")
        
        // Account
        if staticTexts["Your Account"].waitForExistence(timeout: 5) {
            try navigateAccount(email: email)
        }
        
        // Consent
        if staticTexts["Consent"].waitForExistence(timeout: 5) {
            try navigateConsent()
        }
        
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
        XCTAssert(staticTexts["Interesting Modules"].waitForExistence(timeout: 5))
        
        for _ in 0..<5 {
            XCTAssert(buttons["Next"].waitForExistence(timeout: 2) && buttons["Next"].isHittable)
            buttons["Next"].tap()
        }
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
    
    private func navigateAccount(email: String) throws {
        XCTAssert(staticTexts["Your Account"].waitForExistence(timeout: 5))
        
        if buttons["Logout"].waitForExistence(timeout: 2.0) {
            buttons["Logout"].tap()
        }
        
        XCTAssert(buttons["Signup"].waitForExistence(timeout: 2) && buttons["Signup"].isHittable)
        buttons["Signup"].tap()
        
        try createAccount(email: email)
        
        // Finish Account Setup: Will possibly be removed
        XCTAssert(staticTexts["Finish Account Setup"].waitForExistence(timeout: 5))
        
        // Enter first name
        XCTAssert(textFields["enter first name"].exists)
        textFields["enter first name"].tap()
        textFields["enter first name"].typeText("Leland")
        
        // Enter last name
        XCTAssert(textFields["enter last name"].exists)
        textFields["enter last name"].tap()
        textFields["enter last name"].typeText("Stanford")
        
        // Complete Account
        XCTAssert(buttons["Complete"].waitForExistence(timeout: 2) && buttons["Complete"].isEnabled)
        buttons["Complete"].tap()
    }
    
    private func createAccount(email: String) throws {
        XCTAssert(staticTexts["Create a new Account"].waitForExistence(timeout: 5))
        
        // Add email
        XCTAssert(collectionViews.textFields["E-Mail Address"].exists)
        collectionViews.textFields["E-Mail Address"].tap()
        collectionViews.textFields["E-Mail Address"].typeText(email)
        
        // Add password
        XCTAssert(collectionViews.secureTextFields["Password"].exists)
        collectionViews.secureTextFields["Password"].tap()
        collectionViews.secureTextFields["Password"].typeText("12345678")
        
        // Enter first name
        XCTAssert(textFields["enter first name"].exists)
        textFields["enter first name"].tap()
        textFields["enter first name"].typeText("Leland")
        
        // Enter last name
        XCTAssert(textFields["enter last name"].exists)
        textFields["enter last name"].tap()
        textFields["enter last name"].typeText("Stanford")
        
        // Tap DoB button to enter today's date
        XCTAssert(buttons["Add Date of Birth"].waitForExistence(timeout: 2))
        buttons["Add Date of Birth"].tap()
        
        // Sign up
        XCTAssert(collectionViews.buttons["Signup"].waitForExistence(timeout: 2)
                  && collectionViews.buttons["Signup"].isEnabled)
        collectionViews.buttons["Signup"].tap()
        
        sleep(3)
    }
    
    private func navigateConsent() throws {
        XCTAssert(staticTexts["Consent"].waitForExistence(timeout: 5))
        
        // Enter first name
        XCTAssert(textFields["Enter your first name ..."].exists)
        textFields["Enter your first name ..."].tap()
        textFields["Enter your first name ..."].typeText("Leland")
        
        // Enter last name
        XCTAssert(textFields["Enter your last name ..."].exists)
        textFields["Enter your last name ..."].tap()
        textFields["Enter your last name ..."].typeText("Stanford")
        
        XCTAssertTrue(scrollViews["Signature Field"].waitForExistence(timeout: 2))
        scrollViews["Signature Field"].tap()
        scrollViews["Signature Field"].swipeRight()
        
        XCTAssert(buttons["I Consent"].waitForExistence(timeout: 2)
                  && buttons["I Consent"].isEnabled)
        buttons["I Consent"].tap()
    }
    
    private func navigateNotifications() throws {
        XCTAssert(staticTexts["Notifications"].waitForExistence(timeout: 5))
        
        XCTAssert(buttons["Allow Notifications"].waitForExistence(timeout: 2))
        buttons["Allow Notifications"].tap()
    }
    
    fileprivate func assertOnboardingComplete() {
        XCTAssert(staticTexts["Home"].waitForExistence(timeout: 5))
        
        let tabBar = tabBars["Tab Bar"]
        XCTAssert(tabBar.buttons["Home"].waitForExistence(timeout: 2))
    }
    
    fileprivate func assertAccountInformation(email: String) throws {
        XCTAssertTrue(navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        navigationBars.buttons["Your Account"].tap()
        
        XCTAssert(staticTexts["Account Overview"].waitForExistence(timeout: 5))
        XCTAssert(staticTexts["Leland Stanford"].waitForExistence(timeout: 5))
        XCTAssert(staticTexts[email].waitForExistence(timeout: 5))
        XCTAssert(staticTexts["Gender Identity, Choose not to answer"].waitForExistence(timeout: 5))
        
        XCTAssertTrue(navigationBars.buttons["Close"].waitForExistence(timeout: 0.5))
        navigationBars.buttons["Close"].tap()

        XCTAssertTrue(navigationBars.buttons["Your Account"].waitForExistence(timeout: 2))
        navigationBars.buttons["Your Account"].tap()
        
        XCTAssertTrue(navigationBars.buttons["Edit"].waitForExistence(timeout: 2))
        navigationBars.buttons["Edit"].tap()

        usleep(500_00)
        XCTAssertFalse(navigationBars.buttons["Close"].exists)

        XCTAssert(buttons["Delete Account"].waitForExistence(timeout: 2))
        buttons["Delete Account"].tap()

        let alert = "Are you sure you want to delete your account?"
        XCTAssert(alerts[alert].waitForExistence(timeout: 6.0))
        alerts[alert].buttons["Delete"].tap()

        XCTAssert(alerts["Authentication Required"].waitForExistence(timeout: 2.0))
        XCTAssert(alerts["Authentication Required"].secureTextFields["Password"].waitForExistence(timeout: 0.5))
        typeText("12345678") // the password field has focus already
        XCTAssertTrue(alerts["Authentication Required"].buttons["Login"].waitForExistence(timeout: 0.5))
        alerts["Authentication Required"].buttons["Login"].tap()
        
        sleep(2)

        // Login
        if buttons["I Already Have an Account"].waitForExistence(timeout: 2.0) {
            buttons["I Already Have an Account"].tap()
        }

        XCTAssert(textFields["E-Mail Address"].waitForExistence(timeout: 5))
        textFields["E-Mail Address"].tap()
        textFields["E-Mail Address"].typeText(email)
        
        XCTAssert(secureTextFields["Password"].waitForExistence(timeout: 5))
        secureTextFields["Password"].tap()
        secureTextFields["Password"].tap()
        secureTextFields["Password"].typeText("12345678")

        XCTAssertTrue(buttons["Login"].waitForExistence(timeout: 0.5))
        buttons["Login"].tap()

        XCTAssertTrue(alerts["Invalid Credentials"].waitForExistence(timeout: 2.0))
    }
}
