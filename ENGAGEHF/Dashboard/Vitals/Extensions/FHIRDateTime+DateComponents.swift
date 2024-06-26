//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import struct ModelsR4.DateTime


/// Include representatino of DateTime as DateComponents for easy conversion to Date type
extension DateTime {
    var dateComponents: DateComponents {
        var components = DateComponents()
        components.year = self.date.year
        
        if let months = self.date.month {
            components.month = Int(months)
        }
        if let days = self.date.day {
            components.day = Int(days)
        }
        
        if let time = self.time {
            components.hour = Int(time.hour)
            components.minute = Int(time.minute)
            components.second = time.second.intValue
            components.nanosecond = time.second.fracValue
        }
        
        components.timeZone = self.timeZone
        
        return components
    }
}


/// Convert DateTime to Date
extension DateTime {
    func getDate() -> Date? {
        Calendar.current.date(from: self.dateComponents)
    }
}
