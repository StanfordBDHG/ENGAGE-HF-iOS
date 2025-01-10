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
    

    func collectionReference(for accountId: String) -> CollectionReference? {
        switch self {
        case .symptoms:
            Firestore.symptomScoresCollectionReference(for: accountId)
        case .weight:
            Firestore.collectionReference(for: accountId, type: HKQuantityType(.bodyMass))
        case .heartRate:
            Firestore.collectionReference(for: accountId, type: HKQuantityType(.heartRate))
        case .bloodPressure:
            Firestore.collectionReference(for: accountId, type: HKCorrelationType(.bloodPressure))
        }
    }
}
