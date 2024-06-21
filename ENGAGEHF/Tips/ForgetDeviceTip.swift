//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import TipKit


struct ForgetDeviceTip: Tip {
    static let instance = ForgetDeviceTip()

    @Parameter static var hasRemovedPairedDevice: Bool = false

    var title: Text {
        Text("Fully Unpair Device")
    }

    var message: Text? {
        Text("Make sure to to remove the device from the Bluetooth settings to fully unpair the device.")
    }

    var actions: [Action] {
        Action {
            guard let url = URL(string: "App-Prefs:root=General") else {
                return
            }
            UIApplication.shared.open(url)
        } _: {
            Text("Open Settings")
        }
    }

    var image: Image? {
        Image(systemName: "exclamationmark.triangle.fill")
            .symbolRenderingMode(.hierarchical)
    }

    var rules: [Rule] {
        #Rule(Self.$hasRemovedPairedDevice) {
            $0 == true
        }
    }
}
