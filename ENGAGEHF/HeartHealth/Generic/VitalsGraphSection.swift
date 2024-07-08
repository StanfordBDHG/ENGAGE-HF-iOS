//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VitalsGraphSection: View {
    @Binding var symptomsType: SymptomsType
    var vitalType: GraphSelection
    
    @State private var dateResolution: DisplayDateResolution = .daily
    
    
    var body: some View {
        Section(
            content: {
                Text("Content")
            },
            header: {
                HStack {
                    if vitalType == .symptoms {
                        SymptomsPicker(symptomsType: $symptomsType)
                    } else {
                        Text(vitalType.description)
                    }
                    Spacer()
//                    ResolutionPicker(selection: $dateResolution)
                }
            }
        )
    }
}


//#Preview {
//    VitalsGraphSection()
//        .previewWith(standard: ENGAGEHFStandard()) {
//            VitalsManager()
//        }
//}
