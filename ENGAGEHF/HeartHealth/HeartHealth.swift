//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct HeartHealth: View {
    @Binding var presentingAccount: Bool
    
    @Environment(VitalsManager.self) private var vitalsManager
    @State private var vitalSelection: GraphSelection = .symptoms
    @State private var addingMeasurement: GraphSelection?
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                GraphPicker(selection: $vitalSelection)
                    .padding(.horizontal)
                VitalsList(vitalSelection: vitalSelection, addingMeasurement: $addingMeasurement)
            }
                .navigationTitle("Heart Health")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .sheet(item: $addingMeasurement, onDismiss: { addingMeasurement = nil }) { measurementType in
                    AddMeasurementView(for: measurementType)
                }
        }
    }
}


#Preview {
    HeartHealth(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
