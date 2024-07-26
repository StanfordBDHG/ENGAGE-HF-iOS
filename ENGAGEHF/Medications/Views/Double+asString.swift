//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension Double {
    func asString(minimumFractionDigits: Int = 0, maximumFractionDigits: Int = 3) -> String {
        let roundedFormatStyle = FloatingPointFormatStyle<Double>().precision(.fractionLength(minimumFractionDigits...maximumFractionDigits))
        return roundedFormatStyle.format(self)
    }
    
}
