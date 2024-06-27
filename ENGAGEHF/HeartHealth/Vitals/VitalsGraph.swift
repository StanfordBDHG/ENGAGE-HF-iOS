//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VitalsGraph: View {
    @Environment(VitalsManager.self) private var vitalsManager
    var vitalsType: GraphSelection
    
    
    var body: some View {
        Text("Temp")
//        switch vitalsType {
//        case .symptoms: SymptomGraph(data: vitalsManager.symptomHistory)
//        }
    }
    
    
    init(for vitalsType: GraphSelection) {
        self.vitalsType = vitalsType
    }
}


#Preview("Symptoms") {
    VitalsGraph(for: .symptoms)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Weight") {
    VitalsGraph(for: .weight)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Heart Rate") {
    VitalsGraph(for: .heartRate)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Blood Pressure") {
    VitalsGraph(for: .bloodPressure)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
