//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum DateGranularity: CustomStringConvertible, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        }
    }
    
    var defaultDateUnit: Calendar.Component {
        switch self {
        case .daily: .day
        case .weekly: .weekOfYear
        case .monthly: .month
        }
    }
    
    
    /// Instantiates the date domain determined by the granularity and relative to the current date
    /// Returns a date range expanded to the neartest interval to the boundary dates determined by the granularity
    func getDateRange(endDate: Date) -> ClosedRange<Date> {
        let calendar = Calendar.current
        
        /// The range of dates determined by the granularity
        var dateRange: DateInterval {
            /// Get range according to the granularity and relative to the current date
            let startDate: Date? = switch self {
            case .daily:
                calendar.date(byAdding: .day, value: -30, to: endDate)
            case .weekly:
                calendar.date(byAdding: .month, value: -3, to: endDate)
            case .monthly:
                calendar.date(byAdding: .month, value: -6, to: endDate)
            }
            
            guard let startDate else {
                return DateInterval(start: endDate, end: endDate)
            }
            return DateInterval(start: startDate, end: endDate)
        }
        
        /// The final date range to display
        /// Expand the ends to the nearest interval
        guard let upperBoundDate = calendar.dateInterval(of: self.defaultDateUnit, for: dateRange.end)?.end,
              let lowerBoundDate = calendar.dateInterval(of: self.defaultDateUnit, for: dateRange.start)?.start else {
            return endDate...endDate
        }
        return lowerBoundDate...upperBoundDate
    }
}
