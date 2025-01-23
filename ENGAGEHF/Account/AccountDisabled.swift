//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount


extension AccountDetails {
    /// If a user account has been disabled by the study coordinator.
    @AccountKey(name: LocalizedStringResource("Account Disabled"), as: Bool.self)
    public var disabled: Bool? // swiftlint:disable:this attributes discouraged_optional_boolean

}


@KeyEntry(\.disabled)
extension AccountKeys {}
