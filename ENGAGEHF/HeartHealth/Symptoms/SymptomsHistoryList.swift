//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsHistoryList: View {
    var data: [SymptomScore]
    var symptomType: SymptomsType
    
    
    var body: some View {
        ForEach(data) { score in
            StudyApplicationListCard {
                HeartHealthListRow(
                    quantity: String(format: "%.1f", score[keyPath: symptomType.symptomScoreKeyMap]),
                    units: "%",
                    date: score.date.formatted(date: .numeric, time: .omitted),
                    type: symptomType.fullName
                )
                .padding(4)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    struct SymptomsHistoryListPreviewWrapper: View {
        @Environment(VitalsManager.self) private var vitalsManager
        var symptomType: SymptomsType
        
        
        // For now, take the measurements from the last month
        private var dateRangeStart: Date {
            Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        }
        
        private var data: [SymptomScore] {
            vitalsManager.symptomHistory
                .filter {
                    (dateRangeStart ... Date.now).contains($0.date)
                }
        }
        
        
        var body: some View {
            List {
                Section(
                    content: {
                        SymptomsHistoryList(data: data, symptomType: symptomType)
                    },
                    header: {
                        HStack {
                            Text("Section Name")
                                .studyApplicationHeaderStyle()
                            Spacer()
                            Text("Picker")
                        }
                    }
                )
            }
        }
    }
    
    
    return SymptomsHistoryListPreviewWrapper(symptomType: .overall)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
