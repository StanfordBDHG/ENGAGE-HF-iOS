//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SpeziViews
import SwiftUI


struct NotificationRow: View {
    let notification: Notification
    
    @ScaledMetric private var spacing: CGFloat = 5
    @ScaledMetric private var typeFontSize: CGFloat = 12
    @ScaledMetric private var titleFontSize: CGFloat = 15
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(alignment: .center) {
                Text(notification.type.localizedUppercase)
                    .font(.system(size: typeFontSize, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                XButton(notification: notification)
            }
            Divider()
            Text(notification.title)
                .font(.system(size: titleFontSize, weight: .bold))
                .bold()
                .multilineTextAlignment(.leading)
                .padding(.bottom, spacing)
            ExpandableText(text: notification.description, lineLimit: 1)
                .font(.footnote)
        }
    }
    
    
    private struct XButton: View {
        @Environment(NotificationManager.self) private var notificationManager
        @ScaledMetric private var labelSize: CGFloat = 9
        private let logger = Logger(subsystem: "ENGAGEHF", category: "NotificationManager")
        
        let notification: Notification
        
        
        var body: some View {
            AsyncButton(
                action: {
                    guard let id = notification.id else {
                        logger.error("Unable to mark notification complete: No notification id")
                        return
                    }
                    await notificationManager.markComplete(id: id)
                },
                label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: labelSize, height: labelSize)
                        .foregroundStyle(.accent)
                        .accessibilityLabel("XButton")
                }
            )
        }
    }
}


#Preview {
    struct NotificationRowPreviewWrapper: View {
        @Environment(NotificationManager.self) private var notificationManager
        
        
        var body: some View {
            List {
                Section(
                    content: {
                        ForEach(notificationManager.notifications, id: \.id) { notification in
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
