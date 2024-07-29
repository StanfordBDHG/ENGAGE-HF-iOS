//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CurrentScheduleSummary: View {
    let currentSchedule: [DoseSchedule]
    let unit: String
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Current Schedule:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            VStack(alignment: .trailing) {
                ForEach(currentSchedule, id: \.self) { dosageSchedule in
                    HStack(alignment: .firstTextBaseline) {
                        HStack(spacing: 2) {
                            Text(dosageSchedule.dose.asString())
                            Text(unit)
                        }
                        Text("\(dosageSchedule.timesDaily)x daily")
                    }
                }
            }
        }
    }
}


#Preview {
    CurrentScheduleSummary(
        currentSchedule: [DoseSchedule(timesDaily: 2, dose: 25)],
        unit: "mg"
    )
}
