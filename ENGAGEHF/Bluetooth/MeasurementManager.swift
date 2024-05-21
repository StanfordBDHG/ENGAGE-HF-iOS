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
    
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    private let logger = Logger(subsystem: "ENGAGEHF", category: "MeasurementManager")
    
    var deviceInformation: DeviceInformationService?
    var weightScaleParams: WeightScaleFeature?
    var deviceName: String?
    
    var newMeasurement: HKQuantitySample?
    
    var showSheet = false
    
    
    init() {
        MeasurementManager._manager = self
    }
    
    
    // Called to reset measurement manager after taking a measurement
    func clear() {
        self.showSheet = false
        self.newMeasurement = nil
        self.deviceInformation = nil
        self.weightScaleParams = nil
        self.deviceName = nil
    }
    
    
    // Called by WeightScaleDevice on change of WeightMeasurement Characteristic
    func loadMeasurement(_ measurement: WeightMeasurement) {
        // Convert to HKQuantitySample after downloading from Firestore
        self.newMeasurement = convertToHKSample(measurement)
        self.showSheet = true
        
        logger.info("Measurement loaded into MeasurementManager: \(measurement.weight)")
    }
    
    // Called by UI Sheet View to save the newMeasurement to firestore
    func saveMeasurement() async throws {
        if ProcessInfo.processInfo.isPreviewSimulator {
            try await Task.sleep(nanoseconds: 10_000_000_000)
            return
        }
        
        guard let measurement: HKQuantitySample = self.newMeasurement else {
            logger.error("Attempting to save a nil measurement.")
            return
        }
        
        logger.info("Saving the following measurement: \(measurement.quantity.description)")
        await standard.add(sample: measurement)
        
        logger.info("Save successful!")
        self.showSheet = false
    }
    
    func discardMeasurement() {
        self.newMeasurement = nil
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
        let units = HKUnit(from: measurement.units.rawValue)
        
        guard let resolution = getResolutionScalar(for: measurement.units) else {
            logger.error("***** Unable to get Resolution Scalar *****")
            return nil
        }
        
        let quantity = HKQuantity(unit: units, doubleValue: Double(measurement.weight) * resolution)
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
    
    private func getResolutionScalar(for units: WeightUnits) -> Double? {
        guard let scaleParams: WeightScaleFeature = weightScaleParams else {
            logger.error("***** Weight Scale Features not present *****")
            return nil
        }
        
        let resolution = scaleParams.weightResolution
        let isLbs = units == .imperial
        
        switch resolution {
        case .unspecified: return 1
        case .gradeOne: return isLbs ? 1 : 0.1
        case .gradeTwo: return 0.1
        case .gradeThree: return 0.1
        case .gradeFour: return isLbs ? 0.1 : 0.01
        case .gradeFive: return 0.01
        case .gradeSix: return 0.01
        case .gradeSeven: return isLbs ? 0.01 : 0.001
        }
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
            timeStampEnabled: true,
            supportMultipleUsers: true,
            supportBMI: true,
            weightResolution: .gradeSix,
            heightResolution: .gradeThree
        )
        
        self.loadMeasurement(
            WeightMeasurement(
                units: .metric,
                timeStampPresent: true,
                userIDPresent: true,
                heightBMIPresent: true,
                weight: 8400,
                timeStamp: DateTime(hours: 0, minutes: 0, seconds: 0),
                bmi: 20,
                height: 180,
                userID: 42
            )
        )
    }
}
