//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import OSLog
import Spezi
import SpeziFirebaseConfiguration


//
// A notification manager
//
// Maintains a list of Notifications associated with the current user in firebase
//
// Includes functionality for adding notifications and marking them complete
// On configuration of the app, adds a snapshot listener to the user's notification collection
//
@Observable
class NotificationManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @StandardActor var standard: ENGAGEHFStandard
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private var snapshotListener: ListenerRegistration?
    
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NotificationManager")
    
    private let expirationDate = 10
    
    var notifications: [Notification] = []
    var isDeletingLastNotification = false
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            let dummyNotification = Notification(
                title: "Weight Recorded",
                description: "A weight measurement has been recorded.",
                id: "test"
            )
            notifications.append(dummyNotification)
            return
        }
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.registerSnapshotListener(user: user)
        }
        self.registerSnapshotListener(user: Auth.auth().currentUser)
    }
    
    // Call on initialization
    //
    // Creates a snapshot listener to save new notifications to the manager
    // as they are added to the user's directory in Firebase
    func registerSnapshotListener(user: User?) {
        logger.info("Initializing notifiation snapshot listener...")
        
        // Remove previous snapshot listener for the user before creating new one
        snapshotListener?.remove()
        guard let uid = user?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        // Ignore notifications older than expirationDate
        guard let thresholdDate = Calendar.current.date(byAdding: .day, value: -expirationDate, to: .now) else {
            logger.error("Unable to get threshold date: \(FetchingError.invalidTimestamp)")
            return
        }
        
        let thesholdTimeStamp = Timestamp(date: thresholdDate)
        
        // Set a snapshot listener on the query for valid notifications
        db.collection("users").document(uid).collection("notifications")
            .whereField("created", isGreaterThan: thesholdTimeStamp)
            .addSnapshotListener() { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    self.logger.error("Error fetching documents: \(error!)")
                    return
                }
                
                self.notifications = documents.compactMap {
                    if $0.get("completed") == nil {
                        return Notification(
                            title: String(describing: $0["title"] ?? "Unknown"),
                            description: String(describing: $0["description"] ?? "Unknown"),
                            id: $0.documentID
                        )
                    }
                    return nil
                }
                
                self.logger.debug("Notifications updated")
            }
    }
    
    func add(_ notification: Notification) async {
        await standard.add(notification: notification)
    }
    
    func markComplete(at offsets: IndexSet) async {
        if ProcessInfo.processInfo.isPreviewSimulator {
            notifications.remove(atOffsets: offsets)
            return
        }
        
        logger.debug("Marking notifications complete at the following offsets: \(offsets)")
        
        let db = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else {
            logger.error("Unable to mark notitificaitons complete: \(FetchingError.userNotAuthenticated)")
            return
        }
        
        // Mark the notifications as completed in the Firestore
        let timestamp = Timestamp(date: .now)
        for offset in offsets {
            let docID = notifications[offset].id
            
            let docRef = db.collection("users").document(user.uid).collection("notifications")
                .document(docID)
            
            do {
                try await docRef.updateData([
                    "completed": timestamp
                ])
            } catch {
                logger.error("Unable to update notification at offset \(offset): \(error)")
            }
        }
        
        logger.info("Successfully marked notifications complete!")
    }
}


extension NotificationManager {
    // Function for adding a mock notification for the preview simulator
    func addMock() {
        let dummyNotification = Notification(
            title: "Mock Notification",
            description: "This is a mock notification.",
            id: "mock"
        )
        notifications.append(dummyNotification)
    }
}
