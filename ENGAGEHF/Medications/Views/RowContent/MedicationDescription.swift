//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationDescription: View {
    let title: String
    let description: String
    
    @Environment(NavigationManager.self) private var navigationManager
    
    
    var body: some View {
        HStack {
            Text(description)
                .font(.body)
                .padding(.vertical, 2)
            
            Spacer()
            
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.accent)
                .accessibilityLabel("\(title) More Information")
                .asButton {
                    navigationManager.switchHomeTab(to: .education)
                }
        }
    }
}


#Preview {
    MedicationDescription(
        title: "Carvedilol",
        description: "Target dose reached. No action Required."
    )
}
