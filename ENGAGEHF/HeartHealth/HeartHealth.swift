//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HeartHealth: View {
    @Binding var presentingAccount: Bool
    @State private var vitalSelection: GraphSelection = .symptoms
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .trailing, spacing: 20) {
                    GraphPicker(selection: $vitalSelection)
                    switch vitalSelection {
                    case .symptoms: SymptomsContentView()
                    case .weight: VitalsContentView(for: .weight)
                    case .heartRate: VitalsContentView(for: .heartRate)
                    case .bloodPressure: VitalsContentView(for: .bloodPressure)
                    }
                }
                .padding(.horizontal)
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
