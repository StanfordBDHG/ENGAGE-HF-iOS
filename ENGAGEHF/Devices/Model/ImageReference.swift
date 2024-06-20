//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


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
