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
    nonisolated static var userCollection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    nonisolated static var videoSectionsCollectionReference: CollectionReference {
        Firestore.firestore().collection("videoSections")
    }
    
    nonisolated static var questionnairesCollectionReference: CollectionReference {
        Firestore.firestore().collection("questionnaires")
    }

    nonisolated static var organizationCollectionReference: CollectionReference {
        Firestore.firestore().collection("organizations")
    }

    nonisolated static func userDocumentReference(for accountId: String) -> DocumentReference {
        Self.userCollection.document(accountId)
    }

    nonisolated static func messagesCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("messages")
    }
    
    nonisolated static func dryWeightCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("dryWeightObservations")
    }

    nonisolated static func symptomScoresCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("symptomScores")
    }

    nonisolated static func medicationRecsCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("medicationRecommendations")
    }

    nonisolated static func questionnaireResponseCollectionReference(for accountId: String) -> CollectionReference {
        userDocumentReference(for: accountId).collection("questionnaireResponses")
    }
    
    nonisolated static func collectionReference(for accountId: String, type: HKSampleType) -> CollectionReference? {
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
