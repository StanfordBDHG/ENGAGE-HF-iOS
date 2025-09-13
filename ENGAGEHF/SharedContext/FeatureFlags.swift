//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// A collection of feature flags for the ENGAGEHF.
enum FeatureFlags {
    /// Skips the onboarding flow to enable easier development of features in the application and to allow UI tests to skip the onboarding flow.
    nonisolated static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always show the onboarding when the application is launched. Makes it easy to modify and test the onboarding flow without the need to manually remove the application or reset the simulator.
    nonisolated static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    /// Set the onboarding completed flag to true. Doesn't disable account related functionality.
    nonisolated static let assumeOnboardingComplete = CommandLine.arguments.contains("--assumeOnboardingComplete") || skipOnboarding
    /// Disables the Firebase interactions, including the login/sign-up step and the Firebase Firestore upload.
    nonisolated static let disableFirebase = CommandLine.arguments.contains("--disableFirebase")
    /// On sign in, fills the user's vitals observation collections (body weight, blood pressure, heart rate, and symptom scores) with random data if none already present.
    nonisolated static let setupMockVitals = CommandLine.arguments.contains("--setupMockVitals")
    /// Fills the `MessageManager`'s message array with mock messages, skipping on-sign-in configuration such as snapshot listeners. Used for UI Testing.
    /// Also causes `QuestionnaireSheetView` to skip Firestore query and use a default questionnaire as a test example.
    nonisolated static let setupTestMessages = CommandLine.arguments.contains("--setupTestMessages")
    /// In the `MedicationsManager`, instead of initializing a snapshot listener for the medication recommendations collection, include a button to directly fill the medications array with mock medications.
    nonisolated static let setupTestMedications = CommandLine.arguments.contains("--setupTestMedications")
    /// Fills the `VideoManager` with a test VideoCollection, skipping on-sign-in configuration. Used for UI Testing and preview simulators.
    nonisolated static let setupTestVideos = CommandLine.arguments.contains("--setupTestVideos")
    /// Configures Firestore with settings that use a custom host
    nonisolated static let useCustomFirestoreHost = CommandLine.arguments.contains("--useCustomFirestoreHost")
    /// In the `UserMetaDataManager`, skips fetching user organization information and instead injects a test instance.
    /// No changes are made to the way notification settings are handled.
    nonisolated static let setupTestUserMetaData = CommandLine.arguments.contains("--setupTestUserMetaData")
    // periphery:ignore - Actually used in the Notification Manager
    /// Skips the call to `registerRemoteNotifications` in the `NotificationManager`, and uses an empty token instead.
    nonisolated static let skipRemoteNotificationRegistration = CommandLine.arguments.contains("--skipRemoteNotificationRegistration")
    #if targetEnvironment(simulator)
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator. disableFirebase still has priority over useFirebaseEmulator.
    nonisolated static let useFirebaseEmulator = true
    #else
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
    nonisolated static let useFirebaseEmulator = CommandLine.arguments.contains("--useFirebaseEmulator")
    #endif
    /// Test mock Bluetooth devices and show extended controls to manage testing procedures.
    nonisolated static let testMockDevices = CommandLine.arguments.contains("--testMockDevices")
    /// Set up test environment (User account with valid invitation code).
    nonisolated static let setupTestEnvironment = CommandLine.arguments.contains("--setupTestEnvironment")
}
