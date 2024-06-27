//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class ModelsR4.Period


extension Period {
    /// Retrieve the start and end date/times of the period, if present, converting from FHIRPrimitive<DateTime> to Date
    /// Period represents a potentially indefinite time interval
    /// Must have a start date - end date optional (if no end date present, it is set to distantFuture)
    func getDates() -> (start: Date, end: Date)? {
        guard let startDate = self.start?.value?.getDate() else {
            return nil
        }
        
        if let endDate = self.end?.value?.getDate() {
            return (startDate, endDate)
        }
        
        return (startDate, Date.distantFuture)
    }
}
