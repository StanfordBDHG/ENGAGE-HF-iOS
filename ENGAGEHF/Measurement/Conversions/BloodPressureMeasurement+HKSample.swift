//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import HealthKit


extension BloodPressureMeasurement {
    func bloodPressureSample(source device: HKDevice) -> HKCorrelation {
        let unit: HKUnit = unit.hkUnit

        let systolic = HKQuantity(unit: unit, doubleValue: systolicValue.double)
        let diastolic = HKQuantity(unit: unit, doubleValue: diastolicValue.double)

        let systolicQuantityType = HKQuantityType(.bloodPressureSystolic)
        let diastolicQuantityType = HKQuantityType(.bloodPressureDiastolic)
        let correlationType = HKCorrelationType(.bloodPressure)

        let date = timeStamp?.date ?? .now

        let systolicSample = HKQuantitySample(type: systolicQuantityType, quantity: systolic, start: date, end: date, device: device, metadata: nil)
        let diastolicSample = HKQuantitySample(type: diastolicQuantityType, quantity: diastolic, start: date, end: date, device: device, metadata: nil)


        let bloodPressure = HKCorrelation(
            type: correlationType,
            start: date,
            end: date,
            objects: [systolicSample, diastolicSample],
            device: device,
            metadata: nil
        )

        return bloodPressure
    }
}


extension BloodPressureMeasurement {
    func heartRateSample(source device: HKDevice) -> HKQuantitySample? {
        guard let pulseRate else {
            return nil
        }

        // beats per minute
        let bpm: HKUnit = .count().unitDivided(by: .minute())
        let pulseQuantityType = HKQuantityType(.heartRate)

        let pulse = HKQuantity(unit: bpm, doubleValue: pulseRate.double)
        let date = timeStamp?.date ?? .now

        // TODO: device
        return HKQuantitySample(
            type: pulseQuantityType,
            quantity: pulse,
            start: date,
            end: date,
            device: device,
            metadata: nil
        )
    }
}
