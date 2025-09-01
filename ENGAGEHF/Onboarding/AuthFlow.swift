//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziViews
import SwiftUI

struct AuthFlow: View {
    var body: some View {
        ManagedNavigationStack {
            AccountOnboarding()
        }
    }
}
