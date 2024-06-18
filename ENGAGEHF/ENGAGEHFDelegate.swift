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
            
            // TODO: only auto-connect with devices that are a) omron devices in b) transfer mode (non pairing) and c) have been paired
            Bluetooth(advertisementStaleInterval: 15) {
                // TODO: global discover is a bit weird with Omron device pairing!
                Discover(WeightScaleDevice.self, by: .advertisedService(WeightScaleService.self))
                Discover(BloodPressureCuffDevice.self, by: .advertisedService(BloodPressureService.self))

                // TODO: omron pairing
                /*
                 The function of registering user is available only when the device is in Pairing Mode.
                 Consent Code range of user authentication is 0x0000-0x270F.
                 Need to set 0x020E to Consent Code to share the measurement data with an application made by
                 OMRON.
                 “Register New User With User Index” is recommended when the user is registered.
                 */
            }
            
            OnboardingDataSource()
            MeasurementManager()
            NotificationManager()
            DeviceManager()
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
