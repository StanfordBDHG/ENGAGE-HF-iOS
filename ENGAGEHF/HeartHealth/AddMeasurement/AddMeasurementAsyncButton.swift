//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziViews
import SwiftUI


struct AddMeasurementAsyncButton: View {
    let type: GraphSelection
    let fields: [FieldDetails]
    let date: Date
    @Binding var viewState: ViewState
    
    @Environment(ENGAGEHFStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        AsyncButton("Add") {
            if ProcessInfo.processInfo.isPreviewSimulator {
                print("Measurement Added!")
                return
            }
            
            do {
                let newSample = try getHKSample()
                try await standard.addMeasurement(samples: [newSample])
                dismiss()
            } catch {
                viewState = .error(HeartHealthError.failedAddition(type.fullName))
            }
        }
    }
    
    
    private func getHKSample() throws -> HKSample {
        switch type {
        case .weight:
            let unitLabel = Locale.current.measurementSystem == .us ? "lb" : "kg"
            
            guard let bodyWeight = fields.first(where: { $0.title == unitLabel })?.value else {
                throw HeartHealthError.failedAddition(type.fullName)
            }
            
            let quantityType = HKQuantityType(.bodyMass)
            let unit: HKUnit = Locale.current.measurementSystem == .us ? .pound() : .gramUnit(with: .kilo)
            let quantity = HKQuantity(unit: unit, doubleValue: bodyWeight)
            
            return HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        case .heartRate:
            guard let heartRate = fields.first(where: { $0.title == "BPM" })?.value else {
                throw HeartHealthError.failedAddition(type.fullName)
            }
            
            let quantityType = HKQuantityType(.heartRate)
            let unit: HKUnit = .count().unitDivided(by: .minute())
            let quantity = HKQuantity(unit: unit, doubleValue: heartRate)
            
            return HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        case .bloodPressure:
            guard let systolic = fields.first(where: { $0.title == "Systolic" })?.value,
                  let diastolic = fields.first(where: { $0.title == "Diastolic" })?.value else {
                throw HeartHealthError.failedAddition(type.fullName)
            }
            
            let systolicType = HKQuantityType(.bloodPressureSystolic)
            let diastolicType = HKQuantityType(.bloodPressureDiastolic)
            let bloodPressureType = HKCorrelationType(.bloodPressure)
            
            let systolicQuantity = HKQuantity(unit: .millimeterOfMercury(), doubleValue: systolic)
            let diastolicQuantity = HKQuantity(unit: .millimeterOfMercury(), doubleValue: diastolic)
            
            let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: date, end: date)
            let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: date, end: date)
            
            return HKCorrelation(type: bloodPressureType, start: date, end: date, objects: [systolicSample, diastolicSample])
        default:
            throw HeartHealthError.failedAddition(type.fullName)
        }
    }
}


#Preview {
    AddMeasurementAsyncButton(
        type: .weight,
        fields: [FieldDetails(title: "Weight")],
        date: Date(),
        viewState: .constant(.idle)
    )
}
