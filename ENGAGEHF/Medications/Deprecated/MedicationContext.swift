//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import ModelsR4


//struct MedicationRecommendationContext: Identifiable, Codable {
//    @DocumentID var id: String?
//    let currentMedicationRef: FHIRReference?
//    let recommendedMedicationRef: FHIRReference?
//    let type: MedicationRecommendationType
//}
//
//
//extension MedicationRecommendationContext {
//    func fetchAssociatedMedication(
//        using firestore: Firestore,
//        requests medicationRequests: [String: MedicationRequest]
//    ) async throws -> MedicationDetails {
//        switch self.type {
//        case .targetDoseReached: return try await extractCurrentMedication(using: firestore, requests: medicationRequests)
//        case .notStarted: return try await extractRecommendedMedication()
//        
//            
//        default: return MedicationDetails()
//        }
//    }
//    
//    
//    private func extractRecommendedMedication() async throws -> MedicationDetails {
//        
//        
//        guard let recommendedMedication = try await self.recommendedMedicationRef?.reference.getDocument(as: Medication.self) else {
//            throw MedicationsError.failedToFetchRecommendedMedication
//        }
//        
//        // For recommended medications, there is no information about dosage
//        return MedicationDetails(displayName: recommendedMedication.displayName, localizedDescription: self.type.localizedDescription)
//    }
//    
//    private func extractCurrentMedication(
//        using firestore: Firestore,
//        requests medicationRequests: [String: MedicationRequest]
//    ) async throws -> MedicationDetails {
//        guard let requestPath = self.currentMedicationRef?.path,
//              let medicationRequest = medicationRequests[requestPath] else {
//            throw MedicationsError.unknownMedicationRequestPath
//        }
//        
//        let medicationPath = try medicationRequest.extractMedicationPath()
//        let currentMedication = try await firestore.document(medicationPath).getDocument(as: Medication.self)
//        
//        // Now, we have general information about the drug in the document at medicationPath
//        // Also have information about the current doseage in the medicationRequest
//        
//        let displayName = currentMedication.code?.
//        let currentDailyDosages = medicationRequest.calculateDailyDosages()
//        let minimumDailyDosages = currentMedication.fetchMinimumDailyDosages()
//        let targetDailyDosages = currentMedication.fetchMaximumDailyDosages()
//        
//        return MedicationDetails()
//    }
//}
