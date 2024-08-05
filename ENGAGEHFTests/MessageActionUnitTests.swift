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
        let videoAction = try MessageAction(from: wellFormedVideoString)
        XCTAssertEqual(videoAction, .playVideo(sectionId: "1234", videoId: "12"))
        
        let wellFormedMedicationsString = "medications"
        let medicationAction = try MessageAction(from: wellFormedMedicationsString)
        XCTAssertEqual(medicationAction, .showMedications)
        
        let wellFormedQuestionnaireString = "questionnaires/1234"
        let questionnaireAction = try MessageAction(from: wellFormedQuestionnaireString)
        XCTAssertEqual(questionnaireAction, .completeQuestionnaire(questionnaireId: "1234"))
        
        let wellFormedHealthSummaryString = "healthSummary"
        let healthSummaryAction = try MessageAction(from: wellFormedHealthSummaryString)
        XCTAssertEqual(healthSummaryAction, .showHealthSummary)
        
        let wellFormedSymptomScoresString = try Firestore.symptomScoresCollectionReference.collectionID
        let symptomScoresAction = try MessageAction(from: wellFormedSymptomScoresString)
        XCTAssertEqual(symptomScoresAction, .showHeartHealth(vitalsType: .symptoms))
        
        let wellFormedBodyWeightString = try Firestore.collectionReference(for: HKQuantityType(.bodyMass))?.collectionID
        let bodyWeightAction = try MessageAction(from: wellFormedBodyWeightString)
        XCTAssertEqual(bodyWeightAction, .showHeartHealth(vitalsType: .weight))
        
        let wellFormedHeartRateString = try Firestore.collectionReference(for: HKQuantityType(.heartRate))?.collectionID
        let heartRateAction = try MessageAction(from: wellFormedHeartRateString)
        XCTAssertEqual(heartRateAction, .showHeartHealth(vitalsType: .heartRate))
        
        let wellFormedBloodPressureString = try Firestore.collectionReference(for: HKCorrelationType(.bloodPressure))?.collectionID
        let bloodPressureAction = try MessageAction(from: wellFormedBloodPressureString)
        XCTAssertEqual(bloodPressureAction, .showHeartHealth(vitalsType: .bloodPressure))
    }
    
    
    func testMalformedDecoding() throws {
        let completelyMalformedActionString = "thisShouldNotMatchAnAction"
        XCTAssertEqual(try MessageAction(from: completelyMalformedActionString), .unknown)
        
        let noVideoSectionIdString = "videoSections//videos/1"
        XCTAssertEqual(try MessageAction(from: noVideoSectionIdString), .unknown)
        
        let noVideoIdString = "videoSections/1/videos/"
        XCTAssertEqual(try MessageAction(from: noVideoIdString), .unknown)
        
        let noQuestionnaireIdString = "questionnaires/"
        XCTAssertEqual(try MessageAction(from: noQuestionnaireIdString), .unknown)
        
        let multipleVideoRegexMatchesString = "videoSections/1/videos/0videoSections/1/videos/0"
        XCTAssertEqual(try MessageAction(from: multipleVideoRegexMatchesString), .unknown)
        
        let multipleQuestionnaireRegexMatchesString = "questionnaires/1questionnaires/1"
        XCTAssertEqual(try MessageAction(from: multipleQuestionnaireRegexMatchesString), .unknown)
        
        XCTAssertEqual(try MessageAction(from: nil), .unknown)
    }
}
