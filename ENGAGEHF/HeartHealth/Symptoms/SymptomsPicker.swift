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
        Picker("Symptoms Picker", selection: $symptomsType) {
            ForEach(SymptomsType.allCases) { symptom in
                Text(symptom.description)
            }
        }
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
