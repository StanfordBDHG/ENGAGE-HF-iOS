//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TextualDosageSummary: View {
    let dosageInformation: DosageInformation
    
    
    private var currentDisplay: String {
        dosageInformation.doses
            .map {
                $0.current.asString()
            }
            .joined(separator: "/")
    }
    
    private var targetDisplay: String {
        dosageInformation.doses
            .map {
                $0.target.asString()
            }
            .joined(separator: "/")
    }
    
    
    var body: some View {
        VStack {
            DoseSummary(type: "Current", value: currentDisplay, unit: dosageInformation.unit)
            DoseSummary(type: "Target", value: targetDisplay, unit: dosageInformation.unit)
        }
    }
}


#Preview {
    TextualDosageSummary(
        dosageInformation: DosageInformation(
            doses: [Dose(current: 50, minimum: 0, target: 100)],
            unit: "mg"
        )
    )
}
