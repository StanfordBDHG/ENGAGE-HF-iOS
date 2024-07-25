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
    var data: [VitalListMeasurement]
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
                    Text(type.localizedEmptyHistoryWarning)
                        .font(.caption)
                        .accessibilityLabel("Empty \(type) List")
                }
            },
            header: {
                MeasurementListHeader(for: type)
            }
        )
            .viewStateAlert(state: $viewState)
    }
    
    
    private func deleteIndices(indexSet: IndexSet) throws {
        var collectionID: CollectionID {
            switch type {
            case .symptoms: .symptomScores
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
            VitalListMeasurement(id: "TEST1", value: "60", date: .now),
            VitalListMeasurement(id: "TEST2", value: "54", date: .now),
            VitalListMeasurement(id: "TEST3", value: "25.0", date: .now),
            VitalListMeasurement(id: "TEST4", value: "120.4", date: .now)
        ],
        units: "lbs",
        type: .weight
    )
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
