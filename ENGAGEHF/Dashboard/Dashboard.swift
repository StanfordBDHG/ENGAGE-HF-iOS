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
    @Environment(WeightScaleDevice.self) private var weightScale: WeightScaleDevice?
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Greeting()
                Spacer()
                
                HStack {
                    Circle()
                        .fill(weightScale == nil ? Color.gray : Color.green)
                        .frame(width: 10, height: 10)
                        .padding()
                    Text(String(Double(weightScale?.service.weightMeasurement?.weight ?? 0) / 100))
                }
                Spacer()
            }
                .navigationTitle("Home")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
}


#Preview {
    Dashboard(presentingAccount: .constant(false))
}
