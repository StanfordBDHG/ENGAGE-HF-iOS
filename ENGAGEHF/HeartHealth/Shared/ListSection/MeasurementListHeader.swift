//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MeasurementListHeader: View {
    let addingEnabled: Bool
    let measurementType: GraphSelection
    @Binding var addingMeasurement: GraphSelection?
    
    
    var body: some View {
        HStack {
            Text("All Data")
                .font(.title3.bold())
            Spacer()
            if addingEnabled {
                TriggerNewMeasurementButton(measurementType: measurementType, addingMeasurement: $addingMeasurement)
            }
        }
    }
    
    
    init(addingEnabled: Bool, for type: GraphSelection, addingMeasurement: Binding<GraphSelection?>) {
        self.addingEnabled = addingEnabled
        self.measurementType = type
        self._addingMeasurement = addingMeasurement
    }
}


#Preview {
    MeasurementListHeader(addingEnabled: true, for: .weight, addingMeasurement: .constant(nil))
}
