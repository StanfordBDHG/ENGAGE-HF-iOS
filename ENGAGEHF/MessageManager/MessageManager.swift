//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import Foundation
import OSLog
import Spezi
import SpeziFirebaseConfiguration


/// Message manager
///
/// Maintains a list of Notifications associated with the current user in firebase
/// On configuration of the app, adds a snapshot listener to the user's notification collection
@Observable
class MessageManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @StandardActor var standard: ENGAGEHFStandard
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private var snapshotListener: ListenerRegistration?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "MessageManager")
    
    var messages: [Message] = []
    
    
    func configure() {
#if DEBUG
        if ProcessInfo.processInfo.isPreviewSimulator {
            self.setupMessagePreview()
            return
        }
#endif
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.registerSnapshotListener(user: user)

#if DEBUG || TEST
            // If testing, add 3 notifications to firestore
            // Called when a user's sign in status changes
            if FeatureFlags.setupMockMessages, let user {
                // Make sure to not load the mock notifications multiple times
                if let messages = self?.messages, messages.isEmpty {
                    Task { [weak self] in
                        try await self?.setupMessageTests(user: user)
                    }
                }
            }
#endif
        }
        self.registerSnapshotListener(user: Auth.auth().currentUser)
    }
    
    
    /// Call on initialization and sign-in of user
    ///
    /// Creates a snapshot listener to save new messages to the manager as they are added to the user's directory in Firebase
    func registerSnapshotListener(user: User?) {
        logger.info("Initializing message snapshot listener...")

        // Remove previous snapshot listener for the user before creating new one
        self.snapshotListener?.remove()
        
        guard let messagesCollectionReference = try? Firestore.messagesCollectionReference else {
            return
        }
        
        // Set a snapshot listener on the query for valid notifications
        self.snapshotListener = messagesCollectionReference
            .addSnapshotListener { querySnapshot, error in
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching documents: \(error)")
                    return
                }
                
                self.messages = documentRefs
                    .compactMap {
                        do {
                            return try $0.data(as: Message.self)
                        } catch {
                            self.logger.error("Error decoding message: \(error)")
                            return nil
                        }
                    }
                    // Because the completionDate field is absent before the message is dismissed,
                    // the only way to filter out dismissed messages is to do so on the client
                    .filter { $0.completionDate == nil }
                
                self.logger.debug("Messages updated")
            }
    }
    
    func dismiss(_ message: Message, didPerformAction: Bool) async {
        logger.debug("Attempting to dismiss message with id: \(message.id ?? "nil")")
        
        guard let messageId = message.id else {
            logger.error("Unable to dismiss message: id is nil.")
            return
        }
        
#if DEBUG
        if ProcessInfo.processInfo.isPreviewSimulator {
            messages.removeAll { $0.id == messageId }
            return
        }
#endif
        
        guard Auth.auth().currentUser != nil else {
            logger.error("Unable to dismiss message: No user signed in.")
            return
        }
        
        guard message.isDismissible else {
            logger.error("Unable to dismiss message: Message is not dismissible.")
            return
        }
        
        let dismissMessage = Functions.functions().httpsCallable("dismissMessage")
        
        do {
            _ = try await dismissMessage.call(
                [
                    "messageId": messageId,
                    "didPerformAction": didPerformAction
                ]
            )
        } catch {
            logger.error("dismissMessage failed: \(error)")
            return
        }
        
        logger.debug("Successfully dismissed message (\(messageId)).")
    }
}


#if DEBUG || TEST
extension MessageManager {
    /// Adds a mock message to self.messages
    /// Used for testing in previews
    func addMockMessage(dismissible: Bool = true, action: String = "medications") {
        let mockMessage = Message(
            title: "Medication Change",
            description: "Your dose of XXX was changed. You can review medication information in the Education Page.",
            action: action,
            isDismissible: dismissible,
            dueDate: Date().addingTimeInterval(60 * 60 * 24 * 3),  // Due three days from now
            completionDate: nil
        )
        
        self.messages.append(mockMessage)
    }
    
    private func setupMessagePreview() {
        let medicationChange = Message(
            title: "Medication Change",
            description: "Your medication has been changed. Watch the video for more information.",
            action: "videoSections/1/videos/2",
            isDismissible: true,
            dueDate: nil,
            completionDate: nil
        )
        let medicationUptitration = Message(
            title: "Medication Uptitration",
            description: "Your medication is eligible to be increased. Please contact your clinician.",
            action: "medications",
            isDismissible: true,
            dueDate: nil,
            completionDate: nil
        )
        let appointmentReminder = Message(
            title: "Appointment Reminder",
            description: "Your appointment is coming up.",
            action: "healthSummary",
            isDismissible: false,
            dueDate: nil,
            completionDate: nil
        )
        let symptomQuestionnaire = Message(
            title: "Symptom Questionnaire",
            description: "Please complete the symptom questionnaire.",
            action: "questionnaires/0",
            isDismissible: false,
            dueDate: nil,
            completionDate: nil
        )
        self.messages = [medicationChange, medicationUptitration, appointmentReminder, symptomQuestionnaire]
    }
    
    /// Adds three mock notifications to the user's notification collection in firestore
    private func setupMessageTests(user: User) async throws {
        // Not recommended to delete collections from the client, so for now just skipping if the collection already exists
        let querySnapshot = try await Firestore.messagesCollectionReference.getDocuments()
        
        guard querySnapshot.documents.isEmpty else {
            // Notifications collections exists and is not empty, so skip
            self.logger.debug("Messages already exist, skipping user.")
            return
        }
        
        self.logger.debug("Adding test message for user \(user.uid)")
        
        for idx in 1...3 {
            let newMessage = Message(
                title: "Medication Change \(idx)",
                description: "Your dose of XXX was changed. You can review medication information in the Education Page.",
                action: "medications",
                isDismissible: true,
                dueDate: Date().addingTimeInterval(60 * 60 * 24 * 3),  // Due three days from now
                completionDate: nil
            )
            
            do {
                try Firestore.messagesCollectionReference.addDocument(from: newMessage)
            } catch {
                self.logger.error("Unable to load notifications to firestore: \(error)")
            }
        }
    }
}
#endif
