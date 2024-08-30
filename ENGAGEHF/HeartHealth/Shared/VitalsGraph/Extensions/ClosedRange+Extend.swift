//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ClosedRange where Bound == Double {
    /// Extends the range by rounding the bounds to a multiple of 10, skipping `numSkipped` multiples in either direction.
    /// If `numSkipped` is equal to `0`, extends the range to the nearest multiple of ten on either side.
    /// If a bound is already a multiple of 10, then that counts as reaching a multiple of 10 (e.g. if `numSkipped` is 0, nothing will change).
    func extendToMultipleOf(_ target: Double, skipping numSkipped: Int = 0) -> Self {
        let newLowerBound = self.lowerBound.roundedToNthMultipleOf(target, skipping: numSkipped, rule: .down)
        let newUpperBound = self.upperBound.roundedToNthMultipleOf(target, skipping: numSkipped, rule: .up)
        
        return newLowerBound...newUpperBound
    }
    
    /// Extends both the lower and upper bounds by `percent` percent of the current range.
    func extendBy(percent: Double) -> Self {
        let range = self.upperBound - self.lowerBound
        return (self.lowerBound - range * percent)...(self.upperBound + range * percent)
    }
    
    
    /// Extends the lower and upper bounds equally until the range spans a given `minimumRange`.
    func withMinimumRange(_ minimumRange: Double) -> Self {
        let currentRange = self.upperBound - self.lowerBound
        let difference = minimumRange - currentRange
        return difference > 0 ? (self.lowerBound - difference / 2)...((self.upperBound + difference / 2)) : self
    }
}
