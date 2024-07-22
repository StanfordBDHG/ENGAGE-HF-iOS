//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VitalsList: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    var vitalSelection: GraphSelection
    @Binding var addingMeasurement: GraphSelection?
    
    
    var body: some View {
        List {
            switch vitalSelection {
            case .symptoms: SymptomsContentView()
            case .weight: VitalsContentView(for: .weight, addingMeasurement: $addingMeasurement)
            case .heartRate: VitalsContentView(for: .heartRate, addingMeasurement: $addingMeasurement)
            case .bloodPressure: VitalsContentView(for: .bloodPressure, addingMeasurement: $addingMeasurement)
            }
        }
            .listStyle(.insetGrouped)
            .headerProminence(.increased)
    }
}


#Preview {
    VitalsList(vitalSelection: .symptoms, addingMeasurement: .constant(nil))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
