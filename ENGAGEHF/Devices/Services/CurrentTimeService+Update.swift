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


extension CurrentTimeService {
    private static var logger: Logger { // TODO: how to deal with that?
        Logger(subsystem: "edu.stanford.bluetooth", category: "CurrentTimeService")
    }

    // TODO: consider moving to SpeziBluetooth!
    func ensureUpdatedTime() { // TODO: better name?
        // check if time update is necessary
        if let currentTime = currentTime,
           let deviceTime = currentTime.time.date {
            // TODO: what are the default (empty values)? is this check sufficient? (check for zero year, month, day?)
            let difference = abs(deviceTime.timeIntervalSinceReferenceDate - Date.now.timeIntervalSinceReferenceDate)
            if difference < 5 {
                // TODO: better value?
                return // we consider 5 second difference accurate enough?)
            }
        }


        // update time if it isn't present or if it is outdated
        Task {
            let exactTime = ExactTime256(from: .now)
            do {
                // TODO: SWIFT TASK CONTINUATION MISUSE: write(data:for:) leaked its continuation!
                try await $currentTime.write(CurrentTime(time: exactTime))
                // TODO: we got 0x80 response!
                Self.logger.debug("Updated weight scale device time to \(String(describing: exactTime))")
            } catch {
                Self.logger.warning("Failed to update current time: \(error)")
            }
        }
    }
}
