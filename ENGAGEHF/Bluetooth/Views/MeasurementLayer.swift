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
    private let measurementTextSize: CGFloat = 60
    private let subTitleSize: CGFloat = 25
    
    
    var body: some View {
        VStack(spacing: 15) {
            Text(measurementManager.newMeasurement?.quantity.description ?? "???")
                .font(.system(size: measurementTextSize, weight: .bold, design: .rounded))
            Text("Measurement Recorded")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}


#Preview {
    PreviewWrapperMeasurementLayer()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
