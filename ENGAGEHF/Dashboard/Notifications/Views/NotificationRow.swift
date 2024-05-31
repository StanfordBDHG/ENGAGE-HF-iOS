//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NotificationRow: View {
    @Binding var notification: Notification
    @State private var isExpanded = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(notification.type)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                XButton(notification: $notification)
            }
            Divider()
            Text(notification.title)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)
            if isExpanded {
                Text(notification.description)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
            } else {
                LearnMoreButton(isExpanded: $isExpanded)
            }
        }
            .onDisappear {
                isExpanded = false
            }
    }
    
    
    private struct XButton: View {
        @Environment(NotificationManager.self) private var notificationManager
        @Binding var notification: Notification
        
        
        var body: some View {
            AsyncButton(
                action: {
                    let indx = notificationManager.notifications.firstIndex {$0.id == notification.id}
                    
                    if let indx: Int {
                        await notificationManager.markComplete(at: IndexSet(integer: indx))
                    }
                },
                label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.accent)
                        .imageScale(.small)
                }
            )
        }
    }
}


#Preview {
    struct NotificationRowPreviewWrapper: View {
        @Environment(NotificationManager.self) private var notificationManager
        
        
        var body: some View {
            @Bindable var notificationManager = notificationManager
            
            List {
                Section(
                    content: {
                        ForEach($notificationManager.notifications, id: \.id) { notification in
                            StudyApplicationListCard {
                                NotificationRow(notification: notification)
                            }
                        }
                    },
                    header: {
                        Text("Notifications")
                            .studyApplicationHeaderStyle()
                    }
                )
                    .buttonStyle(.borderless)
                Button(
                    action: {
                        notificationManager.addMock()
                    },
                    label: {
                        Text("Add Mock")
                    }
                )
            }
                .studyApplicationList()
        }
    }
    
    
    return NotificationRowPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            NotificationManager()
        }
}
