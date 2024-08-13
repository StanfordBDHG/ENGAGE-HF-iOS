//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziFirebaseAccount
import SpeziOnboarding
import SwiftUI


/// Displays an multi-step onboarding flow for the ENGAGEHF.
struct OnboardingFlow: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    
    @State private var localNotificationAuthorization = false
    
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()
            InterestingModules()
            
            if !FeatureFlags.disableFirebase {
                InvitationCodeView()
                AccountOnboarding()
            }
            
            #if !(targetEnvironment(simulator) && (arch(i386) || arch(x86_64)))
                Consent()
            #endif
            
            if !localNotificationAuthorization {
                NotificationPermissions()
            }
        }
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
#Preview {
    OnboardingFlow()
        .previewWith(standard: ENGAGEHFStandard()) {
            OnboardingDataSource()
            InvitationCodeModule()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
