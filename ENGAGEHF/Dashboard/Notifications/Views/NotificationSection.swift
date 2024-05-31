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
import Spezi
import SpeziViews
import SwiftUI


struct NotificationSection: View {
    @Environment(NotificationManager.self) private var notificationManager
    
    
    var body: some View {
        @Bindable var notificationManager = notificationManager
        
        Section(
            content: {
                if !notificationManager.notifications.isEmpty {
                    ForEach($notificationManager.notifications, id: \.id) { notification in
                        StudyApplicationListCard {
                            NotificationRow(notification: notification)
                        }
                    }
                        .listRowSeparator(.hidden)
                        .buttonStyle(.borderless)
                } else {
                    StudyApplicationListCard {
                        HStack {
                            Text("No new notifications")
                            Spacer()
                        }
                    }
                }
            },
            header: {
                Text("Notifications")
                    .studyApplicationHeaderStyle()
            }
        )
    }
}


#Preview {
    struct NotificationSectionPreviewWrapper: View {
        @Environment(NotificationManager.self) private var notificationManager
        
        var body: some View {
            List {
                NotificationSection()
                StudyApplicationListCard {
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
                .studyApplicationList()
        }
    }
    
    
    return NotificationSectionPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            NotificationManager()
        }
}
