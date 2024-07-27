//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import Spezi
import SpeziFirebaseConfiguration


/// Notification manager
///
/// Maintains a list of Notifications associated with the current user in firebase
/// On configuration of the app, adds a snapshot listener to the user's notification collection
@Observable
class NotificationManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @StandardActor var standard: ENGAGEHFStandard
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private var snapshotListener: ListenerRegistration?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NotificationManager")
    
    var notifications: [Notification] = []
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            let dummyNotification = Notification(
                id: String(describing: UUID()),
                type: "Mock Notification",
                title: "Weight Recorded",
                description: "A weight measurement has been recorded.",
                created: Timestamp(date: .now),
                completed: false
            )
            notifications.append(dummyNotification)
            return
        }
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.registerSnapshotListener(user: user)
            
            // If testing, add 3 notifications to firestore
            // Called when a user's sign in status changes
            if FeatureFlags.setupMockMessages, let user {
                // Make sure to not load the mock notifications multiple times
                if let notifications = self?.notifications, notifications.isEmpty {
                    Task { [weak self] in
                        try await self?.setupNotificationTests(user: user)
                    }
                }
            }
        }
        self.registerSnapshotListener(user: Auth.auth().currentUser)
    }
    
    
    /// Adds three mock notifications to the user's notification collection in firestore
    func setupNotificationTests(user: User) async throws {
        // Not recommended to delete collections from the client, so for now just skipping if the collection already exists
        let querySnapshot = try await Firestore.messagesCollectionReference.getDocuments()
        
        guard querySnapshot.documents.isEmpty else {
            // Notifications collections exists and is not empty, so skip
            self.logger.debug("Notifications already exist, skipping user.")
            return
        }
        
        self.logger.debug("Adding test notifications for user \(user.uid)")
        
        for idx in 1...3 {
            let newNotification = Notification(
                type: "Mock Notification \(idx)",
                title: "This is a mock notification.",
                description: "This is a long string that should be truncated by the expandable text class.",
                created: Timestamp(date: .now),
                completed: false
            )
            
            do {
                try Firestore.messagesCollectionReference.addDocument(from: newNotification)
            } catch {
                self.logger.error("Unable to load notifications to firestore: \(error)")
            }
        }
    }
    
    
    /// Call on initialization and sign-in of user
    ///
    /// Creates a snapshot listener to save new notifications to the manager as they are added to the user's directory in Firebase
    func registerSnapshotListener(user: User?) {
        logger.info("Initializing notification snapshot listener...")

        // Remove previous snapshot listener for the user before creating new one
        snapshotListener?.remove()
        
        guard let messagesCollectionReference = try? Firestore.messagesCollectionReference else {
            return
        }
        
        // Set a snapshot listener on the query for valid notifications
        messagesCollectionReference
            .addSnapshotListener { querySnapshot, error in
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching documents: \(error)")
                    return
                }
                
                self.notifications = documentRefs.compactMap {
                    do {
                        return try $0.data(as: Notification.self)
                    } catch {
                        self.logger.error("Error decoding notifications: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("Notifications updated")
            }
    }
    
    func markComplete(id: String) async {
        if ProcessInfo.processInfo.isPreviewSimulator {
            notifications.removeAll { $0.id == id }
            return
        }
        
        logger.debug("Marking notification complete with the following id: \(id)")
        
        do {
            let messagesDocumentReference = try Firestore.messagesCollectionReference.document(id)
            try await messagesDocumentReference.updateData(
                [
                    "completed": Timestamp(date: .now)
                ]
            )
        } catch {
            logger.error("Unable to update notification \(id): \(error)")
        }
        
        logger.debug("Successfully marked notifications complete!")
    }
}


extension NotificationManager {
    // Function for adding a mock notification for the preview simulator
    func addMock() {
        let dummyNotification = Notification(
            id: String(describing: UUID()),
            type: "Medication Change",
            title: "Your dose of XXX was changed.",
            description: "Your dose of XXX was changed. You can review medication information in the Education Page.",
            created: Timestamp(date: .now),
            completed: false
        )
        notifications.append(dummyNotification)
    }
}
