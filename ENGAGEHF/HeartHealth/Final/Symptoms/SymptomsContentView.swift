//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsContentView: View {
    @Environment(VitalsManager.self) private var  vitalsManager
    @State private var symptomsType: SymptomsType = .overall
    
    @State private var symptomsType1: SymptomsType = .overall
    
    
    private var listDisplayData: [VitalMeasurement] {
        let keyPath = symptomsType1.symptomScoreKeyMap
        print("Reloading List Display Data")
        return vitalsManager.symptomHistory
            .map { score in
                VitalMeasurement(
                    id: score.id,
                    value: String(format: "%.1f", score[keyPath: keyPath]),
                    date: score.date
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    
    var body: some View {
        SymptomsGraphSection(symptomsType: $symptomsType)
        DescriptionSection(explanationKey: symptomsType.explanationKey)
        SymptomsListSection(
            data: listDisplayData,
            units: "%",
            type: .symptoms
        )
        .onChange(of: symptomsType) { symptomsType1 = symptomsType }
    }
    
    
    private func getDisplayInfo(for type: SymptomsType) -> [VitalMeasurement] {
        vitalsManager.symptomHistory
            .compactMap { score in
                VitalMeasurement(
                    id: score.id,
                    value: String(format: "%.1f", score[keyPath: symptomsType.symptomScoreKeyMap]),
                    date: score.date
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
}


#Preview {
    SymptomsContentView()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
