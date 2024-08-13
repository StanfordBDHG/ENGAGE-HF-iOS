//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Spezi
import SpeziAccount
import SpeziBluetooth
import SpeziBluetoothServices
import SpeziDevices
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziOmron
import SpeziOnboarding
import SpeziViews
import SwiftUI


class ENGAGEHFDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ENGAGEHFStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(
                    service: FirebaseAccountService(providers: [.emailAndPassword, .signInWithApple], emulatorSettings: accountEmulator),
                    storageProvider: FirestoreAccountStorage(storeIn: Firestore.userCollection, mapping: [
                        // ENGAGE was originally deployed with SpeziAccount 1.0 and key identifiers change with SpeziAccount 2.0.
                        // Therefore, we need to provide a backwards compatibility mapping.
                        "DateOfBirthKey": AccountKeys.dateOfBirth
                    ]),
                    configuration: [
                        .requires(\.userId),
                        .supports(\.name),
                        .supports(\.dateOfBirth)
                    ]
                )
                
                Firestore(settings: FeatureFlags.useFirebaseEmulator ? .emulator : FirestoreSettings())
                
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
            }

            Bluetooth {
                Discover(OmronWeightScale.self, by: .advertisedService(WeightScaleService.self))
                Discover(OmronBloodPressureCuff.self, by: .advertisedService(BloodPressureService.self))
            }
            
            PairedDevices()
            HealthMeasurements()
            
            NavigationManager()
            MessageManager()
            VitalsManager()
            MedicationsManager()
            VideoManager()
            
            OnboardingDataSource()
            InvitationCodeModule()

            ConfigureTipKit()
        }
    }

    private var accountEmulator: (host: String, port: Int)? {
        if FeatureFlags.useFirebaseEmulator {
            (host: "localhost", port: 9099)
        } else {
            nil
        }
    }
}
