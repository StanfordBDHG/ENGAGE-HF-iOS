//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CurrentDosageSummary: View {
    let dosageInformation: DosageInformation
    
    
    private var minimumTotalDose: Double {
        dosageInformation.doses.map(\.minimum).reduce(0, +)
    }
    
    private var currentTotalDose: Double {
        dosageInformation.doses.map(\.current).reduce(0, +)
    }
    
    private var targetTotalDose: Double {
        dosageInformation.doses.map(\.target).reduce(0, +)
    }
    
    
    var body: some View {
        VStack {
            TextualDosageSummary(dosageInformation: dosageInformation)
                .padding(.vertical, 2)
            Gauge(value: currentTotalDose, in: minimumTotalDose...targetTotalDose, label: {})
                .padding(.vertical, 2)
        }
        
        
        
        // Gauge Drafts:
            // Only one guage featuring the total daily dose (combined across subcomponents)
//            MedicationGauge(
//                currentDose: dosageInformation.doses.map(\.current).reduce(0, +),
//                minimumDose: dosageInformation.doses.map(\.minimum).reduce(0, +),
//                targetDose: dosageInformation.doses.map(\.target).reduce(0, +),
//                unit: dosageInformation.unit
//            )
//            .padding(.vertical, 2)
            // One guage per subcomponent
//            ForEach(medication.dosageInformation.doses, id: \.self) { dose in
//                MedicationGauge(
//                    currentDose: dose.current,
//                    minimumDose: dose.minimum,
//                    targetDose: dose.target,
//                    unit: medication.dosageInformation.unit
//                )
//            }
//                .padding(.vertical, 2)
    }
}


#Preview {
    CurrentDosageSummary(
        dosageInformation: DosageInformation(
            doses: [Dose(current: 50, minimum: 24, target: 60)],
            unit: "mg"
        )
    )
}
