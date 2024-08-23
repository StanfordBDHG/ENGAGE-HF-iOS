//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import ModelsR4


enum FHIRObservationToHKSampleConverter {
    private enum HKConversionError: Error {
        case invalidConversion
        case unknownUnit
        case invalidObservationType
        case missingField
    }
    
    
    static func convertToHKQuantitySample(_ observation: FHIRObservation) throws -> HKQuantitySample {
        let hkQuantity: HKQuantity
        let quantityType: HKQuantityType
        
        if observation.code.containsCoding(code: "29463-7", system: FHIRSystem.loinc) {
            // Weight
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.bodyMass)
        } else if observation.code.containsCoding(code: "8867-4", system: FHIRSystem.loinc) {
            // Heart Rate
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.heartRate)
        } else {
            throw HKConversionError.invalidObservationType
        }
        
        let effectiveDate = observation.getEffectiveDate()
        
        guard let effectiveDate else {
            throw HKConversionError.invalidConversion
        }
        
        guard let identifier = observation.id?.value?.string else {
            throw HKConversionError.missingField
        }
        
        return HKQuantitySample(
            type: quantityType,
            quantity: hkQuantity,
            start: effectiveDate.start,
            end: effectiveDate.end,
            metadata: [HKMetadataKeyExternalUUID: identifier]
        )
    }
    
    
    static func convertToHKCorrelation(_ observation: FHIRObservation) throws -> HKCorrelation {
        // For now, only handle Blood Pressure
        guard observation.code.containsCoding(code: "85354-9", system: FHIRSystem.loinc) else {
            throw HKConversionError.invalidObservationType
        }
        
        let effectiveDate = observation.getEffectiveDate()
        
        guard let effectiveDate else {
            throw HKConversionError.invalidConversion
        }
        
        // Index into the components of the observation for systolic and diastolic measurements
        guard let components = observation.component else {
            throw HKConversionError.missingField
        }
        
        let systolicComponent = try self.getComponent(components, code: "8480-6", system: FHIRSystem.loinc)
        let diastolicComponent = try self.getComponent(components, code: "8462-4", system: FHIRSystem.loinc)
        
        let systolicQuantity = try self.getQuantity(observation: systolicComponent)
        let diastolicQuantity = try self.getQuantity(observation: diastolicComponent)
        
        let systolicSample = HKQuantitySample(
            type: HKQuantityType(.bloodPressureSystolic),
            quantity: systolicQuantity,
            start: effectiveDate.start,
            end: effectiveDate.end
        )
        let diastolicSample = HKQuantitySample(
            type: HKQuantityType(.bloodPressureDiastolic),
            quantity: diastolicQuantity,
            start: effectiveDate.start,
            end: effectiveDate.end
        )
        
        guard let identifier = observation.id?.value?.string else {
            throw HKConversionError.missingField
        }
        
        return HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: effectiveDate.start,
            end: effectiveDate.end,
            objects: [systolicSample, diastolicSample],
            metadata: [HKMetadataKeyExternalUUID: identifier]
        )
    }
    
    
    private static func getComponent(_ components: [FHIRObservationComponent], code: String, system: URL) throws -> FHIRObservationComponent {
        guard let component = components.first(
            where: {
                $0.code.containsCoding(code: code, system: system)
            }
        ) else {
            throw HKConversionError.missingField
        }
        
        return component
    }
    
    
    private static func getQuantity(observation: ObservationValueProtocol) throws -> HKQuantity {
        guard case let .quantity(fhirQuantity) = observation.observationValue?.type else {
            throw HKConversionError.invalidConversion
        }
        
        guard let sampleQuantity = fhirQuantity.value?.value?.decimal else {
            throw HKConversionError.invalidConversion
        }
        
        let quantity = sampleQuantity.doubleValue
        
        let units: HKUnit
        switch fhirQuantity.unit?.value?.string {
        case "lbs":
            units = HKUnit.pound()
        case "kg":
            units = HKUnit.gramUnit(with: .kilo)
        case "beats/minute":
            units = .count().unitDivided(by: .minute())
        case "mmHg":
            units = HKUnit.millimeterOfMercury()
        default:
            throw HKConversionError.unknownUnit
        }
        
        return HKQuantity(unit: units, doubleValue: quantity)
    }
}
