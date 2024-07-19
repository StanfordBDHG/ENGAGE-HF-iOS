//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension DateInterval {
    /// Returns a Range of Dates that includes the start of the interval and excludes the end
    /// Can be used to display the DateInterval with the correct boundary dates (including both start and end)
    func asAdjustedRange(using calendar: Calendar = .current) -> Range<Date>? {
        guard let adjustedEnd = calendar.date(byAdding: .second, value: -1, to: end),
              adjustedEnd >= start else {
            return nil
        }
        return start..<adjustedEnd
    }
}
