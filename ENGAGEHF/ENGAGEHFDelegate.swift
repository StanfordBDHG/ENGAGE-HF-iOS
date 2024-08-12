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
        Configuration(standard: ENGAGEHFStandard()) { // swiftlint:disable:this closure_body_length
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(configuration: [
                    .requires(\.userId),
                    .supports(\.name),
                    .supports(\.dateOfBirth)
                ])

                if FeatureFlags.useFirebaseEmulator {
                    FirebaseAccountConfiguration(
                        authenticationMethods: [.emailAndPassword, .signInWithApple],
                        emulatorSettings: (host: "localhost", port: 9099)
                    )
                } else {
                    FirebaseAccountConfiguration(authenticationMethods: [.emailAndPassword, .signInWithApple])
                }
                FirestoreAccountStorage(storeIn: Firestore.userCollection)
                
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
            
            NotificationManager()
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
}
