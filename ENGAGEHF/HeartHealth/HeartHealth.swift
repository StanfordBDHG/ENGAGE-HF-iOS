//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport) import SpeziAccount
import SpeziViews
import SwiftUI


struct HeartHealth: View {
    @Binding var presentingAccount: Bool
    
    @Environment(NavigationManager.self) private var navigationManager
    
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        
        NavigationStack {
            VStack(alignment: .trailing) {
                GraphPicker(selection: $navigationManager.heartHealthVitalSelection)
                    .padding(.horizontal)
                VitalsList(vitalSelection: navigationManager.heartHealthVitalSelection)
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
            AccountConfiguration(service: InMemoryAccountService())
            VitalsManager()
            NavigationManager()
        }
}
