//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import SwiftUI
import Spezi
import SpeziViews


struct NotificationSection: View {
    @State private var notifications: [Notification] = []
    @State private var state: ViewState = .idle
    
    @State private var notificationsLoaded = false

    
    var body: some View {
        Section("Notifications") {
            if state == .idle {
                NotificationRows(notifications: $notifications)
            } else {
                HStack {
                    Text("Notifications Loading...")
                    Spacer()
                    ProgressView()
                }
            }
        }
        .headerProminence(.increased)
        .task {
            if !notificationsLoaded {
                do {
                    try await self.getNotifications()
                } catch {
                    print("\(error)")
                }
            }
        }
    }
    
    
    // Call on appearance
    // Queries the user's firestore data for valid notificiations
    // Valid notifications are not marked completed and younger than 10 days
    private func getNotifications() async throws {
        state = .processing
        
        let db = Firestore.firestore()
        
        guard let thresholdDate = Calendar.current.date(byAdding: .day, value: -10, to: .now) else {
            throw FetchingError.invalidTimestamp
        }
        
        let thesholdTimeStamp = Timestamp(date: thresholdDate)
        
        guard let user = Auth.auth().currentUser else {
            throw FetchingError.userNotAuthenticated
        }
        
        // If a notification is not completed, the `completed` field should be ''
        // If a notification has been completed, the `completed` field will be the Timestamp of when this occured
        let docSnapshot = try await db.collection("users").document(user.uid).collection("notifications")
            .whereField("created", isGreaterThan: thesholdTimeStamp)
            .getDocuments()
        
        for doc in docSnapshot.documents where (doc.get("completed") == nil) {
            let docData = doc.data()
            
            let newNotification = Notification(
                title: String(describing: docData["title"] ?? "Unknown"),
                description: String(describing: docData["description"] ?? "Unknown"),
                id: String(describing: doc.documentID)
            )
            
            self.notifications.append(newNotification)
        }
        
        print("Successfully loaded notifications!")
        state = .idle
        notificationsLoaded = true
    }
}

#Preview {
    NotificationSection()
}
