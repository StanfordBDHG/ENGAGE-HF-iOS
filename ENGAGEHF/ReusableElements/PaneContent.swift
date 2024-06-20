//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


#if DEBUG
struct SheetPreview<Content>: View {
    private let content: Content

    @State private var isPresented = true

    var body: some View {
        Text(verbatim: "")
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    content
                        .toolbar {
                            DismissButton()
                        }
                }
                    .presentationDetents([.medium])
                    .presentationCornerRadius(25)
            }
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content
    }
}
#endif


struct PaneContent<Content: View, Action: View>: View {
    private let title: Text
    private let subtitle: Text
    private let content: Content
    private let action: Action

    @AccessibilityFocusState private var isHeaderFocused: Bool

    var body: some View {
        VStack {
            VStack {
                title
                    .bold()
                    .font(.largeTitle)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($isHeaderFocused)
                subtitle
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding([.leading, .trailing], 20)
            .multilineTextAlignment(.center)

            Spacer()
            content
            Spacer()

            action
        }
            .onAppear {
                isHeaderFocused = true // TODO: should we do that?
            }
    }

    init(title: Text, subtitle: Text, @ViewBuilder content: () -> Content, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.action = action()
    }

    init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource,
        @ViewBuilder content: () -> Content,
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(title: Text(title), subtitle: Text(subtitle), content: content, action: action)
    }
}


#if DEBUG
#Preview {
    SheetPreview {
        PaneContent(title: "The Title", subtitle: "The Subtitle") {
            Image(systemName: "person.crop.square.badge.camera.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityHidden(true)
                .frame(maxWidth: 250, maxHeight: 120)
                .foregroundStyle(.red)
        } action: {
            Button {
            } label: {
                Text("Button")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
                .buttonStyle(.borderedProminent)
                .padding([.leading, .trailing], 36)
        }
    }
}
#endif
