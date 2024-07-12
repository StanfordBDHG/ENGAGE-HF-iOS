//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct HKSampleGraph: View {
    var data: [HKSample]
    var dateRange: DateInterval
    var granularity: Calendar.Component
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


#Preview {
    let granularity = DateGranularity.daily
    
    return HKSampleGraph(
        data: [],
        dateRange: {
            do {
                return try granularity.getDateInterval(endDate: .now)
            } catch {
                print(error.localizedDescription)
                return DateInterval(start: .now, end: .now)
            }
        }(),
        granularity: granularity.intervalComponent
    )
}
