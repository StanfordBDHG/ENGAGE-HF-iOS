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
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
}

#if DEBUG
#Preview {
    Dashboard(presentingAccount: .constant(false))
}
#endif
