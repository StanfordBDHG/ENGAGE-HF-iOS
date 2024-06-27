//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct HeartHealthContentView: View {
    var selection: GraphSelection
    
    
    var body: some View {
        VStack {
            VitalsGraph(for: selection)
            HeartHealthCaption(describing: selection)
            // TODO: Consider VitalsRecord here, listing measurements w option to delete
        }
    }
}

#Preview("Symptoms") {
    HeartHealthContentView(selection: .symptoms)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Weight") {
    HeartHealthContentView(selection: .weight)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Heart Rate") {
    HeartHealthContentView(selection: .heartRate)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Blood Pressure") {
    HeartHealthContentView(selection: .bloodPressure)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
