//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


// swiftlint:disable legacy_objc_type

/// Integer representation of the Decimal for use in creating Dates with time
extension Decimal {
    /// Truncates the decimal and returns only the integer component as an Int
    public var intValue: Int {
        Int(truncating: self as NSNumber)
    }
    
    /// Removes the whole number and returns only the fractional component as an Int, truncated to a precision of 9 decimal places
    public var fracValue: Int {
        NSDecimalNumber(decimal: self)
            .subtracting(NSDecimalNumber(value: self.intValue))
            .multiplying(byPowerOf10: 9)
            .intValue
    }
}


/// Conversion to Double
extension Decimal {
    /// Returns a Double representation of the Decimal
    public var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
