//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import ENGAGEHF
import XCTest


class ClosedRangeExtendUnitTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    
    func testExtentByPercent() throws {
        let start = 0.0
        let end = 100.0
        let percent = 0.25
        
        let expectedResult = -25.0...125.0
        let result = (start...end).extendBy(percent: percent)
        
        XCTAssertEqual(result, expectedResult, "\(result) not equal to expected result \(expectedResult).")
    }
    
    func testExtentToNearestMultiple() throws {
        let start = 1.0
        let end = 100.0
        let initialRange = start...end
        
        let expectedResultSkippingNone = 0.0...102.0
        let resultSkippingNone = initialRange.extendToMultipleOf(6.0, skipping: 0)
        XCTAssertEqual(
            resultSkippingNone,
            expectedResultSkippingNone,
            "Extended to nearest multiple result \(resultSkippingNone) not equal to expected \(expectedResultSkippingNone)."
        )
        
        let expectedResultSkippingOne = -6.0...108.0
        let resultSkippingOne = initialRange.extendToMultipleOf(6.0, skipping: 1)
        XCTAssertEqual(
            resultSkippingOne,
            expectedResultSkippingOne,
            "Extended to multiple, skipping one result \(resultSkippingOne) not equal to expected \(expectedResultSkippingOne)."
        )
    }
    
    func testInitFromSequence() throws {
        let numbers = [-1, 2, 3, 4, 5, 6, 3]
        
        let expectedRange = -1...6
        let range = try XCTUnwrap(ClosedRange(spanning: numbers))
        XCTAssertEqual(range, expectedRange, "Closed range initialized from sequence \(range) not equal to expected \(expectedRange).")
    }
}
