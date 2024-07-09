//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsListSection: View {
    @State private var actualListData: [VitalMeasurement] = []
    
    var data: [VitalMeasurement]
    var units: String
    var type: GraphSelection
    
    @Environment(VitalsManager.self) private var vitalsManager
    
    
    var body: some View {
        Section(
            content: {
                if !actualListData.isEmpty {
                    ForEach(actualListData, id: \.id) { measurement in
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
        .task { actualListData = data }
        .onChange(of: data.map(\.id)) { actualListData = data }
    }
    
    private func deleteIndices(indexSet: IndexSet) {
        var collectionID: CollectionID {
            switch type {
            case .symptoms: .kccqResults
            case .weight: .bodyWeightObservations
            case .heartRate: .heartRateObservations
            case .bloodPressure: .bloodPressureObservations
            }
        }
        
        for idx in indexSet {
            let objectToRemove = actualListData[idx]
            actualListData.remove(at: idx)
            
            if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.disableFirebase {
                vitalsManager.symptomHistory.removeAll {
                    $0.id == objectToRemove.id
                }
            } else {
                Task {
                    await vitalsManager.deleteMeasurement(
                        id: objectToRemove.id,
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
            VitalMeasurement(id: "TEST4", value: "120.4", date: .now)
        ],
        units: "lbs",
        type: .weight
    )
}
