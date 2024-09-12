//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziOnboarding
import SpeziViews
import SwiftUI

@MainActor
struct ContentView: View {
    private enum SheetContent: String, Identifiable {
        case onboarding
        case auth
        
        var id: String {
            rawValue
        }
    }
    
    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    @Environment(Account.self) private var account: Account
    @State private var sheetContent: SheetContent?
    
    private var expectedSheetContent: SheetContent? {
        guard FeatureFlags.skipOnboarding || completedOnboardingFlow else {
            return .onboarding
        }
        guard FeatureFlags.disableFirebase || account.signedIn else {
            return .auth
        }
        guard FeatureFlags.disableFirebase
                || account.details?.isIncomplete ?? true
                || account.details?.invitationCode != nil else {
            return .auth
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            if sheetContent != nil {
                VStack {
                    ContentUnavailableView(
                        "Content Unavailable",
                        systemImage: "person.fill.questionmark",
                        description: Text("The user isn't currently set up correctly. Please try closing the app and opening it back up.")
                    )
                    Button("Retry") {
                        sheetContent = nil
                        updateSheetContent()
                    }
                }
            } else {
                HomeView()
            }
        }
        .onChange(of: expectedSheetContent, initial: true) {
            Task { @MainActor in
                // Delaying this update by 0.5 seconds to ensure that animations are done
                // and the AccountSheet is actually dismissed already, before continuing.
                try? await Task.sleep(for: .seconds(1))
                updateSheetContent()
            }
        }
        .sheet(isPresented: $sheetContent.exists()) {
            Group {
                switch sheetContent {
                case .onboarding:
                    OnboardingFlow()
                case .auth:
                    AuthFlow()
                case .none:
                    EmptyView()
                }
            }
            .interactiveDismissDisabled(true)
        }
    }
    
    @MainActor
    private func updateSheetContent() {
        sheetContent = expectedSheetContent
    }
}

extension Binding {
    fileprivate func exists<V>() -> Binding<Bool> where Value == V? {
        Binding<Bool> {
            wrappedValue != nil
        } set: { newValue in
            if newValue {
                preconditionFailure("Tried setting wrappedValue to `true` on a binding built using `Binding.exists()`.")
            } else {
                wrappedValue = nil
            }
        }
    }
}
