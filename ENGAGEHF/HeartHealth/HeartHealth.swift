//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum GraphSelection: CaseIterable, Identifiable, CustomStringConvertible {
    case symptoms
    case weight
    case heartRate
    case bloodPressure
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .symptoms: "Overview"
        case .weight: "Weight"
        case .heartRate: "Heart Rate"
        case .bloodPressure: "Blood Pressure"
        }
    }
    
    var explanation: String {
        switch self {
        case .symptoms: "symptomOverall"
        case .weight: "vitalsWeight"
        case .heartRate: "vitalsHeartRate"
        case .bloodPressure: "vitalsBloodPressure"
        }
    }
}


struct HeartHealth: View {
    @Binding var presentingAccount: Bool
    @State private var vitalSelection: GraphSelection = .overview
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    GraphPicker(selection: $vitalSelection)
                    HeartHealthContentView(selection: vitalSelection)
                }
            }
                .navigationTitle("Heart Health")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .background(Color(.systemGroupedBackground))
        }
    }
}


#Preview {
    HeartHealth(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
