//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct Dashboard: View {
    @Binding var presentingAccount: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Greeting()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("ENGAGE-HF: Home")  // Todo: Make this white
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AccountButton(isPresented: $presentingAccount)
                        .foregroundColor(.white)
                        .accessibilityLabel(Text("DASHBOARD_ACC_BTN"))
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("AccentColor"), for: .navigationBar)
        }
    }
}

#Preview {
    @State var presentingAccount = false
    return Dashboard(presentingAccount: $presentingAccount)
}
