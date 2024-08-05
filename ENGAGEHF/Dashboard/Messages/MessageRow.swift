//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct MessageRow: View {
    private struct XButton: View {
        @Environment(MessageManager.self) private var messageManager
        @ScaledMetric private var labelSize: CGFloat = 9
        
        let message: Message
        
        
        var body: some View {
            AsyncButton(
                action: {
                    await messageManager.dismiss(message, didPerformAction: false)
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
    
    
    let message: Message
    
    @ScaledMetric private var spacing: CGFloat = 5
    @ScaledMetric private var typeFontSize: CGFloat = 12
    @ScaledMetric private var titleFontSize: CGFloat = 15
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                Text(message.title)
                    .font(.system(size: typeFontSize, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                if message.isDismissible {
                    XButton(message: message)
                }
            }
            Divider()
                .frame(maxWidth: .infinity)
            ExpandableText(text: message.description ?? "", lineLimit: 3)
                .font(.footnote)
        }
            .asButton {
                print("Perform \(message.action)")
            }
    }
}


#if DEBUG
#Preview { // swiftlint:disable:this closure_body_length
    struct MessageRowPreviewWrapper: View {
        @Environment(MessageManager.self) private var messageManager
        
        
        var body: some View {
            List {
                Section(
                    content: {
                        ForEach(messageManager.messages) { message in
                            StudyApplicationListCard {
                                MessageRow(message: message)
                            }
                        }
                            .buttonStyle(.borderless)
                    },
                    header: {
                        Text("Messages")
                            .studyApplicationHeaderStyle()
                    }
                )
                Section(
                    content: {
                        StudyApplicationListCard {
                            Button(
                                action: {
                                    messageManager.addMockMessage()
                                },
                                label: {
                                    Text("Add Mock")
                                }
                            )
                                .buttonStyle(.borderless)
                        }
                    },
                    header: {
                        Text("")
                    }
                )
            }
                .studyApplicationList()
        }
    }
    
    
    return MessageRowPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            MessageManager()
        }
}
#endif
