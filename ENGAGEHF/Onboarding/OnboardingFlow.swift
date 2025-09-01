//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI

/// Displays an multi-step onboarding flow for the ENGAGEHF.
struct OnboardingFlow: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    
    
    var body: some View {
        ManagedNavigationStack(didComplete: $completedOnboardingFlow) {
            Welcome()
            InterestingModules()
            if !FeatureFlags.disableFirebase {
                AccountOnboarding()
            }
            NotificationPermissions()
        }
    }
}


#if DEBUG
#Preview {
    OnboardingFlow()
        .previewWith(standard: ENGAGEHFStandard()) {
            InvitationCodeModule()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
