//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import struct ModelsR4.Instant


extension Instant {
    var dateComponents: DateComponents {
        var components = DateComponents()
        components.year = self.date.year
        components.month = Int(self.date.month)
        components.day = Int(self.date.day)
        components.hour = Int(self.time.hour)
        components.minute = Int(self.time.minute)
        components.second = self.time.second.intValue
        components.nanosecond = self.time.second.fracValue
        components.timeZone = self.timeZone
        
        return components
    }
}
