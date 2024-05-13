//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

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
                        emulatorSettings: (host: "10.34.253.54", port: 9099)
                    )
                } else {
                    FirebaseAccountConfiguration(authenticationMethods: [.emailAndPassword, .signInWithApple])
                }
                firestore
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: "10.34.253.54", port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
            }

//            if HKHealthStore.isHealthDataAvailable() {
//                healthKit
//            }
            
            Bluetooth {
//                Discover(BPCuffDevice.self, by: .advertisedService(BPCuffDevice.service.self))
                Discover(WeightScaleDevice.self, by: .advertisedService(WeightScaleService.self))
            }
            
            OnboardingDataSource()
            MeasurementManager()
        }
    }
    
    
    private var firestore: Firestore {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "10.34.253.54:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            settings: settings
        )
    }
    
    
//    private var healthKit: HealthKit {
//        HealthKit {
//            CollectSample(
//                HKQuantityType(.stepCount),
//                deliverySetting: .anchorQuery(.automatic)
//            )
//        }
//    }
}
