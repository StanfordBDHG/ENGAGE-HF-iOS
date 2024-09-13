//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseFunctions
import Foundation
import OSLog
import Spezi
import SpeziAccount
import SpeziFirebaseAccount


/// Message manager
///
/// Maintains a list of Messages assigned to the current user in firebase
/// On sign-in, adds a snapshot listener to the user's messages collection
@Observable
@MainActor
final class MessageManager: Module, EnvironmentAccessible, DefaultInitializable {
    @ObservationIgnored @StandardActor var standard: ENGAGEHFStandard
    
    @ObservationIgnored @Dependency(Account.self) private var account: Account?
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    @Application(\.logger) @ObservationIgnored private var logger

    private(set) var messages: [Message] = []

    private var notificationTask: Task<Void, Never>?
    private var snapshotListener: ListenerRegistration?

    
    nonisolated init() {}

    
    func configure() {
#if DEBUG || TEST
        if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.setupTestMessages {
            self.injectTestMessages()
            return
        }
#endif

        if let accountNotifications {
            notificationTask = Task.detached { @MainActor [weak self] in
                for await event in accountNotifications.events {
                    guard let self else {
                        return
                    }

                    if let details = event.newEnrolledAccountDetails {
                        updateSnapshotListener(for: details)
                    } else if event.accountDetails == nil {
                        updateSnapshotListener(for: nil)
                    }
                }
            }
        }

        if let account, account.signedIn {
            updateSnapshotListener(for: account.details)
        }
    }
    
    
    /// Call on initialization and sign-in of user
    ///
    /// Creates a snapshot listener to save new messages to the manager as they are added to the user's directory in Firebase
    @MainActor
    private func updateSnapshotListener(for details: AccountDetails?) {
        logger.info("Initializing message snapshot listener...")

        // Remove previous snapshot listener for the user before creating new one
        self.snapshotListener?.remove()

        guard let details else {
            self.messages.removeAll()
            return
        }

        let messagesCollectionReference = Firestore.messagesCollectionReference(for: details.accountId)

        // Set a snapshot listener on the query for valid notifications
        self.snapshotListener = messagesCollectionReference
            .whereField("completionDate", isEqualTo: NSNull())
            .addSnapshotListener { querySnapshot, error in
                self.logger.debug("Fetching most recent messages...")
                
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
                
                self.logger.debug("Messages updated.")
            }
    }

    @MainActor
    func dismiss(_ message: Message, didPerformAction: Bool) async {
        logger.debug("Dismissing message with id: \(message.id ?? "nil")")
        
        guard message.isDismissible else {
            logger.warning("Attempted to delete non-dismissible message (\(message.id ?? "nil")). Returning.")
            return
        }
        
        guard let messageId = message.id else {
            logger.error("Unable to dismiss message: id is nil.")
            return
        }
        
#if DEBUG || TEST
        if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.setupTestMessages {
            messages.removeAll { $0.id == messageId }
            return
        }
#endif

        guard let account, account.signedIn else {
            logger.error("Unable to dismiss message: No user signed in.")
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

    deinit {
        _notificationTask?.cancel()
    }
}


#if DEBUG || TEST
extension MessageManager {
    /// Adds a mock message to self.messages
    /// Used for testing in previews
    @MainActor
    func addMockMessage(dismissible: Bool = true, action: MessageAction = .showHealthSummary) {
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
    

    @MainActor
    private func injectTestMessages() {
        self.messages = [
            // With play video action, with description, is dismissible
            Message(
                title: "Medication Change",
                description: "Your medication has been changed. Watch the video for more information.",
                action: .playVideo(sectionId: "1", videoId: "2"),
                isDismissible: true,
                dueDate: nil,
                completionDate: nil
            ),
            // With see medications action, no description, is dismissible
            Message(
                title: "Medication Uptitration",
                description: nil,
                action: .showMedications,
                isDismissible: true,
                dueDate: nil,
                completionDate: nil
            ),
            // With see heart heatlh action, with description, is not dismissible
            Message(
                title: "Vitals",
                description: "Please take blood pressure and weight measurements.",
                action: .showHeartHealth,
                isDismissible: false,
                dueDate: Date(),
                completionDate: nil
            ),
            // With symptom questionnaire action
            Message(
                title: "Symptom Questionnaire",
                description: "Please complete the symptom questionnaire.",
                action: .completeQuestionnaire(questionnaireId: "0"),
                isDismissible: false,
                dueDate: Date(),
                completionDate: nil
            ),
            // With unknown action
            Message(
                title: "Unknown",
                description: nil,
                action: .unknown,
                isDismissible: false,
                dueDate: nil,
                completionDate: nil
            )
        ]
    }
}
#endif
