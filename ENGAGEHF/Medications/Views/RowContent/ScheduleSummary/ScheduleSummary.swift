//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ScheduleSummary: View {
    let schedule: [DoseSchedule]
    let unit: String
    let label: String
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            VStack(alignment: .trailing) {
                ForEach(schedule, id: \.self) { dosageSchedule in
                    HStack(alignment: .firstTextBaseline) {
                        HStack(spacing: 2) {
                            Text(formatDisplayQuantity(dosageSchedule))
                            Text(unit)
                        }
                        Text(formatDisplayFrequency(dosageSchedule))
                    }
                }
            }
        }
    }
    
    
    private func formatDisplayQuantity(_ schedule: DoseSchedule) -> String {
        schedule.quantity
            .map { $0.asString() }
            .joined(separator: "/")
    }
    
    private func formatDisplayFrequency(_ schedule: DoseSchedule) -> String {
        switch schedule.frequency {
        case 1: "daily"
        case 2: "twice daily"
        default: "\(schedule.frequency.asString())x daily"
        }
    }
}


#Preview {
    ScheduleSummary(
        schedule: [DoseSchedule(frequency: 2, quantity: [25])],
        unit: "mg",
        label: "Test Schedule:"
    )
}
