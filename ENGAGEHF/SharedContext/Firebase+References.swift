//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseStorage
import HealthKit


enum FirebaseError: LocalizedError {
    case userNotAuthenticatedYet
    case accountDeletionNotAllowed
    
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticatedYet: String(localized: "userNotSignedIn")
        case .accountDeletionNotAllowed: String(localized: "accountDeletionError")
        }
    }
}


extension Firestore {
    static var userCollection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    static var videoSectionsCollectionReference: CollectionReference {
        Firestore.firestore().collection("videoSections")
    }
    
    static var questionnairesCollectionReference: CollectionReference {
        Firestore.firestore().collection("questionnaires")
    }

    static func userDocumentReference(for accountId: String) -> DocumentReference {
        Self.userCollection.document(accountId)
    }

    static func messagesCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("messages")
    }

    static func symptomScoresCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("symptomScores")
    }

    static func medicationRecsCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("medicationRecommendations")
    }

    static func questionnaireResponseCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("questionnaireResponses")
    }

    static func heartHealthCollectionReferences(for accountId: String) -> [CollectionReference] {
        [
            symptomScoresCollectionReference(for: accountId),
            collectionReference(for: accountId, type: HKQuantityType(.bodyMass)),
            collectionReference(for: accountId, type: HKQuantityType(.heartRate)),
            collectionReference(for: accountId, type: HKCorrelationType(.bloodPressure))
        ]
            .compactMap { $0 }
    }
    
    
    static func collectionReference(for accountId: String, type: HKSampleType) -> CollectionReference? {
        switch type {
        case HKQuantityType(.bodyMass):
            userDocumentReference(for: accountId).collection("bodyWeightObservations")
        case HKQuantityType(.bodyMassIndex):
            nil
        case HKQuantityType(.height):
            nil
        case HKQuantityType(.heartRate):
            userDocumentReference(for: accountId).collection("heartRateObservations")
        case HKCorrelationType(.bloodPressure):
            userDocumentReference(for: accountId).collection("bloodPressureObservations")
        default:
            nil
        }
    }
}

extension Storage {
    static func patientBucketReference(for accountId: String) -> StorageReference {
        Storage.storage().reference().child("patients/\(accountId)")
    }
}
