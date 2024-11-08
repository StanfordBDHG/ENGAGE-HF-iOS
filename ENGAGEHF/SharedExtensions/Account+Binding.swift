//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI

extension Account {
    // TODO: Talk to Andreas about putting this into SpeziAccount.
    @MainActor
    func detailsBinding<Key: AccountKey>(
        for key: Key.Type,
        viewState: Binding<ViewState>
    ) -> Binding<Key.Value> {
        Binding {
            self.details?[key] ?? key.initialValue.value
        } set: { newValue in
            var modifiedDetails = AccountDetails()
            modifiedDetails[key] = newValue
            guard let modifications = try? AccountModifications(modifiedDetails: modifiedDetails) else {
                return
            }
            Task { @MainActor in
                guard viewState.wrappedValue == .idle else {
                    return
                }
                viewState.wrappedValue = .processing
                do {
                    try await self.accountService.updateAccountDetails(modifications)
                    viewState.wrappedValue = .idle
                } catch {
                    viewState.wrappedValue = .error(AnyLocalizedError(error: error))
                }
            }
        }
    }
}

extension InitialValue {
    fileprivate var value: Value {
        switch self {
        case let .empty(value):
            return value
        case let .default(value):
            return value
        }
    }
}
