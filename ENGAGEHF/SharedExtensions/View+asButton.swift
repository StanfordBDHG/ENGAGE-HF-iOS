//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension View {
    func asButton(onTap: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
    }
}
