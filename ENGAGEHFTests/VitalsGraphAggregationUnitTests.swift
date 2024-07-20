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


class VitalsGraphAggregationUnitTests: XCTestCase {
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
    
    func testAggregationMultipleSeriesMultipleTimeIntervals() throws {
        let viewModel = VitalsGraph.ViewModel()
        let now = Date()
        
        // Generate sample data for the past two weeks relative to now
        let (startDate, sampleData) = try setupSampleDataForMultiSeriesTest(refDate: now)
        
        // Define the expected output (average of 5 points per day)
        let (expectedBWSeries, bwAvg) = try getExpectedSeriesData(startDate: startDate, baseAmount: 70.0, series: "BW")
        let (expectedHRSeries, hrAvg) = try getExpectedSeriesData(startDate: startDate, baseAmount: 60.0, series: "HR")
        
        let expectedAggregatedData = [
            MeasurementSeries(
                seriesName: HKQuantityTypeIdentifier.bodyMass.rawValue,
                data: expectedBWSeries,
                average: bwAvg
            ),
            MeasurementSeries(
                seriesName: HKQuantityTypeIdentifier.heartRate.rawValue,
                data: expectedHRSeries,
                average: hrAvg
            )
        ]
        
        // Create VitalsGraphOptions with daily granularity
        let optionsNoRange = VitalsGraphOptions(
            granularity: .day
        )
        
        // Call processData with no date range provided
        viewModel.processData(sampleData, options: optionsNoRange)
        
        // Validate the results
        validateAggregatedSeries(viewModel.aggregatedData, expected: expectedAggregatedData)
        
        // Make sure the date range was calculated correctly and the options stored
        let expectedStart = Calendar.current.startOfDay(for: startDate)
        let expectedEnd = try XCTUnwrap(Calendar.current.dateInterval(of: .day, for: now.addingTimeInterval(-24 * 60 * 60))).end
        let expectedRange = expectedStart...expectedEnd
        XCTAssertEqual(viewModel.dateRange, expectedRange, "Date range mismatch: expected \(expectedRange) but found \(viewModel.dateRange).")
        
        XCTAssertEqual(viewModel.dateUnit, Calendar.Component.day, "Date unit mismatch.")
        XCTAssertEqual(viewModel.localizedUnitString, optionsNoRange.localizedUnitString, "Localized unit string mismatch.")
        XCTAssertNil(viewModel.selection, "Selection should be nil.")
    }
    
    private func validateAggregatedSeries(_ actualAggregatedData: [MeasurementSeries], expected expectedAggregatedData: [MeasurementSeries]) {
        XCTAssertEqual(
            actualAggregatedData.count,
            expectedAggregatedData.count,
            "The number of series in aggregatedData does not match the expected output."
        )
        
        for expectedSeries in expectedAggregatedData {
            guard let actualSeries = actualAggregatedData.first(where: { $0.seriesName == expectedSeries.seriesName }) else {
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
    }
    
    private func getExpectedSeriesData(startDate: Date, baseAmount: Double, series: String) throws -> ([AggregatedMeasurement], Double) {
        var expectedSeries: [AggregatedMeasurement] = []
        
        var totalQuantity = 0.0
        var numMeasurements = 0
        
        for dayOffset in 0..<14 {
            let date = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate))
            
            let batchTotal = ((baseAmount + Double(dayOffset)) * 5 + (0.0 + 1.0 + 2.0 + 3.0 + 4.0))
            let newAverage = batchTotal / 5.0
            
            expectedSeries.append(
                AggregatedMeasurement(
                    date: date,
                    value: newAverage,
                    count: 5,
                    series: series
                )
            )
            
            totalQuantity += batchTotal
            numMeasurements += 5
        }
        
        return (expectedSeries, totalQuantity / Double(numMeasurements))
    }
    
    private func setupSampleDataForMultiSeriesTest(refDate: Date) throws -> (startDate: Date, data: SeriesDictionary) {
        // Generate sample data over several weeks with multiple data points per day
        var sampleData: SeriesDictionary = [:]
        let startDate = try XCTUnwrap(Calendar.current.date(byAdding: .weekOfYear, value: -2, to: refDate))
        
        for dayOffset in 0..<14 {  // 2 weeks of data
            for pointOffset in 0..<5 {  // 5 data points per day
                let date = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate))
                
                let bodyMassSample = VitalMeasurement(
                    date: date,
                    value: 70 + Double(dayOffset) + Double(pointOffset),
                    type: HKQuantityTypeIdentifier.bodyMass.rawValue
                )
                let heartRateSample = VitalMeasurement(
                    date: date,
                    value: 60 + Double(dayOffset) + Double(pointOffset),
                    type: HKQuantityTypeIdentifier.heartRate.rawValue
                )
                
                sampleData[HKQuantityTypeIdentifier.bodyMass.rawValue, default: []].append(bodyMassSample)
                sampleData[HKQuantityTypeIdentifier.heartRate.rawValue, default: []].append(heartRateSample)
            }
        }
        
        return (startDate, sampleData)
    }
}
