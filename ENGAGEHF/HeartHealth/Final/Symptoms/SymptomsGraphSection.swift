//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsGraphSection: View {
    @Binding var symptomsType: SymptomsType
    @State private var resolution: Calendar.Component = .day
    
    
    var body: some View {
        Section(
            content: {
                SymptomsHistoryView(symptomType: symptomsType, resolution: resolution)
            },
            header: {
                // Header with picker for score type
                HStack {
                    SymptomsPicker(symptomsType: $symptomsType)
                    Spacer()
                    ResolutionPicker(selection: $resolution)
                }
            }
        )
    }
}


#Preview {
    SymptomsGraphSection(symptomsType: .constant(.overall))
}
