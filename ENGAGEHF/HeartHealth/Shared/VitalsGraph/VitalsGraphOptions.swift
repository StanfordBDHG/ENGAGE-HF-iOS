//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct VitalsGraphOptions: Identifiable, Equatable, Sendable {
    nonisolated static let defaultOptions = VitalsGraphOptions()
    
    
    let id = UUID()
    
    let dateRange: ClosedRange<Date>?
    let valueRange: ClosedRange<Double>?
    let targetValue: SeriesTarget?
    let granularity: Calendar.Component
    let localizedUnitString: String?
    let selectionFormatter: @Sendable ([(String, Double)]) -> String
    
    
    init(
        dateRange: ClosedRange<Date>? = nil,
        valueRange: ClosedRange<Double>? = nil,
        targetValue: SeriesTarget? = nil,
        granularity: Calendar.Component? = nil,
        localizedUnitString: String? = nil,
        selectionFormatter: (@Sendable ([(String, Double)]) -> String)? = nil
    ) {
        self.dateRange = dateRange
        self.valueRange = valueRange
        self.targetValue = targetValue
        self.granularity = granularity ?? .day
        self.localizedUnitString = localizedUnitString
        self.selectionFormatter = selectionFormatter ?? { selectedPoints in
            selectedPoints
                .map { _, value in
                    String(format: "%.1f", value)
                }
                .joined(separator: "/")
        }
    }
    
    
    static func == (lhs: VitalsGraphOptions, rhs: VitalsGraphOptions) -> Bool {
        lhs.id == rhs.id
    }
}
