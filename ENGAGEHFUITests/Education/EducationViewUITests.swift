//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
final class EducationViewUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--assumeOnboardingComplete", "--setupTestEnvironment", "--useFirebaseEmulator", "--setupTestVideos"]
        app.launch()
    }
    
    
    func testLongDescriptionVideoView() async throws {
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Education")
        
        let thumbnailOverlay = app.staticTexts["Thumbnail Overlay Title: Long Description"]
        XCTAssert(thumbnailOverlay.waitForExistence(timeout: 0.5))
        
        thumbnailOverlay.tap()
        
        // Validate navigation bar
        XCTAssert(app.buttons["Education"].waitForExistence(timeout: 2))
        
        let expectedNavigationTitle = app.navigationBars["Long Description"]
        XCTAssert(expectedNavigationTitle.waitForExistence(timeout: 2))
        
        // Validate video player
        XCTAssert(app.staticTexts["Installing ENGAGE-HF App and Connecting Omron Devices"].waitForExistence(timeout: 5))
        XCTAssert(app.links["Education For Patients By Dr Zahra Azizi, MD, MSc"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Play video"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Play video"].isHittable)
        
        // Validate video description
        let expectedDescription = """
        Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
        In this video, we’ll walk you through the installation process, from downloading the app to setting \
        it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
        pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
        first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
        Watch now to get the most out of your app and start monitoring your health with ease!
        
        ENGAGE-HF features seemless bluetooth connectivity that allows you to pair your devices and take \
        measurements without ever leaving the app. Simply set your device to pair-mode, and ENGAGE-HF will \
        automatically connect with the device and ask if you would like to pair. Then, whenever you take a \
        measurement, that measurement will automatically show up on the app!
        """
        
        let scrollableText = app.scrollViews["Video Description: Long Description"]
        XCTAssert(scrollableText.exists)
        
        let descriptionText = scrollableText.staticTexts["Scrollable Text"]
        XCTAssert(descriptionText.exists)
        XCTAssertEqual(descriptionText.label, expectedDescription)
    }
    
    
    func testShortDescrtiptionVideoView() async throws {
        try XCTSkipIf(true, "Skipping test due to network issues on runner") // remove once the runner network issue is resolved
        
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Education")
        
        let thumbnailOverlay = app.staticTexts["Thumbnail Overlay Title: Short Description"]
        XCTAssert(thumbnailOverlay.waitForExistence(timeout: 0.5))
        
        thumbnailOverlay.tap()
        
        // Validate navigation bar
        XCTAssert(app.buttons["Education"].waitForExistence(timeout: 2))
        
        let expectedNavigationTitle = app.navigationBars["Short Description"]
        XCTAssert(expectedNavigationTitle.waitForExistence(timeout: 2))
        
        // Validate video player
        XCTAssert(app.staticTexts["Beta Blockers for Heart Failure"].waitForExistence(timeout: 5))
        XCTAssert(app.links["Education For Patients By Dr Zahra Azizi, MD, MSc"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Play video"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Play video"].isHittable)
        
        // Validate video description
        let expectedDescription = """
        Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
        In this video, we’ll walk you through the installation process, from downloading the app to setting \
        it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
        pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
        first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
        Watch now to get the most out of your app and start monitoring your health with ease!
        """
        
        let scrollableText = app.scrollViews["Video Description: Short Description"]
        XCTAssert(scrollableText.exists)
        
        let descriptionText = scrollableText.staticTexts["Scrollable Text"]
        XCTAssert(descriptionText.exists)
        XCTAssertEqual(descriptionText.label, expectedDescription)
    }
    
    
    func testNoDescriptionVideoView() async throws {
        try XCTSkipIf(true, "Skipping test due to network issues on runner") // remove once the runner network issue is resolved
        
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Education")
        
        let thumbnailOverlay = app.staticTexts["Thumbnail Overlay Title: No Description"]
        XCTAssert(thumbnailOverlay.waitForExistence(timeout: 0.5))
        
        thumbnailOverlay.tap()
        
        // Validate navigation bar
        XCTAssert(app.buttons["Education"].waitForExistence(timeout: 2))
        
        let expectedNavigationTitle = app.navigationBars["No Description"]
        XCTAssert(expectedNavigationTitle.exists)
        
        // Validate video player
        XCTAssert(app.staticTexts["How to Use the ENGAGE-HF App!"].waitForExistence(timeout: 2))
        XCTAssert(app.links["Education For Patients By Dr Zahra Azizi, MD, MSc"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Play video"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Play video"].isHittable)
        
        // Make sure there's no description
        XCTAssertFalse(app.scrollViews["Video Description: No Description"].exists)
    }
    
    func testSectionExtension() async throws {
        try XCTSkipIf(true, "Skipping test due to network issues on runner") // remove once the runner network issue is resolved
        
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Education")
        
        let sectionHeader = app.staticTexts["ENGAGE-HF Application"]
        
        XCTAssert(sectionHeader.waitForExistence(timeout: 0.5))
        XCTAssert(app.images["Thumbnail Image: y2ziZVWossE"].waitForExistence(timeout: 0.5))
        
        sectionHeader.tap()
        
        XCTAssertFalse(app.images["Thumbnail Image: y2ziZVWossE"].waitForExistence(timeout: 0.5))
        XCTAssert(sectionHeader.waitForExistence(timeout: 0.5))
        
        sectionHeader.tap()
        
        XCTAssert(sectionHeader.waitForExistence(timeout: 0.5))
        XCTAssert(app.images["Thumbnail Image: y2ziZVWossE"].waitForExistence(timeout: 0.5))
    }
    
    func testThumbnailsAppear() async throws {
        try XCTSkipIf(true, "Skipping test due to network issues on runner") // remove once the runner network issue is resolved
        
        let app = XCUIApplication()
        
        _ = app.staticTexts["Home"].waitForExistence(timeout: 5)
        
        app.goTo(tab: "Education")
        
        let videoSection = app.otherElements["Video Section: ENGAGE-HF Application"]
        XCTAssert(videoSection.exists)
        
        let sectionSubComponents = videoSection.descendants(matching: .any)
        
        
        let shortDescription = """
        Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
        In this video, we’ll walk you through the installation process, from downloading the app to setting \
        it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
        pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
        first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
        Watch now to get the most out of your app and start monitoring your health with ease!
        """
        
        let longDescription = """
        Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
        In this video, we’ll walk you through the installation process, from downloading the app to setting \
        it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
        pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
        first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
        Watch now to get the most out of your app and start monitoring your health with ease!
        
        ENGAGE-HF features seemless bluetooth connectivity that allows you to pair your devices and take \
        measurements without ever leaving the app. Simply set your device to pair-mode, and ENGAGE-HF will \
        automatically connect with the device and ask if you would like to pair. Then, whenever you take a \
        measurement, that measurement will automatically show up on the app!
        """
        
        try validateVideoCard(sectionSubComponents, videoTitle: "No Description", youtubeId: "y2ziZVWossE")
        try validateVideoCard(sectionSubComponents, videoTitle: "Short Description", videoDescription: shortDescription, youtubeId: "XfgcXkq61k0")
        try validateVideoCard(sectionSubComponents, videoTitle: "Long Description", videoDescription: longDescription, youtubeId: "VUImvk3CNik")
    }
    
    
    private func validateVideoCard(
        _ sectionHierarchy: XCUIElementQuery,
        videoTitle: String,
        videoDescription: String? = nil,
        youtubeId: String = "y2ziZVWossE"
    ) throws {
        let thumbnail = sectionHierarchy["Thumbnail Image: \(youtubeId)"]
        XCTAssert(thumbnail.waitForExistence(timeout: 1.0), "No thumbnail found for video with id \(youtubeId)")
        
        let thumbnailTitle = sectionHierarchy["Thumbnail Overlay Title: \(videoTitle)"]
        XCTAssert(thumbnailTitle.waitForExistence(timeout: 1.0), "No title overlay found for video: \(videoTitle)")
        XCTAssertEqual(thumbnailTitle.label, videoTitle)
        
        let thumbnailDescription = sectionHierarchy["Thumbnail Overlay Description: \(videoTitle)"]
        if let videoDescription {
            XCTAssert(thumbnailDescription.waitForExistence(timeout: 1.0), "No description over found for video with description (\(videoTitle)).")
            XCTAssertEqual(thumbnailDescription.label, videoDescription)
        } else {
            XCTAssertFalse(thumbnailDescription.waitForExistence(timeout: 1.0), "Description overlay found for video with no description (\(videoTitle)).")
        }
    }
}
