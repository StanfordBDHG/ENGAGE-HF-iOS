//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import ENGAGEHF
import HealthKit
import XCTest


final class HKSampleGraphUnitTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
    }

    func testHKSampleGraphViewModelWithBloodPressure() throws {
        let viewModel = HKSampleGraph.ViewModel()

        // Generate 5 blood pressure samples, each an hour apart
        let bloodPressureSamples: [HKCorrelation] = [
            try createBloodPressureSample(systolic: 120, diastolic: 80, date: Date().addingTimeInterval(-5 * 60 * 60)),
            try createBloodPressureSample(systolic: 125, diastolic: 82, date: Date().addingTimeInterval(-4 * 60 * 60)),
            try createBloodPressureSample(systolic: 130, diastolic: 85, date: Date().addingTimeInterval(-3 * 60 * 60)),
            try createBloodPressureSample(systolic: 128, diastolic: 84, date: Date().addingTimeInterval(-2 * 60 * 60)),
            try createBloodPressureSample(systolic: 122, diastolic: 81, date: Date().addingTimeInterval(-1 * 60 * 60))
        ].compactMap { $0 }
        
        let expectedOutput: SeriesDictionary = [
            KnownVitalsSeries.bloodPressureSystolic.rawValue: [
                VitalMeasurement(date: Date().addingTimeInterval(-5 * 60 * 60), value: 120, type: KnownVitalsSeries.bloodPressureSystolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-4 * 60 * 60), value: 125, type: KnownVitalsSeries.bloodPressureSystolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-3 * 60 * 60), value: 130, type: KnownVitalsSeries.bloodPressureSystolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-2 * 60 * 60), value: 128, type: KnownVitalsSeries.bloodPressureSystolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-1 * 60 * 60), value: 122, type: KnownVitalsSeries.bloodPressureSystolic.rawValue)
            ],
            KnownVitalsSeries.bloodPressureDiastolic.rawValue: [
                VitalMeasurement(date: Date().addingTimeInterval(-5 * 60 * 60), value: 80, type: KnownVitalsSeries.bloodPressureDiastolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-4 * 60 * 60), value: 82, type: KnownVitalsSeries.bloodPressureDiastolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-3 * 60 * 60), value: 85, type: KnownVitalsSeries.bloodPressureDiastolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-2 * 60 * 60), value: 84, type: KnownVitalsSeries.bloodPressureDiastolic.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-1 * 60 * 60), value: 81, type: KnownVitalsSeries.bloodPressureDiastolic.rawValue)
            ]
        ]
        
        viewModel.processData(data: bloodPressureSamples)
        
        // Make sure the data was properly converted from HKSamples
        validateSeriesDictionary(actualOutput: viewModel.seriesData, expectedOutput: expectedOutput)
        
        // Make sure the correct unit was identified
        XCTAssertEqual(viewModel.displayUnit, "mmHg")
        
        // Make sure the correct formatter was chosen
        XCTAssertEqual(viewModel.formatter([("Systolic", 120.0), ("Diastolic", 60.0)]), "120/60")
    }
    
    func testHKSampleGraphViewModelWithBodyWeight() throws {
        let viewModel = HKSampleGraph.ViewModel()
        
        let unit: HKUnit = Locale.current.measurementSystem == .us ? .pound() : .gramUnit(with: .kilo)
        
        // Generate 5 body mass samples, each an hour apart
        let bodyMassSamples: [HKQuantitySample] = [
            try createBodyMassSample(weight: 70, unit: unit, date: Date().addingTimeInterval(-5 * 60 * 60)),
            try createBodyMassSample(weight: 71, unit: unit, date: Date().addingTimeInterval(-4 * 60 * 60)),
            try createBodyMassSample(weight: 72, unit: unit, date: Date().addingTimeInterval(-3 * 60 * 60)),
            try createBodyMassSample(weight: 73, unit: unit, date: Date().addingTimeInterval(-2 * 60 * 60)),
            try createBodyMassSample(weight: 74, unit: unit, date: Date().addingTimeInterval(-1 * 60 * 60))
        ]
        
        // Define expected output
        let expectedOutput: SeriesDictionary = [
            HKQuantityTypeIdentifier.bodyMass.rawValue: [
                VitalMeasurement(
                    date: Date().addingTimeInterval(-5 * 60 * 60),
                    value: bodyMassSamples[0].quantity.doubleValue(for: unit),
                    type: KnownVitalsSeries.bodyWeight.rawValue
                ),
                VitalMeasurement(
                    date: Date().addingTimeInterval(-4 * 60 * 60),
                    value: bodyMassSamples[1].quantity.doubleValue(for: unit),
                    type: KnownVitalsSeries.bodyWeight.rawValue
                ),
                VitalMeasurement(
                    date: Date().addingTimeInterval(-3 * 60 * 60),
                    value: bodyMassSamples[2].quantity.doubleValue(for: unit),
                    type: KnownVitalsSeries.bodyWeight.rawValue
                ),
                VitalMeasurement(
                    date: Date().addingTimeInterval(-2 * 60 * 60),
                    value: bodyMassSamples[3].quantity.doubleValue(for: unit),
                    type: KnownVitalsSeries.bodyWeight.rawValue
                ),
                VitalMeasurement(
                    date: Date().addingTimeInterval(-1 * 60 * 60),
                    value: bodyMassSamples[4].quantity.doubleValue(for: unit),
                    type: KnownVitalsSeries.bodyWeight.rawValue
                )
            ]
        ]
        
        // Process the data
        viewModel.processData(data: bodyMassSamples)
        
        // Make sure the data was properly converted from HKSamples
        validateSeriesDictionary(actualOutput: viewModel.seriesData, expectedOutput: expectedOutput)
        
        // Make sure the correct unit was identified
        XCTAssertEqual(viewModel.displayUnit, "lb")
        
        // Make sure the correct formatter was chosen
        XCTAssertEqual(viewModel.formatter([(HKQuantityTypeIdentifier.bodyMass.rawValue, 120.0), ("Diastolic", 60.0)]), "120.0")
    }
    
    func testHKSampleGraphViewModelWithHeartRate() throws {
        let viewModel = HKSampleGraph.ViewModel()
        
        // Generate 5 heart rate samples, each an hour apart
        let heartRateSamples: [HKQuantitySample] = [
            try createHeartRateSample(heartRate: 60, date: Date().addingTimeInterval(-5 * 60 * 60)),
            try createHeartRateSample(heartRate: 62, date: Date().addingTimeInterval(-4 * 60 * 60)),
            try createHeartRateSample(heartRate: 64, date: Date().addingTimeInterval(-3 * 60 * 60)),
            try createHeartRateSample(heartRate: 66, date: Date().addingTimeInterval(-2 * 60 * 60)),
            try createHeartRateSample(heartRate: 68, date: Date().addingTimeInterval(-1 * 60 * 60))
        ]
        
        // Define expected output
        let expectedOutput: SeriesDictionary = [
            HKQuantityTypeIdentifier.heartRate.rawValue: [
                VitalMeasurement(date: Date().addingTimeInterval(-5 * 60 * 60), value: 60, type: KnownVitalsSeries.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-4 * 60 * 60), value: 62, type: KnownVitalsSeries.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-3 * 60 * 60), value: 64, type: KnownVitalsSeries.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-2 * 60 * 60), value: 66, type: KnownVitalsSeries.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-1 * 60 * 60), value: 68, type: KnownVitalsSeries.heartRate.rawValue)
            ]
        ]
        
        viewModel.processData(data: heartRateSamples)
        
        // Make sure the data was properly converted from HKSamples
        validateSeriesDictionary(actualOutput: viewModel.seriesData, expectedOutput: expectedOutput)
        
        // Make sure the correct unit was identified
        XCTAssertEqual(viewModel.displayUnit, "BPM")
        
        // Make sure the correct formatter was chosen
        XCTAssertEqual(viewModel.formatter([(HKQuantityTypeIdentifier.heartRate.rawValue, 120.0), ("Diastolic", 60.0)]), "120")
    }
    
    
    private func validateSeriesDictionary(actualOutput: SeriesDictionary, expectedOutput: SeriesDictionary) {
        XCTAssertEqual(actualOutput.count, expectedOutput.count, "The number of series in seriesData does not match the expected output.")
        
        for (key, expectedMeasurements) in expectedOutput {
            guard let actualMeasurements = actualOutput[key] else {
                XCTFail("Missing series for key: \(key)")
                continue
            }
            
            XCTAssertEqual(actualMeasurements.count, expectedMeasurements.count, "Number of measurements for key \(key) does not match.")
            
            for expectedMeasurement in expectedMeasurements {
                XCTAssert(
                    actualMeasurements.contains { measurement in
                        Calendar.current.isDate(measurement.date, equalTo: expectedMeasurement.date, toGranularity: .day) &&
                        measurement.value == expectedMeasurement.value &&
                        measurement.type == expectedMeasurement.type
                    },
                    "Failed to find measurement matching: \(expectedMeasurement)"
                )
            }
        }
    }
    
    private func createBloodPressureSample(systolic: Double, diastolic: Double, date: Date) throws -> HKCorrelation? {
        let systolicType = try XCTUnwrap(HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic))
        let diastolicType = try XCTUnwrap(HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic))
        
        let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: systolic)
        let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: diastolic)
        
        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: date, end: date)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: date, end: date)
        
        let bloodPressureType = try XCTUnwrap(HKCorrelationType.correlationType(forIdentifier: .bloodPressure))
        let bloodPressureCorrelation = HKCorrelation(type: bloodPressureType, start: date, end: date, objects: [systolicSample, diastolicSample])
        
        return bloodPressureCorrelation
    }
    
    private func createBodyMassSample(weight: Double, unit: HKUnit, date: Date) throws -> HKQuantitySample {
        let bodyMassType = try XCTUnwrap(HKQuantityType.quantityType(forIdentifier: .bodyMass))
        let bodyMassQuantity = HKQuantity(unit: unit, doubleValue: weight)
        return HKQuantitySample(type: bodyMassType, quantity: bodyMassQuantity, start: date, end: date)
    }
    
    private func createHeartRateSample(heartRate: Double, date: Date) throws -> HKQuantitySample {
        let heartRateType = try XCTUnwrap(HKQuantityType.quantityType(forIdentifier: .heartRate))
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: heartRate)
        return HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: date, end: date)
    }
}
