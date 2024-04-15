//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import NIOCore
import ByteCoding


// Weight resolutions in kgs / lbs as defined in the manual
enum WeightMeasurementResolution: UInt8, Equatable {
    case unspecified = 0
    case gradeOne = 1  // 0.5 kg or 1 lb
    case gradeTwo = 2  // 0.2 kg or .5 lb
    case gradeThree = 3 // 0.1 kg or 0.2 lb
    case gradeFour = 4  // 0.05 kg or 0.1 lb
    case gradeFive = 5  // 0.02 kg or 0.05 lb
    case gradeSix = 6  // 0.01 kg or 0.02 lb
    case gradeSeven = 7  // 0.005 kg or 0.01 lb
}


// Height resolutions in inches / meters as defined in the manual
enum HeightMeasurementResolution: UInt8, Equatable {
    case unspecified = 0
    case gradeOne = 1  // 0.01 meter or 1 inch
    case gradeTwo = 2  // 0.005 meter or 0.5 inch
    case gradeThree = 3  // 0.001 meter or 0.1 inch
}


struct WeightScaleFeature {
    let timeStampEnabled: Bool
    let supportMultipleUsers: Bool
    let supportBMI: Bool
    let weightResolution: WeightMeasurementResolution
    let heightResolution: HeightMeasurementResolution
}


extension WeightMeasurementResolution: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        // Read in 4 bits from the ByteBuffer, then save to a UInt8
        
        
        guard let value = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        self.init(rawValue: value)
    }
}


extension HeightMeasurementResolution: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let value = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        self.init(rawValue: value)
    }
}

extension WeightScaleFeature: ByteDecodable, Equatable {
    init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard byteBuffer.readableBytes >= 4 else {
            return nil
        }
        
        guard let timeStampFlag = Bool(from: &byteBuffer),
              let multipleUsersFlag = Bool(from: &byteBuffer),
              let supportBMIFlag = Bool(from: &byteBuffer),
              let weightResolution = WeightMeasurementResolution(from: &byteBuffer),
              let heightResolution = HeightMeasurementResolution(from: &byteBuffer) else {
            return nil
        }
        
    }
}
