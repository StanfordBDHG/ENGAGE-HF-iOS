//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension KeyedDecodingContainer {
    /// Attempts to decode a date from a string assumed to be in ISO8601 Format with the provided options.
    func decodeISO8601Date(
        forKey key: KeyedDecodingContainer.Key,
        options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withFractionalSeconds]
    ) throws -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = options
        
        let dateString = try decode(String.self, forKey: key)
        guard let date = dateFormatter.date(from: dateString) else {
            throw DecodingError.typeMismatch(Date.self, .init(codingPath: codingPath, debugDescription: "Date is not ISO8601 encoded."))
        }
        
        return date
    }
    
    /// Attempts to decode a date from a string assumed to be in ISO8601 Format with the provided options, if present.
    func decodeISO8601DateIfPresent(
        forKey key: KeyedDecodingContainer.Key,
        options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withFractionalSeconds]
    ) throws -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = options
        
        guard let dateString = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        
        guard let date = dateFormatter.date(from: dateString) else {
            throw DecodingError.typeMismatch(Date.self, .init(codingPath: codingPath, debugDescription: "Date is not ISO8601 encoded."))
        }
        
        return date
    }
}
