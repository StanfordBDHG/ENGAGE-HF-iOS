//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI


struct StudyConcluded: View {
    @Binding var presentingAccount: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Icon()
                    .padding()
                Text(
                    """
                    Thank you for participating in the ENGAGE-HF Study!
                    """
                )
                    .multilineTextAlignment(.center)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color(.systemGroupedBackground))
                .navigationTitle("ENGAGE-HF")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
}


#if DEBUG
#Preview {
    StudyConcluded(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
