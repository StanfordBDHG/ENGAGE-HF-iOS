//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import SpeziViews
import SwiftUI


struct NotificationRow: View {
    @Binding var notification: Notification
    
    var body: some View {
        DisclosureGroup(
            content: {
                Text(notification.description)
            },
            label: {
                Text(notification.title)
                    .bold()
            }
        )
    }
}


struct NotificationRows: View {
    @Binding var notifications: [Notification]
    
    var body: some View {
        if !notifications.isEmpty {
            ForEach($notifications, id: \.id) { notification in
                NotificationRow(notification: notification)
            }
            .onDelete { index in
                Task {
                    do {
                        try await deleteNotification(at: index)
                    } catch {
                        print("\(error)")
                    }
                }
            }
        } else {
            Text("No new notifications")
        }
    }
    
    private func deleteNotification(at offsets: IndexSet) async throws {
        // Mark the notifications as completed in the Firestore
        let db = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else {
            throw FetchingError.userNotAuthenticated
        }
        
        let timestamp = Timestamp(date: .now)
        for offset in offsets {
            let docID = notifications[offset].id
            
            let docRef = db.collection("users").document(user.uid).collection("notifications")
                .document(docID)
            
            try await docRef.updateData([
                "completed": timestamp
            ])
        }
        
        print("Successfully updated the notifications after deletion!")
        
        // Remove notifications from stored list
        notifications.remove(atOffsets: offsets)
    }
}


#Preview {
    let dummyNotification = Notification(
        title: "Weight Recorded",
        description: "A weight measurement has been recorded.",
        id: "test"
    )
    return NotificationRow(notification: .constant(dummyNotification))
}
