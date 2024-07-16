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
    
    var intervalComponent: Calendar.Component {
        switch self {
        case .daily: .day
        case .weekly: .weekOfYear
        case .monthly: .month
        }
    }
    
    
    func getDateInterval(endDate: Date) throws -> DateInterval {
        let calendar = Calendar.current
        
        
        let startDate: Date? = switch self {
        case .daily:
            calendar.date(byAdding: .day, value: -30, to: endDate)
        case .weekly:
            calendar.date(byAdding: .month, value: -3, to: endDate)
        case .monthly:
            calendar.date(byAdding: .month, value: -6, to: endDate)
        }
        
        guard let startDate else {
            throw HeartHealthError.invalidDate(endDate)
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
}
