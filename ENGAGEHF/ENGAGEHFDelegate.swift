//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import PhoneNumberKit
import Spezi
import SpeziAccount
import SpeziAccountPhoneNumbers
import SpeziBluetooth
import SpeziBluetoothServices
import SpeziDevices
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziOmron
import SpeziViews
import SwiftUI


class ENGAGEHFDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        // swiftlint:disable:next closure_body_length
        Configuration(standard: ENGAGEHFStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(
                    service: FirebaseAccountService(
                        providers: [
                            .emailAndPassword
                        ],
                        emulatorSettings: accountEmulator
                    ),
                    storageProvider: FirestoreAccountStorage(
                        storeIn: Firestore.userCollection,
                        mapping: [
                        "phoneNumbers": AccountKeys.phoneNumbers,
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
                        ],
                        decoder: customDecoder
                    ),
                    configuration: [
                        .requires(\.userId),
                        .supports(\.name),
                        .supports(\.phoneNumbers),
                        .manual(\.invitationCode),
                        .manual(\.organization),
                        .manual(\.receivesAppointmentReminders),
                        .manual(\.receivesInactivityReminders),
                        .manual(\.receivesMedicationUpdates),
                        .manual(\.receivesQuestionnaireReminders),
                        .manual(\.receivesRecommendationUpdates),
                        .manual(\.receivesVitalsReminders),
                        .manual(\.receivesWeightAlerts),
                        .manual(\.selfManaged),
                        .manual(\.disabled)
                    ]
                )
                
                Firestore(settings: FeatureFlags.useFirebaseEmulator ? .emulatorWithHost(firestoreHost) : FirestoreSettings())
                
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: firestoreHost, port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
                PhoneVerificationProvider()
            }

            Bluetooth {
                if #available(iOS 18, *) {
                    // Normally, we would supply the `supportOptions: .bluetoothPairingLE` argument to automatically handle the "Pair" alert.
                    // However, some build of iOS broke this, and if you do this with a factory reset device, results in the following error:
                    // Code=14, Description=Peer removed pairing information and the device will never connect or pair.
                    // This seems to not be a problem with the SC-150 scale.
                    Discover(OmronBloodPressureCuff.self, by: .accessory(advertising: BloodPressureService.self))
                    Discover(OmronWeightScale.self, by: .accessory(advertising: WeightScaleService.self, supportOptions: .bluetoothPairingLE))
                } else {
                    Discover(OmronBloodPressureCuff.self, by: .advertisedService(BloodPressureService.self))
                    Discover(OmronWeightScale.self, by: .advertisedService(WeightScaleService.self))
                }
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
    
    private var customDecoder: FirebaseFirestore.Firestore.Decoder {
        let decoder = FirebaseFirestore.Firestore.Decoder()
        decoder.userInfo[.phoneNumberDecodingStrategy] = PhoneNumberDecodingStrategy.e164
        return decoder
    }
}
