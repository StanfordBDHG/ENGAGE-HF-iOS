//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import Foundation
import NIOCore


//func getFlags(flagBits: UInt8) -> (WeightUnits, Bool, Bool, Bool) {
//    let timeStampFlag: Bool = ((flagBits >> 1) & 0b1) != 0
//    let userIDFlag: Bool = ((flagBits >> 2) & 0b1) != 0
//    let heightBMIFlag: Bool = ((flagBits >> 3) & 0b1) != 0
//    
//    let weightUnits: WeightUnits
//    switch flagBits & (0b1) {
//    case 0: weightUnits = .metric
//    case 1: weightUnits = .imperial
//    default: weightUnits = .imperial
//    }
//    
//    return (weightUnits, timeStampFlag, heightBMIFlag, userIDFlag)
//}
//
//func getDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date? {
//    var dateComponents = DateComponents()
//    dateComponents.year = Int(year)
//    dateComponents.month = Int(month)
//    dateComponents.day = Int(day)
//    dateComponents.hour = Int(hour)
//    dateComponents.minute = Int(minute)
//    dateComponents.second = Int(second)
//    
//    if let timeStamp = Calendar.current.date(from: dateComponents) {
//        return timeStamp
//    } else {
//        print("Failed to create Date")
//        return nil
//    }
//}


enum WeightUnits: Equatable {
    case metric, imperial   // Different name here?
}


struct WeightMeasurement {
    // Flags
    let units: WeightUnits
    let timeStampPresent: Bool
    let userIDPresent: Bool
    let heightBMIPresent: Bool
    
    // Units:
    // Kilograms with a resolution of 0.005
    // Pounds with a resolution of 0.01
    let weight: UInt16
    
    // Only present when corresponding flag is true
    let timeStamp: Date?
    let bmi: UInt16?
    let height: UInt16?
    let userID: UInt8?
}


extension WeightMeasurement: ByteDecodable {
    init?(from byteBuffer: inout NIOCore.ByteBuffer, preferredEndianness endianness: NIOCore.Endianness) {
        guard byteBuffer.readableBytes >= 15 else {
            return nil
        }
        
        // Decode fields as described in the manual
        guard let flagBits = UInt8(from: &byteBuffer),
              let weight = UInt16(from: &byteBuffer),
              let year = UInt16(from: &byteBuffer),
              let month = UInt8(from: &byteBuffer),
              let day = UInt8(from: &byteBuffer),
              let hour = UInt8(from: &byteBuffer),
              let minute = UInt8(from: &byteBuffer),
              let second = UInt8(from: &byteBuffer),
              let userID = UInt8(from: &byteBuffer),
              let bmi = UInt16(from: &byteBuffer),
              let height = UInt16(from: &byteBuffer) else {
            return nil
        }
        
        // Extract flags
        let timeStampFlag: Bool = ((flagBits >> 1) & 0b1) != 0
        let userIDFlag: Bool = ((flagBits >> 2) & 0b1) != 0
        let heightBMIFlag: Bool = ((flagBits >> 3) & 0b1) != 0
        
        let weightUnits: WeightUnits
        switch flagBits & (0b1) {
        case 0: weightUnits = .metric
        case 1: weightUnits = .imperial
        default: weightUnits = .imperial
        }
        
        // Get the time stamp
        let dateComponents = DateComponents(
            year: Int(year),
            month: Int(month),
            day: Int(day),
            hour: Int(hour),
            minute: Int(minute),
            second: Int(second)
        )
        let timeStamp: Date? = Calendar.current.date(from: dateComponents)
        
        self.units = weightUnits
        self.timeStampPresent = timeStampFlag
        self.heightBMIPresent = heightBMIFlag
        self.userIDPresent = userIDFlag
        self.weight = weight
        self.userID = userIDFlag ? userID : nil
        self.height = heightBMIFlag ? height : nil
        self.bmi = heightBMIFlag ? bmi : nil
        self.timeStamp = timeStampFlag ? timeStamp : nil
    }
}
