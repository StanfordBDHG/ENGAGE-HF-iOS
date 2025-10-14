//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// A collection of feature flags for ENGAGE-HF.
enum FeatureFlags {
    /// Skips the onboarding flow to simplify feature development and allow UI tests to bypass onboarding.
    nonisolated static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always shows onboarding on app launch. Useful for modifying and testing the flow without reinstalling the app or resetting the simulator.
    nonisolated static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    /// Sets the onboarding-completed flag to true. Does not disable account-related functionality.
    nonisolated static let assumeOnboardingComplete = CommandLine.arguments.contains("--assumeOnboardingComplete") || skipOnboarding
    /// Disables Firebase interactions, including the login/sign-up step and Firestore uploads.
    nonisolated static let disableFirebase = CommandLine.arguments.contains("--disableFirebase")
    /// On sign-in, populates the user's vitals collections (body weight, blood pressure, heart rate, and symptom scores) with random data if none are present.
    nonisolated static let setupMockVitals = CommandLine.arguments.contains("--setupMockVitals")
    /// Populates the ``MessageManager``'s messages with mock data and skips on-sign-in setup (e.g., snapshot listeners). Used for UI testing.
    /// Also causes ``QuestionnaireSheetView`` to skip the Firestore query and use a default questionnaire for testing.
    nonisolated static let setupTestMessages = CommandLine.arguments.contains("--setupTestMessages")
    /// In ``MedicationsManager``, replaces the snapshot listener for medication recommendations with a button that fills the medications array with mock data.
    nonisolated static let setupTestMedications = CommandLine.arguments.contains("--setupTestMedications")
    /// Populates ``VideoManager`` with a test ``VideoCollection``, skipping on-sign-in setup. Used for UI testing and previews.
    nonisolated static let setupTestVideos = CommandLine.arguments.contains("--setupTestVideos")
    /// Skips phone-number verification performed via Cloud Functions.
    nonisolated static let setupTestPhoneNumberVerificationBehavior = CommandLine.arguments.contains("--setupTestPhoneNumberVerificationBehavior")
    /// Configures Firestore to use a custom host.
    nonisolated static let useCustomFirestoreHost = CommandLine.arguments.contains("--useCustomFirestoreHost")
    /// In ``UserMetaDataManager``, skips fetching user-organization information and injects a test instance instead.
    /// Notification settings behavior is unchanged.
    nonisolated static let setupTestUserMetaData = CommandLine.arguments.contains("--setupTestUserMetaData")
    // periphery:ignore - Actually used in the Notification Manager
    /// Skips calling  ``NotificationManager/registerRemoteNotifications`` and uses an empty token instead.
    nonisolated static let skipRemoteNotificationRegistration = CommandLine.arguments.contains("--skipRemoteNotificationRegistration")
    #if targetEnvironment(simulator)
    /// Controls whether the app connects to the local Firebase emulator. Always true on the iOS simulator. `disableFirebase` takes priority over `useFirebaseEmulator`.
    nonisolated static let useFirebaseEmulator = true
    #else
    /// Controls whether the app connects to the local Firebase emulator.
    nonisolated static let useFirebaseEmulator = CommandLine.arguments.contains("--useFirebaseEmulator")
    #endif
    /// Tests mock Bluetooth devices and shows extended controls for managing test procedures.
    nonisolated static let testMockDevices = CommandLine.arguments.contains("--testMockDevices")
    /// Sets up a test environment (user account with a valid invitation code).
    nonisolated static let setupTestEnvironment = CommandLine.arguments.contains("--setupTestEnvironment")
}
