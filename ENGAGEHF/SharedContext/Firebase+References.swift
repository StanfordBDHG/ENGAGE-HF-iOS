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


enum FirebaseError: LocalizedError {
    case userNotAuthenticatedYet
    
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticatedYet: String(localized: "userNotSignedIn")
        }
    }
}


extension Firestore {
    static var userCollection: CollectionReference {
        Firestore.firestore().collection("patients")
    }
    
    static var patientCollection: CollectionReference {
        Firestore.firestore().collection("patients")
    }
    
    
    static var userDocumentReference: DocumentReference {
        get async throws {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw FirebaseError.userNotAuthenticatedYet
            }
            return Self.userCollection.document(userId)
        }
    }
    
    static var patientDocumentReference: DocumentReference {
        get async throws {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw FirebaseError.userNotAuthenticatedYet
            }
            return Self.patientCollection.document(userId)
        }
    }
}

extension Storage {
    static var patientBucketReference: StorageReference {
        get async throws {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw FirebaseError.userNotAuthenticatedYet
            }
            return Storage.storage().reference().child("patients/\(userId)")
        }
    }
}
