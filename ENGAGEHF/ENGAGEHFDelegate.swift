//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import Spezi
import SpeziAccount
import SpeziBluetooth
import SpeziFirebaseAccount
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziOnboarding
import SwiftUI


class ENGAGEHFDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ENGAGEHFStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(configuration: [
                    .requires(\.userId),
                    .requires(\.name),

                    // additional values stored using the `FirestoreAccountStorage` within our Standard implementation
                    .collects(\.genderIdentity),
                    .collects(\.dateOfBirth)
                ])

                if FeatureFlags.useFirebaseEmulator {
                    FirebaseAccountConfiguration(
                        authenticationMethods: [.emailAndPassword, .signInWithApple],
                        emulatorSettings: (host: "localhost", port: 9099)
                    )
                } else {
                    FirebaseAccountConfiguration(authenticationMethods: [.emailAndPassword, .signInWithApple])
                }
                firestore
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
            }
            
            Bluetooth {
                Discover(WeightScaleDevice.self, by: .advertisedService(WeightScaleService.self))
                Discover(BloodPressureCuffDevice.self, by: .advertisedService(BloodPressureService.self))
            }
            
            OnboardingDataSource()
            MeasurementManager()
            NotificationManager()
            InvitationCodeModule()
        }
    }
    
    
    private var firestore: Firestore {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            settings: settings
        )
    }
}
