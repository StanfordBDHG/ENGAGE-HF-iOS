//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VitalsListSection<T: Graphable>: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    var storagePath: KeyPath<VitalsManager, [T]>
    
    
    var body: some View {
        Section(
            content: {
//                ForEach(vitalsManager[keyPath: storagePath]) { dataPoint in
//                    HeartHealthListRow(
//                        quantity: String()
//                    )
//                }
                Text("Blah")
            },
            header: {
                HStack {
                    Text("All Measurements")
                        .studyApplicationHeaderStyle()
                    Spacer()
                    AddMeasurementButton()
                }
            }
        )
    }
}


#Preview {
    VitalsListSection<SymptomScore>(storagePath: \.symptomHistory)
}
