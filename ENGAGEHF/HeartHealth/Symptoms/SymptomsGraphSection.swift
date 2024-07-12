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
    
    @Environment(VitalsManager.self) private var vitalsManager
    private var resolution: DateGranularity = .weekly
    
    
    private var dateInterval: DateInterval {
        do {
            return try resolution.getDateInterval(endDate: .now)
        } catch {
            return DateInterval(start: .now, end: .now)
        }
    }
    
    private var data: [SymptomScore] {
        vitalsManager.symptomHistory
            .filter {
                dateInterval.contains($0.date)
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    
    var body: some View {
        Section(
            content: {
                if !data.isEmpty {
                    SymptomsGraph(
                        data: data,
                        granularity: resolution,
                        symptomType: symptomsType
                    )
                } else {
                    Text("No recent symptom scores available.")
                        .font(.caption)
                }
            },
            header: {
                SymptomsPicker(symptomsType: $symptomsType)
            }
        )
    }
}


#Preview {
    SymptomsGraphSection(symptomsType: .constant(.overall))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
