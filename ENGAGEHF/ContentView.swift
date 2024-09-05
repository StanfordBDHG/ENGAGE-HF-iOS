//
//  ContentView.swift
//  ENGAGEHF
//
//  Created by Paul Kraft on 04.09.2024.
//

@_spi(TestingSupport) import SpeziAccount
import SpeziViews
import SwiftUI

@MainActor
struct ContentView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Environment(Account.self) private var account: Account
    @State private var isLoginActive = false
    @State private var isPresentingLogin = false
    
    private var shouldPresentLogin: Bool {
        guard !FeatureFlags.disableFirebase
                && !FeatureFlags.skipOnboarding
                && completedOnboardingFlow else {
            return false
        }
        return !account.signedIn
            || (account.details?.isAnonymous ?? true)
            || isLoginActive
    }

    var body: some View {
        ZStack {
            if !completedOnboardingFlow {
                EmptyView()
            } else if isPresentingLogin {
                EmptyView()
            } else {
                HomeView()
            }
        }
            .onChange(of: shouldPresentLogin, initial: true) {
                Task { @MainActor in
                    // This task makes sure to show the sheet slightly after the view,
                    // so that the presentation will actually occur - otherwise it might
                    // not happen
                    isPresentingLogin = shouldPresentLogin
                }
            }
            .sheet(isPresented: !$completedOnboardingFlow) {
                OnboardingFlow()
            }
            .sheet(isPresented: $isPresentingLogin) {
                AccountSetupSheet(isLoginActive: $isLoginActive)
            }
    }
}
