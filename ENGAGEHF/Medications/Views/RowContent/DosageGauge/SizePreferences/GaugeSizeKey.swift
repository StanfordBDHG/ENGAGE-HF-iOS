//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


struct GaugeSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .init(width: 15, height: 15)
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
