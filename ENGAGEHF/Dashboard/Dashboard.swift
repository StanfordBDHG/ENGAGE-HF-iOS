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

    @Environment(MeasurementManager.self) private var measurementManager

    
    var body: some View {
        NavigationStack {
            VStack {
                Greeting()
                Spacer()
            }
                .navigationTitle("Home")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .toolbar {
                    if FeatureFlags.testMockDevices {
                        ToolbarItemGroup(placement: .secondaryAction) {
                            Button("Trigger Weight Measurement", systemImage: "scalemass.fill") {
                                measurementManager.loadMockWeightMeasurement()
                            }
                            Button("Trigger Blood Pressure Measurement", systemImage: "drop.fill") {
                                measurementManager.loadMockBloodPressureMeasurement()
                            }
                        }
                    }
                }
        }
    }
}


#if DEBUG
#Preview {
    Dashboard(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
#endif
