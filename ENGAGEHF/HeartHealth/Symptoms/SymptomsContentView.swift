//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsContentView: View {
    @State private var symptomsType: SymptomsType = .overall
    @State private var recordFormat: RecordFormat = .list
    
    
    var body: some View {
        Section(
            content: {
                // Symptom Scores List or Graph
                SymptomsHistoryView(symptomType: symptomsType, format: recordFormat)
                
                // Picker for changing the symptoms type
                SymptomsPicker(symptomsType: $symptomsType)
                
                // Symptoms description
                HeartHealthCaption(
                    title: "Description",
                    descriptionKey: LocalizedStringKey(symptomsType.explanationKey)
                )
            },
            header: {
                // Header with picker for score type
                HStack {
                    Text(symptomsType.fullName)
                        .studyApplicationHeaderStyle()
                    Spacer()
                    RecordFormatPicker(recordFormat: $recordFormat)
                }
            }
        )
    }
}


#Preview {
    SymptomsContentView()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
