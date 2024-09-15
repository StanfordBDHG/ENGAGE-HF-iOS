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
        // swiftlint:disable:next closure_body_length
        Configuration(standard: ENGAGEHFStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(
                    service: FirebaseAccountService(providers: [.emailAndPassword, .signInWithApple], emulatorSettings: accountEmulator),
                    storageProvider: FirestoreAccountStorage(storeIn: Firestore.userCollection, mapping: [
                        "dateOfBirth": AccountKeys.dateOfBirth,
                        "invitationCode": AccountKeys.invitationCode,
                        "organization": AccountKeys.organization,
                        "receivesAppointmentReminders": AccountKeys.receivesAppointmentReminders,
                        "receivesInactivityReminders": AccountKeys.receivesInactivityReminders,
                        "receivesMedicationUpdates": AccountKeys.receivesMedicationUpdates,
                        "receivesQuestionnaireReminders": AccountKeys.receivesQuestionnaireReminders,
                        "receivesRecommendationUpdates": AccountKeys.receivesRecommendationUpdates,
                        "receivesVitalsReminders": AccountKeys.receivesVitalsReminders,
                        "receivesWeightAlerts": AccountKeys.receivesWeightAlerts
                    ]),
                    configuration: [
                        .requires(\.userId),
                        .supports(\.name),
                        .manual(\.invitationCode),
                        .manual(\.organization),
                        .manual(\.receivesAppointmentReminders),
                        .manual(\.receivesInactivityReminders),
                        .manual(\.receivesMedicationUpdates),
                        .manual(\.receivesQuestionnaireReminders),
                        .manual(\.receivesRecommendationUpdates),
                        .manual(\.receivesVitalsReminders),
                        .manual(\.receivesWeightAlerts)
                    ]
                )
                
                Firestore(settings: FeatureFlags.useFirebaseEmulator ? .emulatorWithHost(firestoreHost) : FirestoreSettings())
                
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: firestoreHost, port: 9199))
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
            
            UserMetaDataManager()
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

    private var firestoreHost: String {
        FeatureFlags.useCustomFirestoreHost ? FirestoreSettings.customHost : FirestoreSettings.defaultHost
    }

    private var accountEmulator: (host: String, port: Int)? {
        if FeatureFlags.useFirebaseEmulator {
            (host: firestoreHost, port: 9099)
        } else {
            nil
        }
    }
}
