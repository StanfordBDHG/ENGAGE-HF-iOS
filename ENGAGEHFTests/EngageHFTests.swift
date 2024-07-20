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


class EngageHFTests: XCTestCase {
    func testAggregationEmptySeries() {
        let viewModel = VitalsGraph.ViewModel()
        
        let emptyData: SeriesDictionary = [:]
        viewModel.processData(emptyData, options: .defaultOptions)
        
        XCTAssertTrue(viewModel.aggregatedData.isEmpty)
    }
    
    func testAggregationSingleSeriesSameInterval() {
        let viewModel = VitalsGraph.ViewModel()
        
        var seedDateComponents = DateComponents()
        seedDateComponents.year = 2024
        seedDateComponents.month = 6
        seedDateComponents.day = 23
        seedDateComponents.hour = 16
        let seedDate = Calendar.current.date(from: seedDateComponents) ?? Date()
        
        let measurements: [VitalMeasurement] = [
            VitalMeasurement(date: seedDate, value: 70, type: "Weight"),
            VitalMeasurement(date: seedDate.addingTimeInterval(60), value: 80, type: "Weight")
        ]
        let data: SeriesDictionary = ["Weight": measurements]
        viewModel.processData(data, options: .defaultOptions)
        
        let seriesCount = viewModel.aggregatedData.count
        XCTAssertEqual(seriesCount, 1, "There should only be one series, but \(seriesCount) present.")
        
        let pointCount = viewModel.aggregatedData[0].data.count
        XCTAssertEqual(pointCount, 1, "There should only be one aggregated point, but \(pointCount) present.")
        
        let numAveraged = viewModel.aggregatedData[0].data[0].count
        XCTAssertEqual(numAveraged, 2, "The point should be the average of 2 values.")
        
        let average = viewModel.aggregatedData[0].data[0].value
        XCTAssertEqual(average, 75.0)
    }
    
    func testAggregationMultipleSeriesMultipleTimeIntervals() {
        let viewModel = VitalsGraph.ViewModel()
        let now = Date()
        
        // Generate sample data over several weeks with multiple data points per day
        var sampleData: SeriesDictionary = [:]
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: now)!
        
        for dayOffset in 0..<14 {  // 2 weeks of data
            for pointOffset in 0..<5 {  // 5 data points per day
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                
                let bodyMassSample = VitalMeasurement(date: date, value: 70 + Double(dayOffset) + Double(pointOffset), type: HKQuantityTypeIdentifier.bodyMass.rawValue)
                let heartRateSample = VitalMeasurement(date: date, value: 60 + Double(dayOffset) + Double(pointOffset), type: HKQuantityTypeIdentifier.heartRate.rawValue)
                
                sampleData[HKQuantityTypeIdentifier.bodyMass.rawValue, default: []].append(bodyMassSample)
                sampleData[HKQuantityTypeIdentifier.heartRate.rawValue, default: []].append(heartRateSample)
            }
        }
        
        // Create VitalsGraphOptions with daily granularity
        let optionsNoRange = VitalsGraphOptions(
            granularity: .day
        )
        
        // Define the expected output (average of 5 points per day)
        var bodyMassData: [AggregatedMeasurement] = []
        var heartRateData: [AggregatedMeasurement] = []
        
        var totalBodyMass = 0.0
        var totalHeartRate = 0.0
        var totalMeasurementCount = 0
        var sampleDate = Date()
        
        for dayOffset in 0..<14 {
            sampleDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
            let bodyMassValue = ((70 + Double(dayOffset)) * 5 + (0.0 + 1.0 + 2.0 + 3.0 + 4.0)) / 5.0
            let heartRateValue = ((60 + Double(dayOffset)) * 5 + (0.0 + 1.0 + 2.0 + 3.0 + 4.0)) / 5.0
            
            bodyMassData.append(AggregatedMeasurement(date: sampleDate, value: bodyMassValue, count: 5, series: HKQuantityTypeIdentifier.bodyMass.rawValue))
            heartRateData.append(AggregatedMeasurement(date: sampleDate, value: heartRateValue, count: 5, series: HKQuantityTypeIdentifier.heartRate.rawValue))
            
            totalBodyMass += (70 + Double(dayOffset)) * 5 + (0.0 + 1.0 + 2.0 + 3.0 + 4.0)
            totalHeartRate += (60 + Double(dayOffset)) * 5 + (0.0 + 1.0 + 2.0 + 3.0 + 4.0)
            totalMeasurementCount += 5
        }
        
        let finalDate = sampleDate
        
        let expectedAggregatedData = [
            MeasurementSeries(
                seriesName: HKQuantityTypeIdentifier.bodyMass.rawValue,
                data: bodyMassData,
                average: totalBodyMass / Double(totalMeasurementCount)
            ),
            MeasurementSeries(
                seriesName: HKQuantityTypeIdentifier.heartRate.rawValue,
                data: heartRateData,
                average: totalHeartRate / Double(totalMeasurementCount)
            )
        ]
        
        // Call processData with no date range provided
        viewModel.processData(sampleData, options: optionsNoRange)
        
        // Validate the results
        XCTAssertEqual(
            viewModel.aggregatedData.count,
            expectedAggregatedData.count,
            "The number of series in aggregatedData does not match the expected output."
        )
        
        for expectedSeries in expectedAggregatedData {
            guard let actualSeries = viewModel.aggregatedData.first(where: { $0.seriesName == expectedSeries.seriesName }) else {
                XCTFail("Failed to find series with name \(expectedSeries.seriesName) in aggregated data.")
                continue
            }
            
            XCTAssertEqual(
                actualSeries.average,
                expectedSeries.average,
                "Average mismatch for series \(expectedSeries.seriesName): Expected \(expectedSeries.average) but found \(actualSeries.average)"
            )
            
            XCTAssertEqual(
                actualSeries.data.count,
                expectedSeries.data.count,
                "Count mismatch for series \(expectedSeries.seriesName): Expected \(expectedSeries.data.count) but found \(actualSeries.data.count)"
            )
            
            for expectedPoint in expectedSeries.data {
                XCTAssert(
                    actualSeries.data.contains { measurement in
                        measurement.value == expectedPoint.value &&
                        measurement.count == expectedPoint.count &&
                        Calendar.current.isDate(measurement.date, equalTo: expectedPoint.date, toGranularity: .day)
                    },
                    "Failed to find measurement matching: \(expectedPoint)"
                )
            }
        }
        
        // Make sure the date range was calculated correctly and the options stored
        let expectedStart = Calendar.current.startOfDay(for: startDate)
        let expectedEnd = Calendar.current.dateInterval(of: .day, for: finalDate)!.end
        let expectedRange = expectedStart...expectedEnd
        XCTAssertEqual(viewModel.dateRange, expectedRange, "Date range mismatch: expected \(expectedRange) but found \(viewModel.dateRange).")
        
        XCTAssertEqual(viewModel.dateUnit, Calendar.Component.day, "Date unit mismatch.")
        XCTAssertEqual(viewModel.localizedUnitString, optionsNoRange.localizedUnitString, "Localized unit string mismatch.")
        XCTAssertNil(viewModel.selection, "Selection should be nil.")
    }
    
    
    func testHKSampleGraphViewModelWithBloodPressure() {
        let viewModel = HKSampleGraph.ViewModel()

        // Generate 5 blood pressure samples, each an hour apart
        let bloodPressureSamples: [HKCorrelation] = [
            createBloodPressureSample(systolic: 120, diastolic: 80, date: Date().addingTimeInterval(-5 * 60 * 60)),
            createBloodPressureSample(systolic: 125, diastolic: 82, date: Date().addingTimeInterval(-4 * 60 * 60)),
            createBloodPressureSample(systolic: 130, diastolic: 85, date: Date().addingTimeInterval(-3 * 60 * 60)),
            createBloodPressureSample(systolic: 128, diastolic: 84, date: Date().addingTimeInterval(-2 * 60 * 60)),
            createBloodPressureSample(systolic: 122, diastolic: 81, date: Date().addingTimeInterval(-1 * 60 * 60))
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
            ],
        ]
        
        viewModel.processData(data: bloodPressureSamples)
        
        
        // Make sure the data was properly converted from HKSamples
        validateSeriesDictionary(actualOutput: viewModel.seriesData, expectedOutput: expectedOutput)
        
        // Make sure the correct unit was identified
        XCTAssertEqual(viewModel.displayUnit, "mmHg")
        
        // Make sure the correct formatter was chosen
        XCTAssertEqual(viewModel.formatter([("Systolic", 120.0), ("Diastolic", 60.0)]), "120/60")
    }
    
    func testHKSampleGraphViewModelWithBodyWeight() {
        let viewModel = HKSampleGraph.ViewModel()
        
        let unit: HKUnit = Locale.current.measurementSystem == .us ? .pound() : .gramUnit(with: .kilo)
        
        // Generate 5 body mass samples, each an hour apart
        let bodyMassSamples: [HKQuantitySample] = [
            createBodyMassSample(weight: 70, unit: unit, date: Date().addingTimeInterval(-5 * 60 * 60)),
            createBodyMassSample(weight: 71, unit: unit, date: Date().addingTimeInterval(-4 * 60 * 60)),
            createBodyMassSample(weight: 72, unit: unit, date: Date().addingTimeInterval(-3 * 60 * 60)),
            createBodyMassSample(weight: 73, unit: unit, date: Date().addingTimeInterval(-2 * 60 * 60)),
            createBodyMassSample(weight: 74, unit: unit, date: Date().addingTimeInterval(-1 * 60 * 60))
        ]
        
        // Define expected output
        let expectedOutput: SeriesDictionary = [
            HKQuantityTypeIdentifier.bodyMass.rawValue: [
                VitalMeasurement(date: Date().addingTimeInterval(-5 * 60 * 60), value: bodyMassSamples[0].quantity.doubleValue(for: unit), type: HKQuantityTypeIdentifier.bodyMass.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-4 * 60 * 60), value: bodyMassSamples[1].quantity.doubleValue(for: unit), type: HKQuantityTypeIdentifier.bodyMass.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-3 * 60 * 60), value: bodyMassSamples[2].quantity.doubleValue(for: unit), type: HKQuantityTypeIdentifier.bodyMass.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-2 * 60 * 60), value: bodyMassSamples[3].quantity.doubleValue(for: unit), type: HKQuantityTypeIdentifier.bodyMass.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-1 * 60 * 60), value: bodyMassSamples[4].quantity.doubleValue(for: unit), type: HKQuantityTypeIdentifier.bodyMass.rawValue)
            ]
        ]
        
        // Process the data
        viewModel.processData(data: bodyMassSamples)
        
        // Make sure the data was properly converted from HKSamples
        validateSeriesDictionary(actualOutput: viewModel.seriesData, expectedOutput: expectedOutput)
        
        // Make sure the correct unit was identified
        XCTAssertEqual(viewModel.displayUnit, "lbs")
        
        // Make sure the correct formatter was chosen
        XCTAssertEqual(viewModel.formatter([(HKQuantityTypeIdentifier.bodyMass.rawValue, 120.0), ("Diastolic", 60.0)]), "120.0")
    }
    
    func testHKSampleGraphViewModelWithHeartRate() {
        let viewModel = HKSampleGraph.ViewModel()
        
        // Generate 5 heart rate samples, each an hour apart
        let heartRateSamples: [HKQuantitySample] = [
            createHeartRateSample(heartRate: 60, date: Date().addingTimeInterval(-5 * 60 * 60)),
            createHeartRateSample(heartRate: 62, date: Date().addingTimeInterval(-4 * 60 * 60)),
            createHeartRateSample(heartRate: 64, date: Date().addingTimeInterval(-3 * 60 * 60)),
            createHeartRateSample(heartRate: 66, date: Date().addingTimeInterval(-2 * 60 * 60)),
            createHeartRateSample(heartRate: 68, date: Date().addingTimeInterval(-1 * 60 * 60))
        ]
        
        // Define expected output
        let expectedOutput: SeriesDictionary = [
            HKQuantityTypeIdentifier.heartRate.rawValue: [
                VitalMeasurement(date: Date().addingTimeInterval(-5 * 60 * 60), value: 60, type: HKQuantityTypeIdentifier.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-4 * 60 * 60), value: 62, type: HKQuantityTypeIdentifier.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-3 * 60 * 60), value: 64, type: HKQuantityTypeIdentifier.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-2 * 60 * 60), value: 66, type: HKQuantityTypeIdentifier.heartRate.rawValue),
                VitalMeasurement(date: Date().addingTimeInterval(-1 * 60 * 60), value: 68, type: HKQuantityTypeIdentifier.heartRate.rawValue)
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
    
    private func createBloodPressureSample(systolic: Double, diastolic: Double, date: Date) -> HKCorrelation? {
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        
        let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: systolic)
        let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: diastolic)
        
        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: date, end: date)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: date, end: date)
        
        let bloodPressureType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
        let bloodPressureCorrelation = HKCorrelation(type: bloodPressureType, start: date, end: date, objects: [systolicSample, diastolicSample])
        
        return bloodPressureCorrelation
    }
    
    private func createBodyMassSample(weight: Double, unit: HKUnit, date: Date) -> HKQuantitySample {
        let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let bodyMassQuantity = HKQuantity(unit: unit, doubleValue: weight)
        return HKQuantitySample(type: bodyMassType, quantity: bodyMassQuantity, start: date, end: date)
    }
    
    private func createHeartRateSample(heartRate: Double, date: Date) -> HKQuantitySample {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: heartRate)
        return HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: date, end: date)
    }
}
