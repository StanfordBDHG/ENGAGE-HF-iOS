//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class ModelsR4.Timing


extension Timing {
    /// Returns the start and end date/times of the scheduled or repeated event as Dates
    /// Takes the earliest of the event dates as the start, and sets the end as indefinite (distantFuture)
    func getDates() -> (start: Date, end: Date)? {
        if let events = self.event {
            let dates = events.compactMap {
                $0.value?.getDate()
            }
            
            if let startDate = dates.min() {
                return (startDate, Date.distantFuture)
            }
        }
        
        return nil
    }
}
