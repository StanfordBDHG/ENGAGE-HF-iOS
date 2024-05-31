//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension Binding where Value == Bool {
    /// Negates a `Binding`.
    prefix static func ! (value: Binding<Bool>) -> Binding<Bool> { // TODO: can be removed?
        Binding<Bool>(
            get: { !value.wrappedValue },
            set: { value.wrappedValue = !$0 }
        )
    }
}
