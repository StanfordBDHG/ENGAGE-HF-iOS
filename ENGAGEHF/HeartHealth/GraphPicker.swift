//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct GraphPicker: View {
    @Binding var selection: GraphSelection
    
    var body: some View {
        Picker("Graph Selection", selection: $selection) {
            ForEach(GraphSelection.allCases) { selection in
                Text(String(describing: selection))
                    .multilineTextAlignment(.center)
            }
        }
            .pickerStyle(.segmented)
            .padding()
    }
}


#Preview {
    @State var selection: GraphSelection = .overview
    
    return GraphPicker(selection: $selection)
}
