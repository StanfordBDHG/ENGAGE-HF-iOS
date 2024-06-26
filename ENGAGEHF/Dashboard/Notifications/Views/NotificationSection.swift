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
        if !notificationManager.notifications.isEmpty {
            Section(
                content: {
                    ForEach(notificationManager.notifications) { notification in
                        StudyApplicationListCard {
                            NotificationRow(notification: notification)
                        }
                    }
                    .buttonStyle(.borderless)
                },
                header: {
                    Text("Notifications")
                        .studyApplicationHeaderStyle()
                }
            )
        }
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
