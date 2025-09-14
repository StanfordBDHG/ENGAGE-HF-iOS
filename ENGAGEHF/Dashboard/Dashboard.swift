//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport) import SpeziAccount
@_spi(TestingSupport) import SpeziDevices
import SwiftUI


struct Dashboard: View {
    @Binding var presentingAccount: Bool
    
#if DEBUG
    @Environment(HealthMeasurements.self) private var measurements
#endif

    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // Messages
                    MessagesSection()
                    
                    // Most recent vitals
                    RecentVitalsSection()
                }
                    .padding()
            }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Home")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
#if DEBUG
                .toolbar {
                    if FeatureFlags.testMockDevices {
                        ToolbarItemGroup(placement: .secondaryAction) {
                            Button("Trigger Weight Measurement", systemImage: "scalemass.fill") {
                                measurements.loadMockWeightMeasurement()
                            }
                            Button("Trigger Blood Pressure Measurement", systemImage: "drop.fill") {
                                measurements.loadMockBloodPressureMeasurement()
                            }
                            Button("Show Measurements", systemImage: "heart.text.square") {
                                measurements.shouldPresentMeasurements = true
                            }
                        }
                    }
                }
#endif
        }
    }
}


#if DEBUG
#Preview {
    Dashboard(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration(service: InMemoryAccountService())
            MessageManager()
            HealthMeasurements(mock: [.weight(.mockWeighSample)])
            VitalsManager()
        }
}
#endif
