//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import HealthKit
import OSLog
import Spezi
@_spi(TestingSupport) import SpeziBluetooth
import SpeziFirestore


// Functionality:
// - Store the user's measurement history in an array
//      - Watch for changes in the user's blood pressure and weight measurement collections in firebase
// - Convert an incoming measurement into a HKSample and transform to FHIR Observation
// - Save a given measurement to Firebase
@Observable
class MeasurementManager: Module, EnvironmentAccessible {
    private static var _manager: MeasurementManager?
    static var manager: MeasurementManager {
        guard let manager = _manager else {
            fatalError("Accessing shared MeasurmentManager before initialized.")
        }
        return manager
    }
    
    var showSheet: Bool {
        get {
            newMeasurement != nil
        }
        set {
            if !newValue {
                self.newMeasurement = nil
            }
        }
    }
    
    
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    private let logger = Logger(subsystem: "ENGAGEHF", category: "MeasurementManager")
    
    // TODO: why are these internal settable?
    var deviceInformation: DeviceInformationService?
    var weightScaleParams: WeightScaleFeature?
    var deviceName: String?

    var newMeasurement: HKQuantitySample?
    
    
    init() {
        MeasurementManager._manager = self
    }
    
    
    // Called to reset measurement manager after taking a measurement
    func clear() {
        self.newMeasurement = nil
        self.deviceInformation = nil
        self.weightScaleParams = nil
        self.deviceName = nil
    }
    
    // Called by WeightScaleDevice on change of WeightMeasurement Characteristic
    func loadMeasurement(_ measurement: WeightMeasurement) {
        // Convert to HKQuantitySample after downloading from Firestore
        self.newMeasurement = convertToHKSample(measurement)
        logger.info("Measurement loaded into MeasurementManager: \(measurement.weight)")
    }
    
    // Called by UI Sheet View to save the newMeasurement to firestore
    func saveMeasurement() async throws {
        if ProcessInfo.processInfo.isPreviewSimulator {
            try await Task.sleep(for: .seconds(5))
            return
        }
        
        guard let measurement: HKQuantitySample = self.newMeasurement else {
            logger.error("Attempting to save a nil measurement.")
            return
        }
        
        logger.info("Saving the following measurement: \(measurement.quantity.description)")
        await standard.add(sample: measurement)
        
        logger.info("Save successful!")
        self.clear()
    }
    
    
    private func convertToHKSample(_ measurement: WeightMeasurement) -> HKQuantitySample? {
        guard let deviceInfo: DeviceInformationService = deviceInformation else {
            logger.error("***** Device Information not present *****")
            return nil
        }
        
        let device = HKDevice(
            name: deviceName,
            manufacturer: deviceInfo.manufacturerName,
            model: deviceInfo.modelNumber,
            hardwareVersion: deviceInfo.hardwareRevision,
            firmwareVersion: deviceInfo.firmwareRevision,
            softwareVersion: deviceInfo.softwareRevision,
            localIdentifier: nil,
            udiDeviceIdentifier: nil
        )
        
        let quantityType = HKQuantityType(.bodyMass)
        let units = HKUnit(from: measurement.unit.massUnit)

        let value = measurement.weight(of: weightScaleParams?.weightResolution ?? .unspecified)

        let quantity = HKQuantity(unit: units, doubleValue: value)
        let date = getDate(from: measurement)
        
        return HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: date,
            end: date,
            device: device,
            metadata: nil
        )
    }
    
    private func getDate(from measurement: WeightMeasurement) -> Date {
        guard let dateTime: DateTime = measurement.timeStamp else {
            return .now
        }
        
        let year = dateTime.year
        let month = dateTime.month
        let day = dateTime.day
        let hour = dateTime.hours
        let minute = dateTime.minutes
        let second = dateTime.seconds
        
        if year == 0, month == .unknown, day == 0 {
            logger.info("***** Timestamp unkown, displaying current date *****")
            return .now
        }
        
        let dateComponents = DateComponents(
            year: year != 0 ? Int(year) : nil,
            month: month != .unknown ? Int(month.rawValue) : nil,
            day: day != 0 ? Int(day) : nil,
            hour: hour != 0 ? Int(hour) : nil,
            minute: minute != 0 ? Int(minute) : nil,
            second: second != 0 ? Int(second) : nil
        )
        
        guard let date = Calendar.current.date(from: dateComponents) else {
            logger.error("***** Invalid date components, returning current date *****")
            return .now
        }
        
        return date
    }
}


extension MeasurementManager {
    // Call in preview simulator wrappers
    // Loads a mock measurement to display in preview
    func loadMockMeasurement() {
        self.deviceName = "Mock Device"
        
        let devInfo = DeviceInformationService()
        devInfo.$manufacturerName.inject("Mock")
        devInfo.$modelNumber.inject("42")
        devInfo.$hardwareRevision.inject("42")
        devInfo.$firmwareRevision.inject("42")
        devInfo.$softwareRevision.inject("42")
        self.deviceInformation = devInfo
        
        self.weightScaleParams = WeightScaleFeature(
            weightResolution: .resolution10g,
            heightResolution: .resolution1mm,
            options: .timeStampSupported,
            .bmiSupported,
            .multipleUsersSupported
        )
        let measurement = WeightMeasurement(
            weight: 8400,
            unit: .si,
            timeStamp: DateTime(hours: 0, minutes: 0, seconds: 0),
            userId: 42,
            additionalInfo: .init(bmi: 20, height: 180)
        )

        self.loadMeasurement(measurement)
    }
}
