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
//    public var weightHistory: [Int]?
    public var state: ManagerState = .idle
    public var deviceInformation: DeviceInformationService?
    public var newMeasurement: HKQuantitySample?
    
    
    // Called by WeightScaleDevice on change of WeightMeasurement Characteristic
    public func loadMeasurement(_ measurement: WeightMeasurement) {
        // Convert to HKQuantitySample
        let weightHKSample = convertToHKSample(measurement)
        
        // Save the sample to the Measurement Manager
        self.newMeasurement = weightHKSample
    }
    
    // Called by UI Sheet View to save the newMeasurement to firestore
    public func saveMeasurement() async {
        assert(self.newMeasurement != nil, "Attempting to save a nonexistant measurement.")
        self.state = .processing
        
        let logger = Logger(subsystem: "edu.stanford.engage.riedman", category: "MeasurementManager")
        let firestore = Firestore.firestore()
        
        let measurement = self.newMeasurement!
        
        do {
            logger.info("Saving the following measurement to Firestore: \n\(self.newMeasurement)")
            guard let userID = Auth.auth().currentUser?.uid else {
                logger.warning("Unable to access userID")
                return
            }
            
            try await firestore.collection("users").document(userID).collection("WeightMeasurements").addDocument(from: "")
        } catch {
            logger.warning("Unable to save measurement to Firestore: \(error)")
        }
        
        self.state = .idle
    }
    
    public func discardMeasurement() {
        self.newMeasurement = nil
    }
    
    
    func convertToHKSample(_ measurement: WeightMeasurement) -> HKQuantitySample? {
        return nil
    }
        
        
        
//        let device = HKDevice(name: deviceName,
//                              manufacturer: manufacturerName,
//                              model: modelName,
//                              hardwareVersion: hardwareVersionNumber,
//                              firmwareVersion: firmwareVersionNumber,
//                              softwareVersion: softwareVersionNumber,
//                              localIdentifier: localIdentifier,
//                              UDIDeviceIdentifier: deviceIdentifier)
//         
//        let metadata = [HKMetadataKeyDigitalSignature:digitalSignature,
//                        HKMetadataKeyTimeZone:timeZone]
//         
//        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
//            fatalError("*** Unable to create a heart rate quantity type ***")
//        }
//         
//        let units = HKUnit(fromString: measurement.units.)
//        let quantity = HKQuantity(unit: bpm, doubleValue: 72.0)
//         
//        let quantitySample = HKQuantitySample(type: quantityType,
//                                              quantity: quantity,
//                                              startDate: start,
//                                              endDate: end,
//                                              device: device,
//                                              metadata: metadata)
        
        
//        return quantitySample
//    }
    
}
