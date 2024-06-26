//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VitalsCardText<V>: View where V: ViewModifier {
    let quantityValue: String?
    let vitalType: String
    let component: String
    let style: V
    
    
    var body: some View {
        if let value = self.quantityValue {
            Text(value)
                .multilineTextAlignment(.leading)
                .accessibilityLabel("\(vitalType) \(component): \(value)")
                .modifier(style)
        } else {
            Text("No recent \(vitalType) \(component) available")
                .font(.caption)
                .multilineTextAlignment(.leading)
        }
    }
    
    
    init(quantityValue: String?, vitalType: String, component: String, style: V) {
        self.quantityValue = quantityValue
        self.vitalType = vitalType
        self.component = component
        self.style = style
    }
}


extension VitalsCardText where V == EmptyModifier {
    init(quantityValue: String?, vitalType: String, component: String) {
        self.quantityValue = quantityValue
        self.vitalType = vitalType
        self.component = component
        self.style = EmptyModifier()
    }
}


#Preview {
    VitalsCardText(quantityValue: "29.0", vitalType: "Weight", component: "Measurement")
}
