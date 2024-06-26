//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct VitalsContentHeader: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    @Binding var dateResolution: Calendar.Component
    var selection: GraphSelection
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(String(describing: selection))
                    .studyApplicationHeaderStyle()
                Spacer()
                Picker("Date Resolution", selection: $dateResolution) {
                    Text("Daily").tag(Calendar.Component.day)
                    Text("Weekly").tag(Calendar.Component.weekOfYear)
                    Text("Monthly").tag(Calendar.Component.month)
                }
            }
            if selection == .weight {
                Text(vitalsManager.localMassUnits.unitString)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else if selection == .heartRate {
                Text("bpm")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else if selection == .bloodPressure {
                Text("mmHg")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                Text("Error")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
            .padding()
    }
}


#Preview {
    struct VitalsContentHeaderPreviewWrapper: View {
        @State var dateResolution: Calendar.Component = .day
        @State var selection: GraphSelection = .weight
        
        
        var body: some View {
            VStack {
                VitalsContentHeader(dateResolution: $dateResolution, selection: selection)
                Text("Date type: \(String(describing: dateResolution))")
            }
        }
    }

    return VitalsContentHeaderPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
