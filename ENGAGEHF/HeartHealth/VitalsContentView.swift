//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct VitalsContentView: View {
    @ScaledMetric private var contentHeight: CGFloat = 150
    
    @State var currentSelection: GraphSelection
    @State var dateResolution: Calendar.Component = .day
    
    var body: some View {
        VStack {
            VitalsContentHeader(dateResolution: $dateResolution, selection: currentSelection)
            StudyApplicationListCard {
                if currentSelection == .overview {
                    SymptomOverview()
                } else {
                    VitalsGraph(selection: $currentSelection, dateResolution: $dateResolution)
                }
            }
                .frame(maxWidth: .infinity, idealHeight: contentHeight)
        }
            .padding()
    }
}

#Preview("Overview") {
    VitalsContentView(currentSelection: .overview)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Weight") {
    VitalsContentView(currentSelection: .weight)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Heart Rate") {
    VitalsContentView(currentSelection: .heartRate)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Blood Pressure") {
    VitalsContentView(currentSelection: .bloodPressure)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
