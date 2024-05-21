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


struct NotificationSectionPreviewWrapper: View {
    @Environment(NotificationManager.self) private var notificationManager
    
    var body: some View {
        List {
            NotificationSection()
            Button(
                action: {
                    notificationManager.addMock()
                },
                label: {
                    Text("Add mock notification")
                }
            )

        }
    }
}


struct NotificationSection: View {
    @Environment(NotificationManager.self) private var notificationManager
    
    
    var body: some View {
        @Bindable var notificationManager = notificationManager
        
        Section("Notifications") {
            if !notificationManager.notifications.isEmpty && !notificationManager.isDeletingLastNotification {
                ForEach($notificationManager.notifications, id: \.id) { notification in
                    NotificationRow(notification: notification)
                        .transition(.opacity)
                }
                .onDelete { index in
                    Task {
                        if notificationManager.notifications.count == 1 {
                            withAnimation {
                                notificationManager.isDeletingLastNotification = true
                            }
                        }
                        await notificationManager.markComplete(at: index)
                    }
                }
            } else {
                Text("No new notifications")
                    .transition(.opacity)
                    .onChange(of: notificationManager.notifications) { oldNotifs, newNotifs in
                        if oldNotifs.isEmpty && !newNotifs.isEmpty {
                            withAnimation {
                                notificationManager.isDeletingLastNotification = false
                            }
                        }
                    }
            }
        }
            .headerProminence(.increased)
            .animation(.easeInOut, value: notificationManager.notifications)
    }
}


#Preview {
    NotificationSectionPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            NotificationManager()
        }
}
