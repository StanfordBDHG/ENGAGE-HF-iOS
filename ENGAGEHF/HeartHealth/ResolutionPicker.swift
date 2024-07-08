//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ResolutionPicker: View {
    @Binding var selection: Calendar.Component
    
    
    var body: some View {
        Picker("Resolution Picker", selection: $selection) { 
            Text("Daily").tag(Calendar.Component.day)
            Text("Weekly").tag(Calendar.Component.weekOfYear)
            Text("Monthly").tag(Calendar.Component.month)
        }
    }
}


#Preview {
    ResolutionPicker(selection: .constant(.day))
}
