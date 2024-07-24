//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import class ModelsR4.Medication


enum MedicationRecommendationType: String, Codable {
    case targetDoseReached
    case personalTargetDoseReached
    case improvementAvailable
    case morePatientObservationsRequired
    case moreLabObservationsRequired
    case notStarted
    case noActionRequired
    
    
    var localizedDescription: String {
        switch self {
        case .targetDoseReached: String(localized: "targetDoseReached")
        case .personalTargetDoseReached: String(localized: "personalTargetDoseReached")
        case .improvementAvailable: String(localized: "improvementAvailable")
        case .morePatientObservationsRequired: String(localized: "morePatientObservationsRequired")
        case .moreLabObservationsRequired: String(localized: "moreLabObservationsRequired")
        case .notStarted: String(localized: "notStarted")
        case .noActionRequired: String(localized: "noActionRequired")
        }
    }
}


struct MedicationRecommendation: Identifiable, Codable {
    @DocumentID var id: String?
    let currentMedication: DocumentReference?
    let recommendedMedication: DocumentReference?
    let type: MedicationRecommendationType
}


extension MedicationRecommendation {
    func fetchAssociatedMedication(from patientDocumentReference: DocumentReference) async throws -> Medication {
        switch self.type {
        case .notStarted: return try await getRecommendedMedication(from: patientDocumentReference)
            
            
        default: return Medication()
        }
    }
    
    
    private func getRecommendedMedication(from patientDocumentReference: DocumentReference) async throws -> Medication {
        guard let recommendedMedication = try await self.recommendedMedication?.getDocument(as: R4Medication.self) else {
            throw MedicationsError.failedToFetchRecommendedMedication
        }
        
        // TODO: Is there a smarter way we want to handle multiple codes? According to Paul's docs in Firebase Repo, we should expect a single display name
        guard let displayName = recommendedMedication.code?.coding?.compactMap(\.display?.value?.string).joined(separator: ", "),
              !displayName.isEmpty else {
            throw MedicationsError.noDisplayName
        }
        
        // For recommended medications, there is no information about dosage
        return Medication()
    }
    
    private func getCurrentMedication(from patientDocumentReference: DocumentReference) async throws -> Medication {
        return Medication()
    }
}
