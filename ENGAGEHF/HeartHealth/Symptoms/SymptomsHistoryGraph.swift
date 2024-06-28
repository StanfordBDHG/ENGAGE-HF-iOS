//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct SymptomsHistoryGraph: View {
    var data: [SymptomScore]
    var field: KeyPath<SymptomScore, Double>
    
    
    var body: some View {
        Chart(data) { score in
            LineMark(
                x: .value("Date", score.date, unit: .day),
                y: .value("Score", score[keyPath: field])
            )
        }
    }
}


#Preview {
    struct SymptomsHistoryGraphPreviewWrapper: View {
        @Environment(VitalsManager.self) private var vitalsManager
        var symptomType: SymptomsType
        
        
        // For now, take the measurements from the last month
        private var dateRangeStart: Date {
            Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        }

        private var dateRangeEnd: Date {
            .now
        }
        
        private var data: [SymptomScore] {
            vitalsManager.symptomHistory
                .filter {
                    (dateRangeStart...dateRangeEnd).contains($0.date)
                }
        }
        
        
        var body: some View {
            SymptomsHistoryGraph(data: data, field: symptomType.symptomScoreKeyMap)
        }
    }
    
    
    return SymptomsHistoryGraphPreviewWrapper(symptomType: .overall)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
