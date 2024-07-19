//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct VitalsGraphOptions: Identifiable, Equatable {
    static let defaultOptions = VitalsGraphOptions()
    
    
    let id = UUID()
    
    let dateRange: ClosedRange<Date>?
    let granularity: Calendar.Component
    let localizedUnitString: String
    let selectionFormatter: ([(String, Double)]) -> String
    
    init(
        dateRange: ClosedRange<Date>? = nil,
        granularity: Calendar.Component? = nil,
        localizedUnitString: String? = nil,
        selectionFormatter: (([(String, Double)]) -> String)? = nil
    ) {
        self.dateRange = dateRange
        self.granularity = granularity ?? .day
        self.localizedUnitString = localizedUnitString ?? "Units"
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
