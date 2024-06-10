//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import Foundation
import OSLog
@_spi(TestingSupport) import SpeziBluetooth
import SpeziFoundation
import SpeziNumerics
import SpeziOmron


import ByteCoding
import NIOCore
struct OmronManufacturerData {
    enum PairingMode {
        case transferMode
        case pairingMode
    }

    enum StreamingMode { // TODO: unused?
        case dataCommunication
        case streaming
    }

    struct UserSlot {
        let id: UInt8
        let sequenceNumber: UInt16
        let recordsNumber: UInt8
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
    // TODO: bluetooth mode!

    let users: [UserSlot] // max 4 slots
}
extension OmronManufacturerData: ByteDecodable {
    init?(from byteBuffer: inout ByteBuffer) {
        // TODO: endianness = .little ???
        guard let companyIdentifier = UInt16(from: &byteBuffer) else {
            return nil
        }

        guard companyIdentifier == 0x020E else { // TODO: magic: "Omron Healthcare Co., Ltd."
            return nil
        }

        guard let dataType = UInt8(from: &byteBuffer),
              dataType == 0x01 else { // TODO: each user data
            return nil
        }

        guard let flags = Flags(from: &byteBuffer) else {
            return nil
        }

        self.timeSet = !flags.contains(.timeNotSet)
        self.pairingMode = flags.contains(.pairingMode) ? .pairingMode : .transferMode
        self.streamingMode = flags.contains(.streamingMode) ? .streaming : .dataCommunication
        // TODO: bluetooth mode??

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


class BloodPressureCuffDevice: BluetoothDevice, Identifiable, HealthDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "BloodPressureCuffDevice")

    @DeviceState(\.id) var id: UUID // TODO: this id is presistent!
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    @DeviceState(\.advertisementData) var advertisementData: AdvertisementData

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var battery = BatteryService() // TODO: for the scale as well?
    @Service var bloodPressure = BloodPressureService()
    @Service var omronOptions = OmronOptionService()

    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    @Dependency private var measurementManager: MeasurementManager?
    @Dependency private var deviceManager: DeviceManager?

    @MainActor private var pairingContinuation: CheckedContinuation<Void, Error>?
    // TODO: weight scale has some reserved flag set???

    required init() {
        $state
            .onChange(perform: handleStateChange)
        bloodPressure.$bloodPressureMeasurement
            .onChange(perform: processMeasurement)
        battery.$batteryLevel
            .onChange(perform: handleBatteryChange(_:))
        time.$currentTime
            .onChange(perform: handleCurrentTimeChange(_:))

        // TODO: can we use the configure method to have an already injected peripheral?
    }

    func configure() {
        guard let manufacturerData else {
            return
        }


        print("ManufacturerData2222: \(manufacturerData)")
        if case .pairingMode = manufacturerData.pairingMode {
            Task { @MainActor in
                deviceManager?.nearbyPairableDevice(self)
            }
        }
        
        // TODO: disable auto-connect,
    }

    @MainActor
    func pair() async throws {
        guard case .disconnected = state,
              pairingContinuation == nil else {
            // TODO: what to do?
            // TODO: also pairing mode must be enabled!
            return
        }

        await connect()

        async let _ = withTimeout(of: .seconds(30)) { @MainActor in
            if let pairingContinuation {
                pairingContinuation.resume(throwing: TimeoutError())
                self.pairingContinuation = nil
            }
        }

        // TODO: cancellation handler?
        // TODO: return error if the device disconnects while pairing?
        try await withCheckedThrowingContinuation { continuation in
            self.pairingContinuation = continuation
        }

        // TODO: store paired device identifier
        print("\(id) is now considered paired!")
    }

    private func handleStateChange(_ state: PeripheralState) {
        print("ManufacturerData: \(manufacturerData)")
        guard case .connected = state else {
            return
        }

        // TODO: manufacturerData: 0e020100 090009

        // TODO: the only way to detect successful pairing is by listening for notification on battery level or current time service!

        if let name {
            // TODO: BP5250
            Self.logger.debug("Device \(name) connected ...") // TODO: remove?
        }

        time.synchronizeDeviceTime()

        Task {
            try? await Task.sleep(for: .seconds(1)) // TODO: isNotifying is outdated at this point!
            print("Requesting latest sequence number!")
            do {
                let recordsCount = try await omronOptions.reportNumberOfStoredRecords(.allRecords)
                print("Records count: \(recordsCount)")
                let sequenceNumber = try await omronOptions.reportSequenceNumberOfLatestRecords()

                print("latest sequence number: \(sequenceNumber)")
            } catch {
                print("Error occurred: \(error)")
            }

            do {
                try await omronOptions.reportStoredRecords(.lastRecord)
            } catch {
                print("Failed to report stored records: \(error)")
            }

        }
    }

    private func processMeasurement(_ measurement: BloodPressureMeasurement) {
        guard let measurementManager else {
            preconditionFailure("Measurement Manager was not configured")
        }

        Self.logger.debug("Received new blood pressure measurement: \(String(describing: measurement))")
        measurementManager.handleNewMeasurement(.bloodPressure(measurement, bloodPressure.features ?? []), from: self)
    }

    @MainActor
    private func handleBatteryChange(_ level: UInt8) {
        handleDeviceInteraction()
    }

    @MainActor
    private func handleCurrentTimeChange(_ time: CurrentTime) {
        handleDeviceInteraction()
    }

    @MainActor
    private func handleDeviceInteraction() {
        // any kind of messages received from the the device is interpreted as successful pairing.
        if let pairingContinuation { // TODO: synchronization?
            pairingContinuation.resume()
            self.pairingContinuation = nil
        }
    }
}


extension BloodPressureCuffDevice {
    static func createMockDevice(systolic: MedFloat16 = 103, diastolic: MedFloat16 = 64, pulseRate: MedFloat16 = 62) -> BloodPressureCuffDevice {
        let device = BloodPressureCuffDevice()

        device.deviceInformation.$manufacturerName.inject("Mock Blood Pressure Cuff")
        device.deviceInformation.$modelNumber.inject("1")
        device.deviceInformation.$hardwareRevision.inject("2")
        device.deviceInformation.$firmwareRevision.inject("1.0")

        let features: BloodPressureFeature = [
            .bodyMovementDetectionSupported,
            .irregularPulseDetectionSupported
        ]

        let measurement = BloodPressureMeasurement(
            systolic: systolic,
            diastolic: diastolic,
            meanArterialPressure: 77,
            unit: .mmHg,
            timeStamp: DateTime(year: 2024, month: .june, day: 5, hours: 12, minutes: 33, seconds: 11),
            pulseRate: pulseRate,
            userId: 1,
            measurementStatus: []
        )

        device.bloodPressure.$features.inject(features)
        device.bloodPressure.$bloodPressureMeasurement.inject(measurement)

        device.$id.inject(UUID())
        device.$name.inject("Mock Blood Pressure Cuff")
        device.$state.inject(.connected)

        device.$connect.inject { @MainActor [weak device] in
            device?.$state.inject(.connecting)
            device?.handleStateChange(.connecting)

            try? await Task.sleep(for: .seconds(1))

            device?.$state.inject(.connected)
            device?.handleStateChange(.connected)
        }

        device.$disconnect.inject { @MainActor [weak device] in
            device?.$state.inject(.disconnected)
            device?.handleStateChange(.disconnected)
        }

        return device
    }
}
