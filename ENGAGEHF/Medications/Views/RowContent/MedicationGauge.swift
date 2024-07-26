//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationGauge: View {
    private struct GaugeLabel: View {
        let dose: Double
        let unit: String
        
        
        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(dose.asString())
                    .font(.subheadline.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    
    let currentDose: Double
    let minimumDose: Double
    let targetDose: Double
    let unit: String
    
    
    var body: some View {
        Gauge(value: currentDose, in: minimumDose...targetDose) {
            // No overall label
        } currentValueLabel: {
            // No current value label
        } minimumValueLabel: {
            GaugeLabel(dose: minimumDose, unit: unit)
                .frame(minWidth: 50)
        } maximumValueLabel: {
            GaugeLabel(dose: targetDose, unit: unit)
                .frame(minWidth: 50)
        }
            .gaugeStyle(.linearCapacity)
    }
}


#Preview {
    MedicationGauge(currentDose: 10, minimumDose: 0, targetDose: 100, unit: "mg")
}
