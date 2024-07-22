//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct TriggerNewMeasurementButton: View {
    var measurementType: GraphSelection
    @Binding var addingMeasurement: GraphSelection?
    
    
    var body: some View {
        Button(
            action: {
                addingMeasurement = measurementType
            },
            label: {
                Image(systemName: "plus")
                    .accessibilityLabel("Add Measurement: \(measurementType.description)")
            }
        )
    }
}


#Preview {
    TriggerNewMeasurementButton(measurementType: .weight, addingMeasurement: .constant(nil))
}
