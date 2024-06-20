//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//


struct OmronModel: RawRepresentable {
    let rawValue: String

    init(_ model: String) {
        self.init(rawValue: model)
    }

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}


extension OmronModel {
    /// The Omron SC150 weight scale.
    static let sc150 = OmronModel("SC-150")
    /// The Omron BP5250 blood pressure monitor.
    static let bp5250 = OmronModel("BP5250")
}


extension OmronModel: Codable {
    init(from decoder: any Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.rawValue = try decoder.decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
        var encoder = encoder.singleValueContainer()
        try encoder.encode(rawValue)
    }
}
