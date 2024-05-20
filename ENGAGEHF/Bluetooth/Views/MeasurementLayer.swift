//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct PreviewWrapperMeasurementLayer: View {
    @Environment(MeasurementManager.self) private var measurementManager
    
    
    var body: some View {
        MeasurementLayer()
            .onAppear {
                measurementManager.loadMockMeasurement()
            }
    }
}


struct MeasurementLayer: View {
    @Environment(MeasurementManager.self) private var measurementManager
    @ScaledMetric private var measurementTextSize: CGFloat = 60
    
    
    var body: some View {
        VStack(spacing: 15) {
            Text(measurementManager.newMeasurement?.quantity.description ?? "???")
                .font(.system(size: measurementTextSize, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Text("Measurement Recorded")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}


#Preview {
    PreviewWrapperMeasurementLayer()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
