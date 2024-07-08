//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsHistoryView: View {
    var symptomType: SymptomsType
    var resolution: Calendar.Component = .day
    
    @Environment(VitalsManager.self) private var vitalsManager
    
    
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
            .sorted {
                $0.date > $1.date
            }
    }
    
    
    var body: some View {
        if !data.isEmpty {
            SymptomsHistoryGraph(
                data: data,
                symptomType: symptomType,
                startDate: dateRangeStart,
                endDate: dateRangeEnd
            )
        } else {
            StudyApplicationListCard {
                Text("No recent symptom scores available.")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}


#Preview {
    SymptomsHistoryView(symptomType: .overall)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
