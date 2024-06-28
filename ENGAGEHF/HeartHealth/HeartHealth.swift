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
                VStack(alignment: .center) {
                    GraphPicker(selection: $vitalSelection)
                    HeartHealthContentView(selection: vitalSelection)
                        .padding()
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
