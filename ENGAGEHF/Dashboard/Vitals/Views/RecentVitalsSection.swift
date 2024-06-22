//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import HealthKitOnFHIR
import SwiftUI


struct HRRow: View {
    var sample: HKQuantitySample?
    
    var body: some View {
        Text("Heart Rate")
    }
}


struct BPRow: View {
    var sample: HKQuantitySample?
    
    var body: some View {
        Text("Blood Pressure")
    }
}


struct WeightRow: View {
    var sample: HKQuantitySample?
    
    var body: some View {
        Text("Weight")
    }
}


struct RecentVitalsSection: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    var body: some View {
        Section("Weight") {
            ForEach(vitalsManager.weightHistory) { weightSample in
                VStack {
                    HStack {
                        Text("Measurement: ")
                            .bold()
                        Text(weightSample.quantity.description)
                        Spacer()
                    }
                    HStack {
                        Text("Start Date: ")
                            .bold()
                        Text(weightSample.startDate, format: .dateTime)
                        Spacer()
                    }
                    HStack {
                        Text("End Date: ")
                            .bold()
                        Text(weightSample.endDate, format: .dateTime)
                        Spacer()
                    }
                }
            }
        }
        .headerProminence(.increased)
        Section("Heart Rate") {
            ForEach(vitalsManager.heartRateHistory) { heartRateSample in
                VStack {
                    HStack {
                        Text("Measurement: ")
                            .bold()
                        Text(heartRateSample.quantity.description)
                        Spacer()
                    }
                    HStack {
                        Text("Start Date: ")
                            .bold()
                        Text(heartRateSample.startDate, format: .dateTime)
                        Spacer()
                    }
                    HStack {
                        Text("End Date: ")
                            .bold()
                        Text(heartRateSample.endDate, format: .dateTime)
                        Spacer()
                    }
                }
            }
        }
        .headerProminence(.increased)
        Section("Blood Pressure") {
            ForEach(vitalsManager.bloodPressureHistory) { bloodPressureSample in
                VStack {
                    BloodPressureMeasurementLabel(bloodPressureSample)
                    HStack {
                        Text("Start Date: ")
                            .bold()
                        Text(bloodPressureSample.startDate, format: .dateTime)
                        Spacer()
                    }
                    HStack {
                        Text("End Date: ")
                            .bold()
                        Text(bloodPressureSample.endDate, format: .dateTime)
                        Spacer()
                    }
                }
            }
        }
        .headerProminence(.increased)
    }
    
    private func getDisplay(sample: HKCorrelation) {
        
    }
}

#Preview {
    RecentVitalsSection()
        .previewWith {
            VitalsManager()
        }
}
