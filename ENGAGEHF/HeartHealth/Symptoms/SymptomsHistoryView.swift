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
    var format: RecordFormat
    
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
    }
    
    
    var body: some View {
        switch format {
        case .list: SymptomsHistoryList(data: data, symptomType: symptomType)
        case .graph: Text("Graph") /*SymptomsHistoryGraph(data: data)*/
        }
    }
}


#Preview {
    SymptomsHistoryView(symptomType: .overall, format: .list)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
