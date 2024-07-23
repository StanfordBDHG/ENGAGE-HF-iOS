//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MeasurementListHeader: View {
    let measurementType: GraphSelection
    
    @State private var addingMeasurement: GraphSelection?
    
    
    var body: some View {
        HStack {
            Text("All Data")
                .font(.title3.bold())
            Spacer()
            if measurementType != .symptoms {
                TriggerNewMeasurementButton(
                    measurementType: measurementType,
                    addingMeasurement: $addingMeasurement
                )
            }
        }
            .sheet(
                item: $addingMeasurement,
                onDismiss: {
                    addingMeasurement = nil
                },
                content: { measurementType in
                    AddMeasurementView(for: measurementType)
                }
            )
    }
    
    
    init(for type: GraphSelection) {
        self.measurementType = type
    }
}


#Preview {
    MeasurementListHeader(for: .weight)
}
