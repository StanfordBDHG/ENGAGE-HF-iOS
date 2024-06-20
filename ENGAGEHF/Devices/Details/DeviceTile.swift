//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


struct DeviceTile: View {
    private let deviceInfo: PairedDeviceInfo

    @Environment(DeviceManager.self) private var deviceManager

    private var image: Image {
        deviceInfo.icon?.image ?? Image(systemName: "sensor") // swiftlint:disable:this accessibility_label_for_image
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.accent) // set accent color if one uses sf symbols
                    .symbolRenderingMode(.hierarchical) // set symbol rendering mode if one uses sf symbols
                    .accessibilityHidden(true)
                    .frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 120, alignment: .topLeading)
                Spacer()

                if deviceManager.isConnected(device: deviceInfo.id) {
                    ProgressView()
                }
            }
            Spacer()
            HStack {
                Text(deviceInfo.name)
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                if let percentage = deviceInfo.lastBatteryPercentage {
                    BatteryIcon(percentage: Int(percentage))
                        .labelStyle(.iconOnly)
                }
            }
        }
            .padding(16)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                    .foregroundStyle(Color(uiColor: .secondarySystemGroupedBackground))
            }
            .aspectRatio(1.0, contentMode: .fit) // explicit aspect ratio to ensure tile is always square
    }

    init(_ deviceInfo: PairedDeviceInfo) {
        self.deviceInfo = deviceInfo
    }
}


#if DEBUG
#Preview {
    VStack(spacing: 0) {
        HStack(spacing: 16) {
            Group {
                DeviceTile(PairedDeviceInfo(id: UUID(), name: "BP5250", model: OmronModel.bp5250, icon: .asset("Omron-BP5250")))
                DeviceTile(PairedDeviceInfo(id: UUID(), name: "Health Device 1", model: OmronModel.sc150, icon: nil))
            }
                .background(Color(uiColor: .systemGroupedBackground))
                .frame(maxHeight: 190)
        }
        HStack(spacing: 16) {
            Group {
                DeviceTile(PairedDeviceInfo(id: UUID(), name: "Health Device 2", model: OmronModel.sc150, icon: nil))
                DeviceTile(PairedDeviceInfo(id: UUID(), name: "SC-150", model: OmronModel.bp5250, icon: .asset("Omron-SC-150")))
            }
                .background(Color(uiColor: .systemGroupedBackground))
                .frame(maxHeight: 190)
        }
    }
        .padding([.leading, .trailing], 12)
        .frame(maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .previewWith {
            DeviceManager()
        }
}
#endif
