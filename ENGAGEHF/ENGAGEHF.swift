//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI
import TipKit


@main
struct ENGAGEHF: App {
    @UIApplicationDelegateAdaptor(ENGAGEHFDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false

    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                    HomeView()
                } else {
                    EmptyView()
                }
            }
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .onAppear {
                    if FeatureFlags.testingTips {
                        Tips.showAllTipsForTesting()
                    }
                    try? Tips.configure() // TODO: what is the error?
                }
                .testingSetup()
                .spezi(appDelegate)
        }
    }
}
