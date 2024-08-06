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
    static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always show the onboarding when the application is launched. Makes it easy to modify and test the onboarding flow without the need to manually remove the application or reset the simulator.
    static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    /// Set the onboarding completed flag to true. Doesn't disable account related functionality.
    static let assumeOnboardingComplete = CommandLine.arguments.contains("--assumeOnboardingComplete") || skipOnboarding
    /// Disables the Firebase interactions, including the login/sign-up step and the Firebase Firestore upload.
    static let disableFirebase = CommandLine.arguments.contains("--disableFirebase")
    /// On sign in, fills the user's vitals observation collections (body weight, blood pressure, heart rate, and symptom scores) with random data if none already present.
    static let setupMockVitals = CommandLine.arguments.contains("--setupMockVitals")
    /// On sign in, fills the user's messages collection with three mock notifications if none already present.
    static let setupMockMessages = CommandLine.arguments.contains("--setupMockMessages")
    /// In the medications manager, instead of initializing a snapshot listener for the medication recommendations collection, include a button to directly fill the medications array with mock medications.
    static let setupTestMedications = CommandLine.arguments.contains("--setupTestMedications")
    /// Fills the VideoManager with a test VideoCollection, skipping on-sign-in configuration. Used for UI Testing and preview simulators.
    static let setupTestVideos = CommandLine.arguments.contains("--setupTestVideos")
    #if targetEnvironment(simulator)
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator. disableFirebase still has priority over useFirebaseEmulator.
    static let useFirebaseEmulator = true
    #else
    /// Defines if the application should connect to the local firebase emulator. Always set to true when using the iOS simulator.
    static let useFirebaseEmulator = CommandLine.arguments.contains("--useFirebaseEmulator")
    #endif
    /// Test mock Bluetooth devices and show extended controls to manage testing procedures.
    static let testMockDevices = CommandLine.arguments.contains("--testMockDevices")
    /// Set up test environment (User account with valid invitation code).
    static let setupTestEnvironment = CommandLine.arguments.contains("--setupTestEnvironment")
}
