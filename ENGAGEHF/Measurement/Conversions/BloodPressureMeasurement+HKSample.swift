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
    func bloodPressureSample(source device: HKDevice?) -> HKCorrelation? {
        guard systolicValue.isFinite, diastolicValue.isFinite else {
            return nil
        }
        let unit: HKUnit = unit.hkUnit

        let systolic = HKQuantity(unit: unit, doubleValue: systolicValue.double)
        let diastolic = HKQuantity(unit: unit, doubleValue: diastolicValue.double)

        let systolicType = HKQuantityType(.bloodPressureSystolic)
        let diastolicType = HKQuantityType(.bloodPressureDiastolic)
        let correlationType = HKCorrelationType(.bloodPressure)

        let date = timeStamp?.date ?? .now

        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolic, start: date, end: date, device: device, metadata: nil)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolic, start: date, end: date, device: device, metadata: nil)


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
    func heartRateSample(source device: HKDevice?) -> HKQuantitySample? {
        guard let pulseRate, pulseRate.isFinite else {
            return nil
        }

        // beats per minute
        let bpm: HKUnit = .count().unitDivided(by: .minute())
        let pulseQuantityType = HKQuantityType(.heartRate)

        let pulse = HKQuantity(unit: bpm, doubleValue: pulseRate.double)
        let date = timeStamp?.date ?? .now // TODO: don't default to now

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


#if DEBUG || TEST
extension HKCorrelation {
    static var mockBloodPressureSample: HKCorrelation {
        let measurement = BloodPressureMeasurement(systolic: 117, diastolic: 76, meanArterialPressure: 67, unit: .mmHg, pulseRate: 68)
        guard let sample = measurement.bloodPressureSample(source: nil) else {
            preconditionFailure("Mock sample was unexpectedly invalid!")
        }
        return sample
    }
}

extension HKQuantitySample {
    static var mockHeartRateSample: HKQuantitySample {
        let measurement = BloodPressureMeasurement(systolic: 117, diastolic: 76, meanArterialPressure: 67, unit: .mmHg, pulseRate: 68)
        guard let sample = measurement.heartRateSample(source: nil) else {
            preconditionFailure("Mock sample was unexpectedly invalid!")
        }
        return sample
    }
}
#endif
