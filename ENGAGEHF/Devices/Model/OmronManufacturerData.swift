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

        init(numberOfUsers: UInt8) {
            precondition(numberOfUsers > 0 && numberOfUsers <= 4, "Only 4 users are supported and at least one.")
            self.rawValue = numberOfUsers - 1
        }
    }

    let timeSet: Bool
    let pairingMode: PairingMode
    let streamingMode: StreamingMode
    let mode: Mode

    let users: [UserSlot] // max 4 slots


    init( // swiftlint:disable:this function_default_parameter_at_end
        timeSet: Bool = true,
        pairingMode: PairingMode,
        streamingMode: StreamingMode = .dataCommunication,
        mode: Mode = .bluetoothStandard,
        users: [UserSlot]
    ) {
        // swiftlint:disable:next empty_count
        precondition(users.count > 0 && users.count <= 4, "Only 4 users are supported and at least one.")
        self.timeSet = timeSet
        self.pairingMode = pairingMode
        self.streamingMode = streamingMode
        self.mode = mode
        self.users = users
    }
}


extension OmronManufacturerData.Flags: ByteCodable {
    init?(from byteBuffer: inout ByteBuffer) {
        guard let rawValue = UInt8(from: &byteBuffer) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }

    func encode(to byteBuffer: inout ByteBuffer) {
        rawValue.encode(to: &byteBuffer)
    }
}


extension OmronManufacturerData: ByteCodable {
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

    func encode(to byteBuffer: inout ByteBuffer) {
        ManufacturerIdentifier.omronHealthcareCoLtd.encode(to: &byteBuffer)
        UInt8(0x01).encode(to: &byteBuffer)

        var flags = Flags(numberOfUsers: UInt8(users.count))

        if !timeSet {
            flags.insert(.timeNotSet)
        }

        if case .pairingMode = pairingMode {
            flags.insert(.pairingMode)
        }

        if case .streaming = streamingMode {
            flags.insert(.streamingMode)
        }

        if case .bluetoothStandard = mode {
            flags.insert(.wlpStp)
        }

        flags.encode(to: &byteBuffer)

        for user in users {
            user.sequenceNumber.encode(to: &byteBuffer)
            user.recordsNumber.encode(to: &byteBuffer)
        }
    }
}
