//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import HealthKit
import SwiftUI


struct VitalsGraph: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    @Binding var selection: GraphSelection
    @Binding var dateResolution: Calendar.Component
    
    
    var body: some View {
        VStack {
            switch selection {
            case .weight:
                WeightAndHeartRateGraph(
                    data: vitalsManager.weightHistory,
                    units: vitalsManager.localMassUnits,
                    dateResolution: $dateResolution
                )
            case .heartRate:
                WeightAndHeartRateGraph(
                    data: vitalsManager.heartRateHistory,
                    units: .count().unitDivided(by: .minute()),
                    dateResolution: $dateResolution
                )
            case .bloodPressure:
                Text("Blood Pressure Here")
            default:
                Text("ERROR: Invalid graph selection.")
            }
            Text(String(describing: dateResolution))
        }
    }
}


#Preview("Weight") {
    VitalsGraph(selection: .constant(.weight), dateResolution: .constant(.day))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Heart Rate") {
    VitalsGraph(selection: .constant(.heartRate), dateResolution: .constant(.day))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Blood Pressure") {
    VitalsGraph(selection: .constant(.bloodPressure), dateResolution: .constant(.day))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
