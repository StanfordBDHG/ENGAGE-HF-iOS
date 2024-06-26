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
    public func getEffectiveDate() -> (start: Date, end: Date)? {
        guard let effective else {
            return nil
        }
        
        switch effective {
        case .dateTime(let dateTime):
            /// .dateTime represents a single point in time, so startDate = endDate
            /// Convert FHIRPrimitive<DateTime> to Date, if present
            if let startDate = dateTime.value?.getDate() {
                return (startDate, startDate)
            }
        case .instant(let instant):
            /// .instant represents a single, precise point in time, so startDate = endDate
            /// Convert FHIRPrimitive<Instant> to Date, if present
            if let startDate = instant.value?.getDate() {
                return (startDate, startDate)
            }
        case .period(let period):
            /// .period represents a potentially indefinite time interval
            /// Must have a start date - end date optional
            return period.getDates()
        case .timing:
            /// .timing represents a repeating schedule of events
            /// Future work: Interpret .timing to accurately set start/end date in this format
            return nil
        }
        
        return nil
    }
}
