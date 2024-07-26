//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button(
                action: {
                    withAnimation {
                        configuration.isExpanded.toggle()
                    }
                },
                label: {
                    HStack {
                        configuration.label
                        Spacer()
                        Image(systemName: configuration.isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.accentColor)
                            .animation(nil, value: configuration.isExpanded)
                    }
                    .contentShape(Rectangle())
                }
            )
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}


#Preview {
    struct MedicationDisclosureStylePreviewWrapper: View {
        var body: some View {
            DisclosureGroup(
                content: { Text("Content") },
                label: { Text("Label") }
            )
                .disclosureGroupStyle(MedicationDisclosureStyle())
        }
    }
    
    return MedicationDisclosureStylePreviewWrapper()
}
