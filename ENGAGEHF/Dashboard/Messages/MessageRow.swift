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
        
        let message: Message
        let labelSize: CGFloat
        
        
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
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Dismiss Button")
                }
            )
        }
    }
    
    
    let message: Message
    
    @ScaledMetric private var spacing: CGFloat = 8
    @ScaledMetric private var dismissLabelSize: CGFloat = 10
    
    @Environment(NavigationManager.self) private var navigationManager
    @Environment(MessageManager.self) private var messageManager
    
    
    private var actionImage: some View {
        let imageName = switch message.action {
        case .playVideo: "play.circle"
        case .showMedications: "pills"
        case .completeQuestionnaire: "pencil.and.list.clipboard"
        case .showHealthSummary: "doc.on.clipboard"
        case .showHeartHealth: "heart.text.square"
        case .unknown: "envelope"
        }
        
        return Image(systemName: imageName)
            .cardSymbolStyle()
            .accessibilityLabel(message.action.description + " Symbol")
    }
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            actionImage
                .foregroundStyle(.accent)
                .frame(width: 38)
            VStack(alignment: .leading, spacing: spacing) {
                HStack(alignment: .top) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(message.title)
                            .bold()
                    }
                        .font(.subheadline)
                    Spacer()
                    if message.isDismissible {
                        XButton(message: message, labelSize: dismissLabelSize)
                    }
                }
                if let description = message.description {
                    ExpandableText(text: description, lineLimit: 3)
                        .font(.footnote)
                        .accessibilityIdentifier("Message Description")
                }
                if message.action != .unknown {
                    Text(message.action.description)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background {
                            Capsule()
                                .fill(.accent.opacity(0.7))
                        }
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white)
                        .accessibilityIdentifier("Message Action")
                }
            }
        }
            .padding(2)
            .asButton {
                if message.action != .unknown {
                    Task {
                        let didPerformAction = await navigationManager.execute(message.action)
                        if message.isDismissible, didPerformAction {
                            await messageManager.dismiss(message, didPerformAction: didPerformAction)
                        }
                    }
                }
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
            NavigationManager()
        }
}
#endif
