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


struct NotificationsView: View {
    @State private var notifications: [Notification] = []

    var body: some View {
        VStack {
            GreetingView()
            
            if !notifications.isEmpty {
                List {
                    ForEach(notifications, id: \.id) { notification in
                        @Bindable var notification = notification
                        
                        NotificationRow(notification: $notification)
                    }
                }
            } else {
                Text("No new notifications")
            }
        }
        .task {
            do {
                try await self.getNotifications()
            } catch {
                print("\(error)")
            }
        }
    }
    
    // Call on appearance
    // Queries the user's firestore data for valid notificiations
    // Valid notifications are not marked completed and younger than 10 days
    private func getNotifications() async throws {
        let db = Firestore.firestore()
        
        guard let thresholdDate = Calendar.current.date(byAdding: .day, value: -10, to: .now) else {
            throw NotificationError.invalidTimestamp
        }
        
        let thesholdTimeStamp = Timestamp(date: thresholdDate)
        
        guard let user = Auth.auth().currentUser else {
            throw NotificationError.userNotAuthenticated
        }
        
        do {
            let docSnapshot = try await db.collection("users").document(user.uid).collection("notifications")
                .whereField("created", isGreaterThan: thesholdTimeStamp)
                .whereField("completed", isEqualTo: false)
                .getDocuments()
            
            for doc in docSnapshot.documents {
                let docData = doc.data()
                
                let newNotification = Notification(
                    title: String(describing: docData["title"]),
                    description: String(describing: docData["description"]),
                    id: String(describing: doc.documentID)
                )
                
                self.notifications.append(newNotification)
            }
        } catch {
            throw error
        }
        
    }
}

#Preview {
    NotificationsView()
}
