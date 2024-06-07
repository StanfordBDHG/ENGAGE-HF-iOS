//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import Spezi


/// Manage and process incoming measurements.
///
/// Functionality:
/// - Store the user's measurement history in an array
///      - Watch for changes in the user's blood pressure and weight measurement collections in firebase
/// - Convert an incoming measurement into a HKSample and transform to FHIR Observation
/// - Save a given measurement to Firebase
@Observable
class MeasurementManager: Module, EnvironmentAccessible {
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    private let logger = Logger(subsystem: "ENGAGEHF", category: "MeasurementManager")

    var newMeasurement: ProcessedMeasurement?

    
    init() {}

    func handleNewMeasurement<Device: HealthDevice>(_ measurement: Measurement, from device: Device) {
        let hkDevice = device.hkDevice

        switch measurement {
        case let .weight(measurement, feature):
            let sample = measurement.quantitySample(source: hkDevice, resolution: feature.weightResolution)
            logger.debug("Measurement loaded into MeasurementManager: \(measurement.weight)")

            newMeasurement = .weight(sample)
        case let .bloodPressure(measurement, _):
            let bloodPressureSample = measurement.bloodPressureSample(source: hkDevice)
            let heartRateSample = measurement.heartRateSample(source: hkDevice)

            guard let bloodPressureSample else {
                logger.debug("Discarding invalid blood pressure measurement ...")
                return
            }

            logger.debug("Measurement loaded into MeasurementManager: \(String(describing: measurement))")

            newMeasurement = .bloodPressure(bloodPressureSample, heartRate: heartRateSample)
        }
    }
    
    /// Called by UI Sheet View to save the newMeasurement to firestore
    func saveMeasurement() async throws {
        if ProcessInfo.processInfo.isPreviewSimulator {
            try await Task.sleep(for: .seconds(5))
            return
        }
        
        guard let measurement = self.newMeasurement else {
            logger.error("Attempting to save a nil measurement.")
            return
        }

        logger.info("Saving the following measurement: \(String(describing: measurement))")
        do {
            switch measurement {
            case let .weight(sample):
                try await standard.addMeasurement(sample: sample)
            case let .bloodPressure(bloodPressureSample, heartRateSample):
                try await standard.addMeasurement(sample: bloodPressureSample)
                if let heartRateSample {
                    try await standard.addMeasurement(sample: heartRateSample)
                }
            }
        } catch {
            logger.error("Failed to save measurement samples: \(error)")
            throw error
        }

        logger.info("Save successful!")
        newMeasurement = nil
    }
}


#if DEBUG || TEST
extension MeasurementManager {
    /// Call in preview simulator wrappers.
    ///
    /// Loads a mock measurement to display in preview.
    func loadMockWeightMeasurement() {
        let device = WeightScaleDevice.createMockDevice()

        guard let measurement = device.weightScale.weightMeasurement else {
            preconditionFailure("Mock Weight Measurement was never injected!")
        }

        handleNewMeasurement(.weight(measurement, device.weightScale.features ?? []), from: device)
    }

    /// Call in preview simulator wrappers.
    ///
    /// Loads a mock measurement to display in preview.
    func loadMockBloodPressureMeasurement() {
        let device = BloodPressureCuffDevice.createMockDevice()

        guard let measurement = device.bloodPressure.bloodPressureMeasurement else {
            preconditionFailure("Mock Blood Pressure Measurement was never injected!")
        }

        handleNewMeasurement(.bloodPressure(measurement, device.bloodPressure.features ?? []), from: device)
    }
}
#endif
