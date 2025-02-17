//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
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
            .accessibilityLabel(message.action.localizedDescription.localizedString() + " Symbol")
    }
    
    private var processingStateView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text(processingStateText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .fill(.secondary.opacity(0.1))
            }
    }
    
    private var processingStateText: String {
        if let processingState = message.processingState {
            switch processingState.type {
            case .healthMeasurement(let count):
                return "Processing \(count) measurement\(count == 1 ? "" : "s")..."
            case .questionnaire:
                return "Processing questionnaire..."
            }
        }
        return "Processing..."
    }
    
    private var titleRow: some View {
        HStack(alignment: .top) {
            HStack(alignment: .center, spacing: 8) {
                Text(message.title)
                    .bold()
            }
                .font(.subheadline)
            Spacer()
            if message.isDismissible && !message.isProcessing {
                XButton(message: message, labelSize: dismissLabelSize)
            }
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: spacing) {
            titleRow
            
            if let description = message.description {
                ExpandableText(text: description, lineLimit: 3)
                    .font(.footnote)
                    .accessibilityIdentifier("Message Description")
            }
            
            if message.isProcessing {
                processingStateView
                    .accessibilityIdentifier("Processing State")
            } else if message.action != .unknown {
                Text(message.action.localizedDescription)
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
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            actionImage
                .foregroundStyle(.accent)
                .frame(width: 38)
            mainContent
        }
            .padding(2)
            .asButton {
                if message.action != .unknown && !message.isProcessing {
                    Task {
                        let didPerformAction = await navigationManager.execute(message.action)
                        if message.isDismissible, didPerformAction {
                            await messageManager.dismiss(message, didPerformAction: didPerformAction)
                        }
                    }
                }
            }
            .disabled(message.isProcessing)
    }
}


#if DEBUG
#Preview { // swiftlint:disable:this closure_body_length
    struct MessageRowPreviewWrapper: View {
        @Environment(MessageManager.self) private var messageManager

        var body: some View {
            NavigationStack {
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
                }
                    .studyApplicationList()
                    .toolbar {
                        Button(
                            action: {
                                messageManager.addMockMessage()
                            },
                            label: {
                                Text("Add Mock")
                            }
                        )
                        Button(
                            action: {
                                messageManager.makeMockMessagesProcessing()
                            },
                            label: {
                                Text("Set Processing")
                            }
                        )
                    }
            }
        }
    }
    
    return MessageRowPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration(service: InMemoryAccountService())
            MessageManager()
            NavigationManager()
        }
}
#endif
