//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import ENGAGEHF
import FirebaseFirestore
import XCTest


final class MessageUnitTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
    }
    
    
    func testWellFormedEncodeDecode() throws {
        let dismissibleMessage = Message(
            title: "Dismissible Message",
            description: "Dismissible Message Description",
            action: .unknown,
            isDismissible: true,
            dueDate: nil,
            completionDate: nil,
            id: nil
        )
        try assertEncodeDecodeWorks(for: dismissibleMessage)
        
        let minimalFieldsMessage = Message(
            title: "Minimal Fields Present",
            description: nil,
            action: .unknown,
            isDismissible: false,
            dueDate: nil,
            completionDate: nil,
            id: nil
        )
        try assertEncodeDecodeWorks(for: minimalFieldsMessage)
        
        let messageWithAction = Message(
            title: "Action Message",
            description: nil,
            action: .playVideo(sectionId: "1234", videoId: "123"),
            isDismissible: false,
            dueDate: nil,
            completionDate: nil,
            id: nil
        )
        try assertEncodeDecodeWorks(for: messageWithAction)
        
        let messageWithDueDate = Message(
            title: "Due Date Message",
            description: "This message has a due date.",
            action: .completeQuestionnaire(questionnaireId: "1234"),
            isDismissible: true,
            dueDate: .now,
            completionDate: nil,
            id: nil
        )
        try assertEncodeDecodeWorks(for: messageWithDueDate)
        
        let messageWithCompletionDate = Message(
            title: "Completion Date Message",
            description: "This message has a completino date.",
            action: .showHeartHealth(vitalsType: .weight),
            isDismissible: true,
            dueDate: .now,
            completionDate: .now,
            id: nil
        )
        try assertEncodeDecodeWorks(for: messageWithCompletionDate)
    }
    
//    func testDecodingWithNoAction() throws {
//        let noActionJSON = Data("""
//            {
//                "notAnAction": "noActionHere"
//            }
//        """.utf8)
//        
//        let decodedAction = try JSONDecoder().decode(MessageAction.self, from: noActionJSON)
//        
//        // We expect to see an unknown action when there is no action field present
//        XCTAssertEqual(decodedAction, .unknown)
//    }
    
//    func testDecodingWithMalformedActions() throws {
//        let completelyMalformedActionJSON = Data("""
//            {
//                "action": "thisShouldNotMatchAnAction"
//            }
//        """.utf8)
//        
//        let emptySectionIdJSON = Data("""
//            {
//                "action": "videoSections//videos/1"
//            }
//        """.utf8)
//        
//        let emptyVideoIdJSON = Data("""
//            {
//                "action": "videoSections/1/videos/"
//            }
//        """.utf8)
//        
//        let emptyQuestionnaireIdJSON = Data("""
//            {
//                "action": "questionnaires/"
//            }
//        """.utf8)
//        
//        let multipleVideoRegexMatchesJSON = Data("""
//            {
//                "action": "videoSections/1/videos/0videoSections/1/videos/0"
//            }
//        """.utf8)
//        
//        let multipleQuestionnaireRegexMatchesJSON = Data("""
//            {
//                "action": "questionnaires/1questionnaires/1"
//            }
//        """.utf8)
//        
//        try assertDecodeWorks(for: completelyMalformedActionJSON, expectedOutput: .unknown)
//        try assertDecodeWorks(for: emptySectionIdJSON, expectedOutput: .unknown)
//        try assertDecodeWorks(for: emptyVideoIdJSON, expectedOutput: .unknown)
//        try assertDecodeWorks(for: emptyQuestionnaireIdJSON, expectedOutput: .unknown)
//        try assertDecodeWorks(for: multipleVideoRegexMatchesJSON, expectedOutput: .unknown)
//        try assertDecodeWorks(for: multipleQuestionnaireRegexMatchesJSON, expectedOutput: .unknown)
//    }
    
    private func assertDecodeWorks(for data: Data, expectedOutput: Message) throws {
        let decodedAction = try Firestore.Decoder().decode(Message.self, from: data)
        XCTAssertEqual(decodedAction, expectedOutput, "Decode failed for: \(data).")
    }
    
    private func assertEncodeDecodeWorks(for message: Message) throws {
        let encodedMessage = try Firestore.Encoder().encode(message)
        let decodedMessage = try Firestore.Decoder().decode(Message.self, from: encodedMessage)
        XCTAssertEqual(
            decodedMessage,
            message,
            "Encode Decode failed. Original: \(message). Encoded: \(encodedMessage). Decoded: \(decodedMessage)."
        )
    }
}
