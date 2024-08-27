//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import ENGAGEHF
import XCTest


final class DecodeISO8601DateUnitTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
    func testDecodeISO8601Date() throws {
        struct ISO8601Date: Decodable {
            enum CodingKeys: CodingKey {
                case date
            }
            
            let date: Date
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.date = try container.decodeISO8601Date(forKey: .date)
            }
        }
        
        
        let options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withFractionalSeconds]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = options
        
        let now = Date()
        
        let encodedDate = try JSONEncoder().encode(
            [
                "date": formatter.string(from: now)
            ]
        )
        let decodedDate = try JSONDecoder().decode(ISO8601Date.self, from: encodedDate)
        
        XCTAssert(
            Calendar.current.isDate(decodedDate.date, equalTo: now, toGranularity: .second),
            "Decoded date \(decodedDate.date) not equal to expected date \(now)"
        )
    }
    
    func testDecodeISO8601DateIfPresent() throws {
        struct ISO8601OptionalDate: Decodable {
            enum CodingKeys: CodingKey {
                case date
            }
            
            let date: Date?
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.date = try container.decodeISO8601DateIfPresent(forKey: .date)
            }
        }
        
        
        let options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withFractionalSeconds]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = options
        
        let now = Date()
        
        let encodedDate = try JSONEncoder().encode(
            [
                "date": formatter.string(from: now)
            ]
        )
        let decodedDate = try JSONDecoder().decode(ISO8601OptionalDate.self, from: encodedDate)
        
        XCTAssert(
            Calendar.current.isDate(try XCTUnwrap(decodedDate.date), equalTo: now, toGranularity: .second),
            "Decoded date \(decodedDate.date ?? .distantPast) not equal to expected date \(now)"
        )
        
        let encodedDateAbsent = try JSONEncoder().encode(["": ""])
        let decodedDateAbsent = try JSONDecoder().decode(ISO8601OptionalDate.self, from: encodedDateAbsent)
        
        XCTAssertNil(decodedDateAbsent.date)
    }
}
