//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension Array: RawRepresentable where Element: Codable {
    public var rawValue: String {
        let data: Data
        do {
            data = try JSONEncoder().encode(self)
        } catch {
            ENGAGEHF.logger.error("Failed to encode \(Self.self): \(error)")
            return "[]"
        }
        guard let rawValue = String(data: data, encoding: .utf8) else {
            ENGAGEHF.logger.error("Failed to convert data of \(Self.self) to string: \(data)")
            return "[]"
        }

        return rawValue
    }
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else {
            ENGAGEHF.logger.error("Failed to convert string of \(Self.self) to data: \(rawValue)")
            return nil
        }

        do {
            self = try JSONDecoder().decode([Element].self, from: data)
        } catch {
            ENGAGEHF.logger.error("Failed to decode \(Self.self): \(error)")
            return nil
        }
    }
}
