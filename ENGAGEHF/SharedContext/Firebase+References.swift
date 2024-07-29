//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
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
    
    
    static var userDocumentReference: DocumentReference {
        get throws {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw FirebaseError.userNotAuthenticatedYet
            }
            return Self.userCollection.document(userId)
        }
    }
    
    static var messagesCollectionReference: CollectionReference {
        get throws {
            try userDocumentReference.collection("messages")
        }
    }
    
    static var symptomScoresCollectionReference: CollectionReference {
        get throws {
            try userDocumentReference.collection("symptomScores")
        }
    }
    
    static var medicationRecsCollectionReference: CollectionReference {
        get throws {
            try userDocumentReference.collection("medicationRecommendations")
        }
    }
    
    static var questionnaireResponseCollectionReference: CollectionReference {
        get throws {
            try userDocumentReference.collection("questionnaireResponses")
        }
    }
    
    static var heartHealthCollectionReferences: [CollectionReference] {
        get throws {
            try [
                symptomScoresCollectionReference,
                collectionReference(for: HKQuantityType(.bodyMass)),
                collectionReference(for: HKQuantityType(.heartRate)),
                collectionReference(for: HKCorrelationType(.bloodPressure))
            ]
                .compactMap { $0 }
        }
    }
    
    
    static func collectionReference(for type: HKSampleType) throws -> CollectionReference? {
        switch type {
        case HKQuantityType(.bodyMass):
            try userDocumentReference.collection("bodyWeightObservations")
        case HKQuantityType(.bodyMassIndex):
            nil
        case HKQuantityType(.height):
            nil
        case HKQuantityType(.heartRate):
            try userDocumentReference.collection("heartRateObservations")
        case HKCorrelationType(.bloodPressure):
            try userDocumentReference.collection("bloodPressureObservations")
        default:
            nil
        }
    }
}

extension Storage {
    static var patientBucketReference: StorageReference {
        get throws {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw FirebaseError.userNotAuthenticatedYet
            }
            return Storage.storage().reference().child("patients/\(userId)")
        }
    }
}
