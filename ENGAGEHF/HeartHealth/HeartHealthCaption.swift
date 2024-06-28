//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HeartHealthCaption: View {
    var title: String
    var descriptionKey: LocalizedStringKey
    
    
    var body: some View {
        DisclosureGroup(
            content: {
                StudyApplicationListCard {
                    Text(descriptionKey)
                }
            },
            label: {
                Text(title)
                    .studyApplicationHeaderStyle()
            }
        )
    }
}


#Preview {
    HeartHealthCaption(title: "Weight", descriptionKey: "vitalsWeight")
}
