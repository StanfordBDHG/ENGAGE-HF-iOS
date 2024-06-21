//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccessoryImageView: View {
    private let device: any HealthDevice

    var body: some View {
        let image = device.icon?.image ?? Image(systemName: "sensor") // swiftlint:disable:this accessibility_label_for_image
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityHidden(true)
                .foregroundStyle(.accent) // set accent color if one uses sf symbols
                .symbolRenderingMode(.hierarchical) // set symbol rendering mode if one uses sf symbols
                .frame(maxWidth: 250, maxHeight: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: 150) // make drag-able area a bit larger
        .background(Color(uiColor: .systemBackground)) // we need to set a non-clear color for it to be drag-able
    }


    init(_ device: any HealthDevice) {
        self.device = device
    }
}


#if DEBUG
#Preview {
    AccessoryImageView(BloodPressureCuffDevice.createMockDevice())
}
#endif
