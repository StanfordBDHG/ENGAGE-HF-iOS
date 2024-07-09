//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsListSection: View {
    var data: [VitalMeasurement]
    var units: String
    var type: GraphSelection
    
    @Environment(VitalsManager.self) private var vitalsManager
    
    
    var body: some View {
        Section(
            content: {
                if !data.isEmpty {
                    ForEach(data, id: \.id) { measurement in
                        SymptomsListRow(
                            displayQuantity: measurement.value,
                            displayUnit: units,
                            displayDate: measurement.date.formatted(date: .abbreviated, time: .omitted),
                            type: type.description
                        )
                    }
                    .onDelete { indexSet in
                        deleteIndices(indexSet: indexSet)
                    }
                } else {
                    Text("No \(type.description) available.")
                        .font(.caption)
                }
            },
            header: {
                Text("All Data")
            }
        )
    }
    
    private func deleteIndices(indexSet: IndexSet) {
        var collectionID: String {
            switch type {
            case .symptoms: "kccqResults"
            case .weight: "bodyWeightObservations"
            case .heartRate: "heartRateObservations"
            case .bloodPressure: "bloodPressureObservations"
            }
        }
        
        for idx in indexSet {
            if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.disableFirebase {
                vitalsManager.symptomHistory.removeAll {
                    $0.id == data[idx].id
                }
            } else {
                Task {
                    await vitalsManager.deleteMeasurement(
                        id: data[idx].id,
                        collectionID: collectionID
                    )
                }
            }
        }
    }
}


#Preview {
    SymptomsListSection(
        data: [
            VitalMeasurement(id: "TEST1", value: "60", date: .now),
            VitalMeasurement(id: "TEST2", value: "54", date: .now),
            VitalMeasurement(id: "TEST3", value: "25.0", date: .now),
            VitalMeasurement(id: "TEST4", value: "120.4", date: .now),
        ],
        units: "lbs",
        type: .weight
    )
}
