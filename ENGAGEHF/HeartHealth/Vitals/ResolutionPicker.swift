//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ResolutionPicker: View {
    @Binding var selection: DateGranularity
    
    
    var body: some View {
        Picker("Resolution Picker", selection: $selection) {
            ForEach(DateGranularity.allCases) { resolution in
                Text(resolution.description)
            }
        }
    }
}


#Preview {
    ResolutionPicker(selection: .constant(.daily))
}
