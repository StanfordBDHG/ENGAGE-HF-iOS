//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension VitalsGraph {
    struct DefaultChartStyle: ViewModifier {
        var viewModel: ViewModel
        var dateRange: ClosedRange<Date>
        
        
        func body(content: Content) -> some View {
            content
                .chartXScale(domain: dateRange)
                .chartForegroundStyleScale(range: [Color.accentColor, Color.complement])
                .chartLegend(viewModel.multipleTypesPresent ? .visible : .hidden)
        }
    }
}
