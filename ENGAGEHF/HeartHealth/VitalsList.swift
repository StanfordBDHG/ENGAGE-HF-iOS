//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Spezi


struct VitalsList: View {
    let vitalSelection: GraphSelection
    
    
    var body: some View {
        List {
            switch vitalSelection {
            case .symptoms: SymptomsContentView()
            case .weight: VitalsContentView(for: .weight)
            case .heartRate: VitalsContentView(for: .heartRate)
            case .bloodPressure: VitalsContentView(for: .bloodPressure)
            }
        }
            .listStyle(.insetGrouped)
            .headerProminence(.increased)
    }
}


#Preview {
    VitalsList(vitalSelection: .symptoms)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
