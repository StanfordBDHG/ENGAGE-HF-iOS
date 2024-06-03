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
import SpeziBluetooth


class BloodPressureCuffDevice: BluetoothDevice, Identifiable {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "BloodPressureCuffDevice")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var bloodPressure = BloodPressureService()

    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect

    // TODO: user data service?
    // TODO: record access service!

    required init() {
        $state
            .onChange(perform: handleStateChange)
        bloodPressure.$bloodPressureMeasurement
            .onChange(perform: processMeasurement)
    }

    private func handleStateChange(_ state: PeripheralState) {
        guard case .connected = state else {
            return
        }

        time.ensureUpdatedTime()
    }

    private func processMeasurement(_ measurement: BloodPressureMeasurement) {
        // TODO: actually do something with it
        print("Received new measurement: \(measurement)")
    }
}
