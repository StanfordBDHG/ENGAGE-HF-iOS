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


enum WeightUnits: String, Equatable {
    case metric = "kgs"
    case imperial = "lbs"
}


struct WeightMeasurement: Equatable {
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
        guard byteBuffer.readableBytes >= 11 else {
            return nil
        }
        
        // Decode fields as described in the manual
        guard let flagBits = UInt8(from: &byteBuffer, preferredEndianness: endianness),
              let weight = UInt16(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        
        // Extract flags
        let timeStampFlag: Bool = ((flagBits >> 1) & 0b1) != 0
        let userIDFlag: Bool = ((flagBits >> 2) & 0b1) != 0
        let heightBMIFlag: Bool = ((flagBits >> 3) & 0b1) != 0
        
        // Get the time stamp
        let timeStamp: Date? = timeStampFlag ? getTimeStamp(from: &byteBuffer, preferredEndianness: endianness) : nil
        
        var userID: UInt8?
        if userIDFlag {
            guard let userIDBits = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
                return nil
            }
            
            userID = userIDBits
        }
        
        var bmi: UInt16?
        var height: UInt16?
        if heightBMIFlag {
            guard let bmiBits = UInt16(from: &byteBuffer),
                  let heightBits = UInt16(from: &byteBuffer) else {
                return nil
            }
            
            bmi = bmiBits
            height = heightBits
        }
        
        let weightUnits: WeightUnits
        switch flagBits & (0b1) {
        case 0: weightUnits = .metric
        case 1: weightUnits = .imperial
        default: weightUnits = .imperial
        }
        
        self.units = weightUnits
        self.timeStampPresent = timeStampFlag
        self.heightBMIPresent = heightBMIFlag
        self.userIDPresent = userIDFlag
        self.weight = weight
        self.userID = userID
        self.height = height
        self.bmi = bmi
        self.timeStamp = timeStamp
    }
}

private func getTimeStamp(from byteBuffer: inout NIOCore.ByteBuffer, preferredEndianness endianness: NIOCore.Endianness) -> Date? {
    guard let year = UInt16(from: &byteBuffer, preferredEndianness: endianness),
          let month = UInt8(from: &byteBuffer, preferredEndianness: endianness),
          let day = UInt8(from: &byteBuffer, preferredEndianness: endianness),
          let hour = UInt8(from: &byteBuffer, preferredEndianness: endianness),
          let minute = UInt8(from: &byteBuffer, preferredEndianness: endianness),
          let second = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
        return nil
    }
    
    let dateComponents = DateComponents(
        year: year != 0 ? Int(year) : nil,
        month: month != 0 ? Int(month) : nil,
        day: day != 0 ? Int(day) : nil,
        hour: hour != 0 ? Int(hour) : nil,
        minute: minute != 0 ? Int(minute) : nil,
        second: second != 0 ? Int(second) : nil
    )
    
    return Calendar.current.date(from: dateComponents)
}
