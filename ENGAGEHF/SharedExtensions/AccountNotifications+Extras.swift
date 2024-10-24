//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount

extension AccountNotifications.Event {
    var newEnrolledAccountDetails: AccountDetails? {
        switch self {
        case let .associatedAccount(details) where details.invitationCode != nil:
            return details
        case let .detailsChanged(before, after) where before.invitationCode == nil && after.invitationCode != nil:
            return after
        case .associatedAccount, .detailsChanged, .disassociatingAccount, .deletingAccount:
            return nil
        }
    }
    
    var accountDetails: AccountDetails? {
        switch self {
        case let .associatedAccount(details):
            return details
        case let .detailsChanged(_, after):
            return after
        case .deletingAccount, .disassociatingAccount:
            return nil
        }
    }
}
