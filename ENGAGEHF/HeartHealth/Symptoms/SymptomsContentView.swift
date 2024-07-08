//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsContentView: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    @State private var symptomsType: SymptomsType = .overall
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
        
        Section(
            content: {
                Text(LocalizedStringKey(symptomsType.explanationKey))
            },
            header: {
                Text("Description")
            }
        )
        
        Section(
            content: {
                ForEach(vitalsManager.symptomHistory) { score in
                    HStack(alignment: .firstTextBaseline) {
                        DisplayMeasurement(
                            quantity: String(format: "%.1f", score[keyPath: symptomsType.symptomScoreKeyMap]),
                            units: "%",
                            type: symptomsType.fullName,
                            quantityTextSize: 25.0
                        )
                        Spacer()
                        Text(score.date.formatted(date: .numeric, time: .omitted))
                            .font(.title2)
                            .foregroundStyle(Color.secondary)
                            .accessibilityLabel("\(symptomsType.fullName) Date: \(score.date.formatted(date: .numeric, time: .omitted))")
                    }
//                    .padding(.vertical, 4)
                }
            },
            header: {
                Text("All Data")
            }
        )
        
        
//        Section(
//            content: {
//                // Symptom Scores List or Graph
//                SymptomsHistoryView(symptomType: symptomsType, format: recordFormat)
//                
//                // Picker for changing the symptoms type
//                SymptomsPicker(symptomsType: $symptomsType)
//                
//                // Symptoms description
//                HeartHealthCaption(
//                    title: "Description",
//                    descriptionKey: LocalizedStringKey(symptomsType.explanationKey)
//                )
//            },
//            header: {
//                // Header with picker for score type
//                HStack {
//                    Text(symptomsType.fullName)
//                        .studyApplicationHeaderStyle()
//                    Spacer()
//                    RecordFormatPicker(recordFormat: $recordFormat)
//                }
//            }
//        )
    }
}


#Preview {
    SymptomsContentView()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
