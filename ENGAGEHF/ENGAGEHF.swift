//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI
import TipKit


@main
struct ENGAGEHF: App {
    static let logger = Logger(subsystem: "edu.stanford.bdh.engagehf", category: "App")
    @UIApplicationDelegateAdaptor(ENGAGEHFDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false


    static var appName: String? {
        // TODO: CFBundleName vs CFBundleDisplayName
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
        // TODO: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }

    
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
                    do {
                        try Tips.configure()
                    } catch {
                        Self.logger.error("Failed to configure TipKit: \(error)")
                    }
                }
                .testingSetup()
                .spezi(appDelegate)
        }
    }
}
