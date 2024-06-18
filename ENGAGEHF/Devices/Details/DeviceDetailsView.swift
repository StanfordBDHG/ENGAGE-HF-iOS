//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import SpeziViews

// TODO: 180x120 ASKit dimenaions


struct DeviceDetailsView: View {
    private let deviceDetails: PairedDeviceInfo

    @Environment(\.dismiss) private var dismiss

    @State private var presentForgetConfirmation = false

    var body: some View {
        List {
            // TODO: show picture?
            NavigationLink {
                EmptyView()
            } label: {
                ListRow("Name") { // TODO: edit functionality?
                    Text(deviceDetails.name)
                }
            }


            Section {
                Button("Forget This Device") {
                    presentForgetConfirmation = true
                    // TODO: erase pairing, + confimration!
                }
            } footer: {
                Text(.now.addingTimeInterval(-150000), style: .time)
                Text(DateInterval(start: .now, duration: 15))
                Text("This device was last seen at 19:46") // TODO: time formatter (days, vs. time vs. exact time)
            }
        }
            .navigationTitle("Device Details")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Do you really want to forget this device?", isPresented: $presentForgetConfirmation, titleVisibility: .visible) {
                Button("Forget Device", role: .destructive) {
                    ForgetDeviceTip.hasRemovedPairedDevice = true
                    // TODO: forget device!
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
    }


    init(_ deviceDetails: PairedDeviceInfo) {
        self.deviceDetails = deviceDetails
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        DeviceDetailsView(PairedDeviceInfo(id: UUID(), name: "BP5250", model: "BP5250", icon: .asset("Omron-BP5250")))
    }
}
#endif
