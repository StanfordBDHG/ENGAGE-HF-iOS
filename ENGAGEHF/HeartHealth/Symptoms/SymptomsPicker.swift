//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsPicker: View {
    @Binding var symptomsType: SymptomsType
    
    
    var body: some View {
        Menu(
            content: {
                ForEach(SymptomsType.allCases) { symptom in
                    Button(symptom.fullName) {
                        symptomsType = symptom
                    }
                }
            },
            label: {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(symptomsType.fullName)
                        .font(.title3.bold())
                        .foregroundStyle(Color(.label))
                    Image(systemName: "chevron.down")
                        .accessibilityLabel("Symptoms Picker Chevron")
                }
            }
        )
    }
}


#Preview {
    struct SymptomsPickerPreviewWrapper: View {
        @State var symptomsType: SymptomsType = .overall
        
        
        var body: some View {
            VStack {
                SymptomsPicker(symptomsType: $symptomsType)
                Text(symptomsType.description)
            }
        }
    }
    
    return SymptomsPickerPreviewWrapper()
}
