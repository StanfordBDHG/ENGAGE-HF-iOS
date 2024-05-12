//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import ByteCoding
import Foundation
import NIOCore


enum WeightUnits: String, Equatable {
    case metric = "kg"
    case imperial = "lb"
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
    let timeStamp: DateTime?
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
        if timeStampFlag {
            guard let timeStamp = DateTime(from: &byteBuffer, preferredEndianness: endianness) else {
                return nil
            }
            
            self.timeStamp = timeStamp
        } else {
            self.timeStamp = nil
        }
        
        if userIDFlag {
            guard let userID = UInt8(from: &byteBuffer, preferredEndianness: endianness) else {
                return nil
            }
            
            self.userID = userID
        } else {
            self.userID = nil
        }
        
        if heightBMIFlag {
            guard let bmi = UInt16(from: &byteBuffer),
                  let height = UInt16(from: &byteBuffer) else {
                return nil
            }
            
            self.bmi = bmi
            self.height = height
        } else {
            self.bmi = nil
            self.height = nil
        }
        
        self.units = {
            if (flagBits & 1) == 1 {
                return .imperial
            } else {
                return .metric
            }
        }()
        
        
        self.timeStampPresent = timeStampFlag
        self.heightBMIPresent = heightBMIFlag
        self.userIDPresent = userIDFlag
        self.weight = weight
    }
}
