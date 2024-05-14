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
    @State private var recentWeight: HKQuantitySample?
    @State private var recentBP: HKQuantitySample?
    @State private var recentHR: HKQuantitySample?
    
    
    var body: some View {
        Section("Most Recent Vitals") {
            WeightRow(sample: recentWeight)
            BPRow(sample: recentBP)
            HRRow(sample: recentHR)
        }
        .headerProminence(.increased)
    }
    
    // TODO: Add compatability with measurements other than Weight
    func getMostRecent(of sampleType: HKSampleType) async throws {
        
    }
}

#Preview {
    RecentVitalsSection()
}
