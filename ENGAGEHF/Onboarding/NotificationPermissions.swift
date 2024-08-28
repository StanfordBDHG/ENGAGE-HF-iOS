//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI
import UserNotifications


struct NotificationPermissions: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(NotificationManager.self) private var notificationManager
    
    @State private var notificationProcessing = false
    
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "NOTIFICATION_PERMISSIONS_TITLE",
                        subtitle: "NOTIFICATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "bell.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("NOTIFICATION_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    primaryText: "NOTIFICATION_PERMISSIONS_BUTTON",
                    primaryAction: {
                        notificationProcessing = true
                        
                        // Notification Authorization is not available in the preview simulator.
                        if ProcessInfo.processInfo.isPreviewSimulator {
                            try await _Concurrency.Task.sleep(for: .seconds(5))
                        } else {
                            _ = try await notificationManager.requestNotificationPermissions()
                        }
                        
                        notificationProcessing = false
                        onboardingNavigationPath.nextStep()
                    },
                    secondaryText: "Skip",
                    secondaryAction: {
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(notificationProcessing)
            // Small fix as otherwise "Login" or "Sign up" is still shown in the nav bar
            .navigationTitle(Text(verbatim: ""))
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        NotificationPermissions()
    }
}
#endif
