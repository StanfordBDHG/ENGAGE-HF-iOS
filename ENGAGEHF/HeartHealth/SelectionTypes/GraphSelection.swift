//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import HealthKit


/// The type of Vitals to be displayed as the main content of the Heart Health view
/// Chosen by GraphPicker in HeartHealth
enum GraphSelection: CaseIterable, Identifiable, CustomStringConvertible, Equatable {
    case symptoms
    case weight
    case heartRate
    case bloodPressure
    
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .symptoms: "Symptoms"
        case .weight: "Weight"
        case .heartRate: "HR"
        case .bloodPressure: "BP"
        }
    }
    
    var fullName: String {
        switch self {
        case .symptoms: "Symptom Score"
        case .weight: "Body Weight"
        case .heartRate: "Heart Rate"
        case .bloodPressure: "Blood Pressure"
        }
    }
    
    var localizedEmptyHistoryWarning: String {
        switch self {
        case .symptoms: String(localized: "symptomsMissing")
        case .weight: String(localized: "weightMissing")
        case .heartRate: String(localized: "heartRateMissing")
        case .bloodPressure: String(localized: "bloodPressureMissing")
        }
    }
    
    var collectionReference: CollectionReference? {
        switch self {
        case .symptoms:
            try? Firestore.symptomScoresCollectionReference
        case .weight:
            try? Firestore.collectionReference(for: HKQuantityType(.bodyMass))
        case .heartRate:
            try? Firestore.collectionReference(for: HKQuantityType(.heartRate))
        case .bloodPressure:
            try? Firestore.collectionReference(for: HKCorrelationType(.bloodPressure))
        }
    }
    
    
    init(collectionRef: CollectionReference?) throws {
        switch collectionRef {
        case try Firestore.symptomScoresCollectionReference:
            self = .symptoms
        case try Firestore.collectionReference(for: HKQuantityType(.bodyMass)):
            self = .weight
        case try Firestore.collectionReference(for: HKQuantityType(.heartRate)):
            self = .heartRate
        case try Firestore.collectionReference(for: HKCorrelationType(.bloodPressure)):
            self = .bloodPressure
        default:
            throw DecodingError.valueNotFound(
                CollectionReference.self,
                .init(
                    codingPath: [],
                    debugDescription: "No collection matches given reference."
                )
            )
        }
    }
}
