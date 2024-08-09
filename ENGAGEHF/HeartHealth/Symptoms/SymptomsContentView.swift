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
    
    
    private var listDisplayData: [VitalListMeasurement] {
        vitalsManager.symptomHistory
            .map { score in
                VitalListMeasurement(
                    id: score.id,
                    // TODO: If this is dizziness, format it as an integer and have no "%" unit in list or graph
                    // TODO: Otherwise, keep the percentage and double formatting
                    value: score[keyPath: symptomsType.symptomScoreKeyMap].map { String(format: "%.1f", $0) },
                    date: score.date
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    
    var body: some View {
        SymptomsGraphSection(symptomsType: $symptomsType)
        DescriptionSection(
            localizedExplanation: symptomsType.localizedExplanation,
            quantityName: symptomsType.fullName
        )
        MeasurementListSection(
            data: listDisplayData,
            units: nil,
            type: .symptoms
        )
            .deleteDisabled(true)
    }
}


#Preview {
    SymptomsContentView()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
