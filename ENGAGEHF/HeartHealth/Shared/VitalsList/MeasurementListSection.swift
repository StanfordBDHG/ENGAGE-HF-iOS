//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziViews
import SwiftUI


struct MeasurementListSection: View {
    private let data: [VitalListMeasurement]
    private let units: String?
    private let type: GraphSelection

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
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "server.rack",
                        description: Text(type.localizedEmptyHistoryWarning)
                    )
                        .symbolVariant(.slash)
                        .accessibilityLabel("Empty \(type) List")
                }
            },
            header: {
                MeasurementListHeader(for: type)
                    .padding(.horizontal, -16)
            }
        )
            .viewStateAlert(state: $viewState)
    }


    init(data: [VitalListMeasurement], units: String?, type: GraphSelection) {
        self.data = data
        self.units = units
        self.type = type
    }


    private func deleteIndices(indexSet: IndexSet) throws {
        guard !ProcessInfo.processInfo.isPreviewSimulator && !FeatureFlags.disableFirebase else {
            for idx in indexSet {
                let objectToRemove = data[idx]
                vitalsManager.symptomHistory.removeAll {
                    $0.id == objectToRemove.id
                }
            }
            return
        }
        
        
        for idx in indexSet {
            let objectToRemove = data[idx]
            
            Task {
                try await vitalsManager.deleteMeasurement(
                    id: objectToRemove.id,
                    graphSelection: type
                )
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
