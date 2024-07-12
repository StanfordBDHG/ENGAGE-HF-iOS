//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct MeasurementListSection: View {
    var data: [VitalMeasurement]
    var units: String
    var type: GraphSelection
    
    @Environment(VitalsManager.self) private var vitalsManager
    @State private var viewState: ViewState = .idle
    
    
    var body: some View {
        Section(
            content: {
                if !data.isEmpty {
                    ForEach(data, id: \.id) { measurement in
                        MeasurementListRow(
                            displayQuantity: measurement.value,
                            displayUnit: units,
                            displayDate: measurement.date.formatted(date: .abbreviated, time: .omitted),
                            type: type.description
                        )
                    }
                    .onDelete { indexSet in
                        do {
                            try deleteIndices(indexSet: indexSet)
                        } catch {
                            viewState = .error(HeartHealthError.failedDeletion)
                        }
                    }
                } else {
                    Text("No \(type.description) available.")
                        .font(.caption)
                }
            },
            header: {
                Text("All Data")
                    .font(.title3.bold())
            }
        )
        .viewStateAlert(state: $viewState)
    }
    
    
    private func deleteIndices(indexSet: IndexSet) throws {
        var collectionID: CollectionID {
            switch type {
            case .symptoms: .kccqResults
            case .weight: .bodyWeightObservations
            case .heartRate: .heartRateObservations
            case .bloodPressure: .bloodPressureObservations
            }
        }
        
        for idx in indexSet {
            let objectToRemove = data[idx]
            
            if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.disableFirebase {
                vitalsManager.symptomHistory.removeAll {
                    $0.id == objectToRemove.id
                }
            } else {
                Task {
                    try await vitalsManager.deleteMeasurement(
                        id: objectToRemove.id,
                        collectionID: collectionID
                    )
                }
            }
        }
    }
}


#Preview {
    MeasurementListSection(
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
