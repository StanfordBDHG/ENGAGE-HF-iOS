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
import SpeziFirestore


enum ManagerState: String, Equatable {
    case idle
    case processing
}


// Functionality:
// - Store the user's measurement history in an array
//      - Watch for changes in the user's blood pressure and weight measurement collections in firebase
// - Convert an incoming measurement into a HKSample and transform to FHIR Observation
// - Save a given measurement to Firebase
@Observable
class MeasurementManager: Module, EnvironmentAccessible {
    static var manager = MeasurementManager()
    
    var state: ManagerState = .idle
    
    var deviceInformation: DeviceInformationService?
    var weightScaleParams: WeightScaleFeature?
    var deviceName: String?
    
    var newMeasurement: HKQuantitySample?
    
    var showSheet = false
    
    
    // Called by WeightScaleDevice on change of WeightMeasurement Characteristic
    func loadMeasurement(_ measurement: WeightMeasurement) {
        // Convert to HKQuantitySample
        let weightHKSample = convertToHKSample(measurement)
        
        // Save the sample to the Measurement Manager
        self.newMeasurement = weightHKSample
        self.showSheet = true
    }
    
    // Called by UI Sheet View to save the newMeasurement to firestore
    func saveMeasurement() async {
        self.state = .processing
        
        let logger = Logger(subsystem: "edu.stanford.engage.riedman", category: "MeasurementManager")
        let firestore = Firestore.firestore()
        
        guard let measurement: HKQuantitySample = self.newMeasurement else {
            logger.warning("Attempting to save a nil measurement.")
            return
        }
        
        do {
            logger.info("Saving the following measurement to Firestore: \n\(measurement)")
            guard let userID = Auth.auth().currentUser?.uid else {
                logger.warning("Unable to access userID")
                return
            }
            
            try await firestore.collection("users").document(userID).collection("WeightMeasurements").addDocument(from: "blah")
            logger.info("Successfully saved the measurement!")
        } catch {
            logger.warning("Unable to save measurement to Firestore: \(error)")
        }
        
        self.state = .idle
    }
    
    func discardMeasurement() {
        self.newMeasurement = nil
    }
    
    
    func convertToHKSample(_ measurement: WeightMeasurement) -> HKQuantitySample? {
        guard let deviceInfo: DeviceInformationService = deviceInformation,
              let scaleParams: WeightScaleFeature = weightScaleParams else {
            print("***** Device Information or Weight Scale Features not present *****")
            return nil
        }
        
        let device = HKDevice(
            name: deviceName,
            manufacturer: deviceInfo.manufacturerName,
            model: deviceInfo.modelNumber,
            hardwareVersion: deviceInfo.hardwareRevision,
            firmwareVersion: deviceInfo.firmwareRevision,
            softwareVersion: deviceInfo.softwareRevision,
            localIdentifier: "Maybe deviceInfo.systemID? Generate a custom one? Ask Paul",
            udiDeviceIdentifier: "Not sure if this applies here"
        )
        
        let quantityType = HKQuantityType(.bodyMass)
        let units = HKUnit(from: measurement.units.rawValue)
        
        guard let resolution = getResolutionScalar(for: measurement.units) else {
            print("***** Unable to get Resolution Scalar *****")
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
    
    func getResolutionScalar(for units: WeightUnits) -> Double? {
        guard let scaleParams: WeightScaleFeature = weightScaleParams else {
            print("***** Weight Scale Features not present *****")
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
    
    func getDate(from measurement: WeightMeasurement) -> Date {
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
            print("***** Timestamp unkown, displaying current date *****")
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
            print("***** Invalid date components, returning current date *****")
            return .now
        }
        
        return date
    }
}
