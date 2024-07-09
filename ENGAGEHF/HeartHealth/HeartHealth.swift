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
    @State private var vitalSelection: GraphSelection = .symptoms
    
    @Environment(VitalsManager.self) private var vitalsManager
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                GraphPicker(selection: $vitalSelection)
                    .padding(.horizontal)
                VitalsList(vitalSelection: vitalSelection)
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
