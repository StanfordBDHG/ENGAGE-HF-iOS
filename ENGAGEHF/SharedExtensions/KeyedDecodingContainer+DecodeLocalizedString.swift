//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension KeyedDecodingContainer {
    /// Decodes a localized string using the most specific locale possible, and defaulting to "en" if necessary.
    /// If no localization dicionary is present, attempts to decode the key as a string.
    func decodeLocalizedString(forKey key: KeyedDecodingContainer.Key) throws -> String {
        if let localizedMap = try? decodeIfPresent([String: String].self, forKey: key) {
            if let localizedVersion = localizedMap[Locale.current.identifier] {
                return localizedVersion
            } else if let localizedVersion = localizedMap[Locale.current.identifier.components(separatedBy: "-").first ?? ""] {
                return localizedVersion
            } else if let localizedVersion = localizedMap["en"] {
                return localizedVersion
            } else if let localizedVersion = localizedMap.values.first {
                return localizedVersion
            } else {
                throw DecodingError.valueNotFound(String.self, .init(codingPath: [], debugDescription: "No localized string found."))
            }
        } else {
            return try decode(String.self, forKey: key)
        }
    }
    
    /// Decodes a localized string using the most specific locale possible and defaulting to "en" if necessary.
    /// If no localization dicionary is present, attempts to decode the key as a string.
    /// If no String or [String: String] is found for the given key, returns nil.
    func decodeLocalizedStringIfPresent(forKey key: KeyedDecodingContainer.Key) throws -> String? {
        if let localizedMap = try? decodeIfPresent([String: String].self, forKey: key) {
            if let localizedVersion = localizedMap[Locale.current.identifier] {
                return localizedVersion
            } else if let localizedVersion = localizedMap[Locale.current.identifier.components(separatedBy: "-").first ?? ""] {
                return localizedVersion
            } else if let localizedVersion = localizedMap["en"] {
                return localizedVersion
            } else if let localizedVersion = localizedMap.values.first {
                return localizedVersion
            } else {
                throw DecodingError.valueNotFound(
                    String.self,
                    .init(
                        codingPath: [],
                        debugDescription: "String dictionary present but no locale found."
                    )
                )
            }
        } else {
            return try decodeIfPresent(String.self, forKey: key)
        }
    }
}
