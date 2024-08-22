//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import ENGAGEHF
import FirebaseFirestore
import HealthKit
import XCTest


final class MessageActionUnitTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testWellFormedDecoding() throws {
        let wellFormedVideoString = "videoSections/1234/videos/12"
        let videoAction = MessageAction(from: wellFormedVideoString)
        XCTAssertEqual(videoAction, .playVideo(sectionId: "1234", videoId: "12"))
        
        let wellFormedMedicationsString = "medications"
        let medicationAction = MessageAction(from: wellFormedMedicationsString)
        XCTAssertEqual(medicationAction, .showMedications)
        
        let wellFormedQuestionnaireString = "questionnaires/1234"
        let questionnaireAction = MessageAction(from: wellFormedQuestionnaireString)
        XCTAssertEqual(questionnaireAction, .completeQuestionnaire(questionnaireId: "1234"))
        
        let wellFormedHealthSummaryString = "healthSummary"
        let healthSummaryAction = MessageAction(from: wellFormedHealthSummaryString)
        XCTAssertEqual(healthSummaryAction, .showHealthSummary)
        
        let wellFormedHeartHealthString = "observations"
        let heartHealthAction = MessageAction(from: wellFormedHeartHealthString)
        XCTAssertEqual(heartHealthAction, .showHeartHealth)
    }
    
    
    func testMalformedDecoding() throws {
        let completelyMalformedActionString = "thisShouldNotMatchAnAction"
        XCTAssertEqual(MessageAction(from: completelyMalformedActionString), .unknown)
        
        let noVideoSectionIdString = "videoSections//videos/1"
        XCTAssertEqual(MessageAction(from: noVideoSectionIdString), .unknown)
        
        let noVideoIdString = "videoSections/1/videos/"
        XCTAssertEqual(MessageAction(from: noVideoIdString), .unknown)
        
        let noQuestionnaireIdString = "questionnaires/"
        XCTAssertEqual(MessageAction(from: noQuestionnaireIdString), .unknown)
        
        let multipleVideoRegexMatchesString = "videoSections/1/videos/0videoSections/1/videos/0"
        XCTAssertEqual(MessageAction(from: multipleVideoRegexMatchesString), .unknown)
        
        let multipleQuestionnaireRegexMatchesString = "questionnaires/1questionnaires/1"
        XCTAssertEqual(MessageAction(from: multipleQuestionnaireRegexMatchesString), .unknown)
        
        XCTAssertEqual(MessageAction(from: nil), .unknown)
    }
}
