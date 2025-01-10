//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension Double {
    /// Rounds `self` to the `numSkipped`th nearest multiple of the given target (nearness being zero-indexed), in the direction determined  by the given rule.
    func roundedToNthMultipleOf(_ target: Double, skipping numSkipped: Int = 0, rule: FloatingPointRoundingRule = .up) -> Self {
        let offsetSign = switch rule {
        case .up: 1.0
        case .down: -1.0
        case .towardZero: -(self / magnitude)
        case .awayFromZero: self / magnitude
        default: 1.0
        }
        let offsetMagnitude = Double(numSkipped) * target
        
        return target * (((self + offsetSign * offsetMagnitude) / target).rounded(rule))
    }
}
