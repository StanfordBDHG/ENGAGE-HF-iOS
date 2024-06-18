//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO: DeviceManager (provide a list of Model numbers and associated UI (and default names?)
// TODO: but there is device-specific data?

import SwiftUI
extension Image {
    init(_ reference: ImageReference) {
        switch reference {
        case let .system(name):
            self = .init(systemName: name)
        case let .asset(name, bundle):
            self = .init(name, bundle: bundle)
        }
    }
}


enum ImageReference {
    case system(String)
    case asset(String, bundle: Bundle? = nil)
}


extension ImageReference {
    var image: Image? {
        switch self {
        case let .system(name):
            return Image(systemName: name)
        case let .asset(name, bundle: bundle):
            guard UIImage(named: name, in: bundle, with: nil) != nil else {
                return nil
            }
            return Image(name, bundle: bundle)
        }
    }
}


extension ImageReference: Hashable {}


extension ImageReference: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case bundle
    }

    private enum ReferenceType: String, Codable {
        case system
        case asset
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(ReferenceType.self, forKey: .type)
        let name = try container.decode(String.self, forKey: .name)
        switch type {
        case .system:
            self = .system(name)
        case .asset:
            let bundleURL = try container.decodeIfPresent(URL.self, forKey: .bundle)
            let bundle = bundleURL.flatMap { Bundle(url: $0) }

            self = .asset(name, bundle: bundle)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .system(name):
            try container.encode(ReferenceType.system, forKey: .type)
            try container.encode(name, forKey: .name)
        case let .asset(name, bundle):
            try container.encode(ReferenceType.asset, forKey: .type)
            try container.encode(name, forKey: .name)

            if let bundle {
                try container.encode(bundle.bundleURL, forKey: .bundle)
            }
        }
    }
}


struct PairedDeviceInfo: Codable, Identifiable {
    let id: UUID
    let name: String // TODO: customization?
    let model: String
    let icon: ImageReference?
    let lastSequenceNumber: UInt16?
    let userDatabaseNumber: UInt32? // TODO: default value?
    // TODO: last connected time
    // TODO: last transfer time?
    // TODO: last battery percentage!

    init<Model: RawRepresentable>(
        id: UUID,
        name: String,
        model: Model,
        icon: ImageReference?,
        lastSequenceNumber: UInt16? = nil,
        userDatabaseNumber: UInt32? = nil
    ) where Model.RawValue == String {
        let modelValue = model.rawValue
        self.init(id: id, name: name, model: modelValue, icon: icon, lastSequenceNumber: lastSequenceNumber, userDatabaseNumber: userDatabaseNumber)
    }

    init(id: UUID, name: String, model: String, icon: ImageReference?, lastSequenceNumber: UInt16? = nil, userDatabaseNumber: UInt32? = nil) {
        self.id = id
        self.name = name
        self.model = model
        self.icon = icon
        self.lastSequenceNumber = lastSequenceNumber
        self.userDatabaseNumber = userDatabaseNumber
    }
}

// TODO: sensor.fill as generic icon!
