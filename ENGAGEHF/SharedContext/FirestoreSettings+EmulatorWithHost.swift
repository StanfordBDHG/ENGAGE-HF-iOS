//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import SpeziFirestore


extension FirestoreSettings {
    /// The host to use when FeatureFlags.useCustomFirstoreHost is set to true.
    /// For development using a separate device rather than a simulator, set this to the host devices' IP Address instead of localhost.
    static let customHost: String = "localhost"
    
    /// The host to use when FeatureFlags.useCustomFirestoreHost is set to false.
    static let defaultHost: String = "localhost"
    
    /// The default emulator configuration define the default settings when using the Firebase emulator suite as described at [Connect your app to the Cloud Firestore Emulator](https://firebase.google.com/docs/emulator-suite/connect_firestore).
    /// Here, the emulaotr configuration is modified to use a provided host.
    static func emulatorWithHost(_ host: String) -> FirestoreSettings {
        let settings = FirestoreSettings()
        settings.host = "\(host):8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        return settings
    }
}
