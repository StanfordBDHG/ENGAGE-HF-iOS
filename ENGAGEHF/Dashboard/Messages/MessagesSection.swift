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


struct MessagesSection: View {
    @Environment(MessageManager.self) private var messageManager
    
    
    var body: some View {
        if !messageManager.messages.isEmpty {
            Section(
                content: {
                    ForEach(messageManager.messages) { message in
                        StudyApplicationListCard {
                            MessageRow(message: message)
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel(self.constructAccessibilityLabel(from: message))
                                .accessibilityIdentifier("Message Card - \(message.title)")
                        }
                    }
                        .buttonStyle(.borderless)
                },
                header: {
                    Text("Messages")
                        .studyApplicationHeaderStyle()
                }
            )
        }
    }
    
    
    private func constructAccessibilityLabel(from message: Message) -> String {
        """
        Message: \(message.title), \
        description: \(message.description ?? "none"), \
        action: \(message.action.localizedDescription).
        """
    }
}


#if DEBUG
#Preview {
    struct MessagesSectionPreviewWrapper: View {
        @Environment(MessageManager.self) private var messageManager
        
        var body: some View {
            List {
                MessagesSection()
                StudyApplicationListCard {
                    Button(
                        action: {
                            messageManager.addMockMessage()
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
    
    
    return MessagesSectionPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            MessageManager()
        }
}
#endif
