//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class ModelsR4.Observation


extension Observation {
    /// Returns Observation.effective as a startDate and an endDate, if present, converting from FHIR Primitives to Swift Dates
    public func getEffectiveDate() -> (startDate: Date?, endDate: Date?) {
        guard let effective else {
            return (nil, nil)
        }
        
        switch effective {
        case .dateTime(let dateTime):
            // Convert FHIRPrimitive<DateTime> to Date
            if let fhirDateTime = dateTime.value {
                let startDate = Calendar.current.date(from: fhirDateTime.dateComponents)
                return (startDate, startDate)
            }
        case .instant(let instant):
            // Convert FHIRPrimitive<Instant> to Date
            if let fhirInstant = instant.value {
                let startDate = Calendar.current.date(from: fhirInstant.dateComponents)
                return (startDate, startDate)
            }
        case .period(let period):
            // Must have a start date - end date optional
            if let fhirStartDate = period.start?.value {
                let startDate = Calendar.current.date(from: fhirStartDate.dateComponents)
                
                // If end date is known, record it, otherwise mark as unknown
                var endDate: Date? = Date.distantFuture
                if let fhirEndDate = period.end?.value {
                    endDate = Calendar.current.date(from: fhirEndDate.dateComponents)
                }
                
                return (startDate, endDate)
            }
        case .timing(let timing):
            // timing.event is an optional array of FHIR DateTimes
            // Take the earliest of the dates as the start time
            if let events = timing.event {
                let dates = events.compactMap {
                    if let date = $0.value {
                        return Calendar.current.date(from: date.dateComponents)
                    }
                    return nil
                }
                    .sorted()
                
                if let startDate = dates.first {
                    return (startDate, Date.distantFuture)
                }
            }
        }
        
        return (nil, nil)
    }
}
