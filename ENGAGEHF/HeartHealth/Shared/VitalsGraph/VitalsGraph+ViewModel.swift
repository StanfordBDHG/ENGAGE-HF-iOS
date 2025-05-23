//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SpeziViews
import SwiftUI


extension VitalsGraph {
    typealias SelectedInterval = (interval: Range<Date>, points: [AggregatedMeasurement])
    
    
    @Observable
    class ViewModel {
        var viewState: ViewState = .idle
        
        private(set) var aggregatedData: [MeasurementSeries] = []
        private(set) var selection: SelectedInterval?
        private(set) var selectionFormatter: ([(String, Double)]) -> String = { _ in String(localized: "No Data", comment: "No data available") }
        private(set) var localizedUnitString: String?
        private(set) var dateRange: ClosedRange<Date> = Date().addingTimeInterval(-60 * 60 * 24 * 30)...Date()
        private(set) var dateUnit: Calendar.Component = .day
        private(set) var dataValueRange: ClosedRange<Double>?
        private(set) var targetValue: SeriesTarget?
        
        let calendar = Calendar.current
        
        
        var numSeries: Int {
            aggregatedData.count + (targetValue == nil ? 0 : 1)
        }
        
        var totalDataPoints: Int {
            aggregatedData.reduce(0) { $0 + $1.data.reduce(0) { $0 + $1.count } }
        }
        
        
        /// Prepares the given data for display.
        /// Aggregates the data by calculating the average across the intervals determined by the granularity of dateUnit.
        /// Saves the dateRange, dateUnit, and aggregatedData for later use.
        func processData(_ data: SeriesDictionary, options: VitalsGraphOptions) {
            // Aggregate the data across time and group by series type
            let aggregatedSeries: [String: [AggregatedMeasurement]] = aggregateData(data: data, dateUnit: options.granularity)
            let seriesAverages: [String: Double] = data.mapValues { average(series: $0) ?? 0 }
            
            // Organize series data into a list of MeasurementSeries, in order of seriesName
            let seriesData = {
                aggregatedSeries
                    .map { seriesName, data in
                        MeasurementSeries(
                            seriesName: seriesName,
                            data: data.sorted { $0.date < $1.date },
                            average: seriesAverages[seriesName] ?? 0
                        )
                    }
                    .sorted { $0.seriesName > $1.seriesName }
            }()

            self.saveProcessingResults(seriesData: seriesData, options: options)
        }
        
        func selectPoint(value: GestureValue, proxy: ChartProxy, geometry: GeometryProxy, clearOnGap: Bool) {
            // Convert the tap location to the coordinate space of the plot area
            guard let anchor: Anchor<CGRect> = proxy.plotFrame else {
                return
            }
            let origin = geometry[anchor].origin
            let location = CGPoint(
                x: value.eventLocation.x - origin.x,
                y: value.eventLocation.y - origin.y
            )
            
            // If nothing is selected, do nothing
            guard let (date, _) = proxy.value(at: location, as: (Date, Double).self) else {
                return
            }
            
            // If the user taps or drags outside the edges of the graph, then clear the selection and show the header
            guard dateRange.contains(date) else {
                self.selection = nil
                return
            }
            
            // Find the point across all series with the closest date to the tapped date.
            guard let tappedIntervalStartDate = getInterval(date: date, unit: dateUnit)?.start,
                  let dateOfClosestPoint = findDateOfClosestPoint(to: tappedIntervalStartDate, in: aggregatedData) else {
                if clearOnGap {
                    self.selection = nil
                }
                return
            }
            
            // Select that point if it is within tapMargin from the tap location.
            // For consistency across date units/granularities, the tap margin is 4% of the width of the chart.
            let tapMargin = dateRange.lowerBound.distance(to: dateRange.upperBound) * 0.04
            
            guard dateOfClosestPoint.distance(to: tappedIntervalStartDate).magnitude < tapMargin.magnitude else {
                if clearOnGap {
                    self.selection = nil
                }
                return
            }
            
            // Find the points in each series that lie on the date of the closest point, if any.
            let selectedPoints = aggregatedData.flatMap { getPoints(from: $0, onDate: dateOfClosestPoint, granularity: dateUnit) }

            // Optionally, if no point was selected, just use the previously selected point
            guard !selectedPoints.isEmpty,
                  let interval = getInterval(date: dateOfClosestPoint, unit: dateUnit)?.asAdjustedRange(using: calendar) else {
                if clearOnGap {
                    self.selection = nil
                }
                return
            }
            
            self.selection = (interval, selectedPoints)
        }
        
        
        private func saveProcessingResults(seriesData: [MeasurementSeries], options: VitalsGraphOptions) {
            // Save the options for later use
            if let dateRange = options.dateRange {
                self.dateRange = dateRange
            } else {
                if let range = getDateRange(from: seriesData, using: options.granularity) {
                    self.dateRange = range
                }
            }
            self.dateUnit = options.granularity
            self.selectionFormatter = seriesData.isEmpty ?
            { _ in String(localized: "No Data", comment: "No data available") } :
            options.selectionFormatter
            self.localizedUnitString = seriesData.isEmpty ? nil : options.localizedUnitString
            self.selection = nil
            
            self.aggregatedData = seriesData
            
            if let targetValue = options.targetValue {
                self.targetValue = targetValue
            }
            
            if let valueRange = options.valueRange {
                self.dataValueRange = valueRange
            } else {
                var seriesValues = seriesData
                    .flatMap { $0.data }
                    .map { $0.value }
                
                if let targetValue = options.targetValue { seriesValues.append(targetValue.value) }
                
                self.dataValueRange = ClosedRange(spanning: seriesValues)?
                    .extendBy(percent: 0.1)
                    .withMinimumRange(30.0)
                    .extendToMultipleOf(10.0)
            }
        }
        
        
        /// Aggregate each series by averaging over the interval determined by dateUnit.
        /// Records the result as a dictionary mapping the series name to a list of AggregatedMeasurements representing each point in the series.
        private func aggregateData(data: SeriesDictionary, dateUnit: Calendar.Component) -> [String: [AggregatedMeasurement]] {
            let allSeriesData = data.flatMap { seriesName, data in
                Dictionary(grouping: data) {
                    getInterval(date: $0.date, unit: dateUnit)?.start ?? self.calendar.startOfDay(for: $0.date)
                }
                .map { date, measurements in
                    AggregatedMeasurement(
                        date: date,
                        value: average(series: measurements) ?? 0,
                        count: measurements.count,
                        series: seriesName
                    )
                }
            }
            return Dictionary(grouping: allSeriesData) { $0.series }
        }
        
        private func average(series: [VitalMeasurement]) -> Double? {
            guard !series.isEmpty else {
                return nil
            }
            return series.map(\.value).reduce(0, +) / Double(series.count)
        }
        
        private func getDateRange(from data: [MeasurementSeries], using dateUnit: Calendar.Component) -> ClosedRange<Date>? {
            guard !data.isEmpty else {
                return nil
            }
            
            let allDates = data.flatMap { $0.data.map(\.date) }
            
            guard let minDate = allDates.min(), let maxDate = allDates.max() else {
                return nil
            }
            
            guard let domainStart = calendar.dateInterval(of: dateUnit, for: minDate)?.start,
                  let domainEnd = calendar.dateInterval(of: dateUnit, for: maxDate)?.end else {
                return nil
            }
            
            return domainStart ... domainEnd
        }
        
        private func findDateOfClosestPoint(to targetDate: Date, in allSeries: [MeasurementSeries]) -> Date? {
            allSeries
                .flatMap { $0.data.map(\.date) }
                .min { $0.distance(to: targetDate).magnitude < $1.distance(to: targetDate).magnitude }
        }
        
        private func getPoints(from series: MeasurementSeries, onDate date: Date, granularity: Calendar.Component) -> [AggregatedMeasurement] {
            series.data.filter { calendar.isDate($0.date, equalTo: date, toGranularity: granularity) }
        }
        
        private func getInterval(date: Date, unit: Calendar.Component) -> DateInterval? {
            calendar.dateInterval(of: unit, for: date)
        }
    }
}
