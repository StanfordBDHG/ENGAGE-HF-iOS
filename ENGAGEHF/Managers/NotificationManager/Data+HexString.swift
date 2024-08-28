//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension Data {
    /// Returns `self` formatted as a hex string, which is the proper format for representing and transmitting APNS device tokens.
    var hexString: String {
        self.reduce(into: "") { $0 += String(format: "%02.2hhx", $1) }
    }
}
