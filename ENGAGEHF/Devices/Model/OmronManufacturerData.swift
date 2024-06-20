//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIOCore
import SpeziBluetooth


struct OmronManufacturerData {
    enum PairingMode {
        case transferMode
        case pairingMode
    }

    enum StreamingMode {
        case dataCommunication
        case streaming
    }

    struct UserSlot {
        let id: UInt8
        let sequenceNumber: UInt16
        let recordsNumber: UInt8
    }

    enum Mode {
        case bluetoothStandard
        case omronExtension
    }

    fileprivate struct Flags: OptionSet {
        static let timeNotSet = Flags(rawValue: 1 << 2)
        static let pairingMode = Flags(rawValue: 1 << 3)
        static let streamingMode = Flags(rawValue: 1 << 4)
        static let wlpStp = Flags(rawValue: 1 << 5)

        let rawValue: UInt8

        var numberOfUsers: UInt8 {
            rawValue & 0x3 + 1
        }

        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }

    let timeSet: Bool
    let pairingMode: PairingMode
    let streamingMode: StreamingMode
    let mode: Mode

    let users: [UserSlot] // max 4 slots
}


extension ManufacturerIdentifier {
    /// Bluetooth manufacturer code for "Omron Healthcare Co., Ltd.".
    static var omronHealthcareCoLtd: ManufacturerIdentifier {
        ManufacturerIdentifier(rawValue: 0x020E)
    }
}


extension OmronManufacturerData: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let companyIdentifier = ManufacturerIdentifier(from: &byteBuffer) else {
            return nil
        }

        guard companyIdentifier == .omronHealthcareCoLtd else {
            return nil
        }

        guard let dataType = UInt8(from: &byteBuffer),
              dataType == 0x01 else { // 0x01 signifies start of "Each User Data"
            return nil
        }

        guard let flags = Flags(from: &byteBuffer) else {
            return nil
        }

        self.timeSet = !flags.contains(.timeNotSet)
        self.pairingMode = flags.contains(.pairingMode) ? .pairingMode : .transferMode
        self.streamingMode = flags.contains(.streamingMode) ? .streaming : .dataCommunication
        self.mode = flags.contains(.wlpStp) ? .bluetoothStandard : .omronExtension

        var userSlots: [UserSlot] = []
        for userNumber in 1...flags.numberOfUsers {
            guard let sequenceNumber = UInt16(from: &byteBuffer),
                  let numberOfData = UInt8(from: &byteBuffer) else {
                return nil
            }

            let userData = UserSlot(id: userNumber, sequenceNumber: sequenceNumber, recordsNumber: numberOfData)
            userSlots.append(userData)
        }
        self.users = userSlots
    }
}


extension OmronManufacturerData.Flags: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let rawValue = UInt8(from: &byteBuffer) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}
