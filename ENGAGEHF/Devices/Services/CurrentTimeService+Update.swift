//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import CoreBluetooth
import Foundation
import OSLog


extension CurrentTimeService {
    private static var logger: Logger {
        Logger(subsystem: "edu.stanford.bluetooth", category: "CurrentTimeService")
    }

    func synchronizeDeviceTime(now: Date = .now) {
        // check if time update is necessary
        if let currentTime = currentTime,
           let deviceTime = currentTime.time.date {
            let difference = abs(deviceTime.timeIntervalSinceReferenceDate - now.timeIntervalSinceReferenceDate)
            if difference < 1 {
                return // we consider 1 second difference accurate enough
            }

            Self.logger.debug("Current time difference is \(difference)s. Device time: \(String(describing: currentTime)). Updating time ...")
        } else {
            Self.logger.debug("Unknown current time (\(String(describing: self.currentTime)). Updating time ...")
        }


        // update time if it isn't present or if it is outdated
        Task {
            let exactTime = ExactTime256(from: now)
            do {
                try await $currentTime.write(CurrentTime(time: exactTime))
                Self.logger.debug("Updated device time to \(String(describing: exactTime))")
            } catch let error as NSError {
                if error.domain == CBATTError.errorDomain {
                    let attError = CBATTError(_nsError: error)
                    if attError.code == CBATTError.Code(rawValue: 0x80) {
                        Self.logger.debug("Device ignored some date fields. Updated device time to \(String(describing: exactTime)).")
                        return
                    }
                }
                Self.logger.warning("Failed to update current time: \(error)")
            }
        }
    }
}
