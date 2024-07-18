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
    @Observable
    class ViewModel {
        var viewState: ViewState = .idle
        
        private(set) var aggregatedData: [AggregatedMeasurement] = []
        private(set) var multipleTypesPresent = false
        private(set) var overallAverages: [String: Double] = [:]
        private(set) var selection: (interval: Range<Date>, points: [AggregatedMeasurement])?
        
        private var dateUnit: Calendar.Component = .day
        private var dateRange: ClosedRange<Date> = Date()...Date()
        private let calendar = Calendar.current
        private typealias SeriesDictionary = [String: [Date: (score: Double, count: Int)]]
        
        
        /// Prepares the given array of VitalGraphMeasurements for display
        /// Aggregates the data by calculating the average across the intervals determined by granularity
        /// Calculates and saves the granularity, date range, aggregated data, and binned data
        func processData(_ data: [VitalMeasurement], dateRange: ClosedRange<Date>, dateUnit: Calendar.Component) {
            let dataBins: SeriesDictionary = binData(data, dateRange: dateRange, dateUnit: dateUnit)
            
            /// The aggregated data, in a RandomAccessCollection as required for the Chart
            let processedData: [AggregatedMeasurement] = {
                dataBins.flatMap { type, seriesDict in
                    seriesDict.map { date, aggregated in
                        AggregatedMeasurement(
                            date: date,
                            value: aggregated.score,
                            count: aggregated.count,
                            type: type
                        )
                    }
                }
                .sorted { $0.type > $1.type }
                .sorted { $0.date < $1.date }
            }()
            
            self.overallAverages = calculateAverages(data)
            self.aggregatedData = processedData
            self.multipleTypesPresent = dataBins.keys.count > 1
            self.selection = nil
            self.dateUnit = dateUnit
            self.dateRange = dateRange
        }
        
        func selectPoint(value: GestureValue, proxy: ChartProxy, geometry: GeometryProxy, clearOnGap: Bool) {
            // Convert the tap location to the coordinate space of the plot area
            let origin = geometry[proxy.plotFrame!].origin
            let location = CGPoint(
                x: value.eventLocation.x - origin.x,
                y: value.eventLocation.y - origin.y
            )
            
            // Mark the points in the tapped interval as selected, if there are any
            if let (date, _) = proxy.value(at: location, as: (Date, Double).self) {
                // If the user taps or drags outside the edges of the graph, then clear the selection
                guard dateRange.contains(date) else {
                    self.selection = nil
                    return
                }
                
                let selectedPoints = aggregatedData.filter { dataPoint in
                    calendar.isDate(dataPoint.date, equalTo: date, toGranularity: dateUnit)
                }
                
                // Optionally, if no point was selected, just use the previously selected point
                guard !selectedPoints.isEmpty,
                      let interval = getInterval(for: date, using: self.calendar, with: dateUnit) else {
                    if clearOnGap {
                        self.selection = nil
                    }
                    return
                }
                
                self.selection = (interval, selectedPoints)
            }
        }
        
        
        private func calculateAverages(_ data: [VitalMeasurement]) -> [String: Double] {
            Dictionary(grouping: data, by: { $0.type })
                .compactMapValues {
                    $0.map(\.value).reduce(0, +) / Double($0.count)
                }
        }

        /// Group the given data by series type, then aggregate each series by averaging over the interval determined by dateUnit
        private func binData(
            _ data: [VitalMeasurement],
            dateRange: ClosedRange<Date>,
            dateUnit: Calendar.Component
        ) -> SeriesDictionary {
            Dictionary(grouping: data) { $0.type }
                .compactMapValues { measurements in
                    Dictionary(grouping: measurements) {
                        getInterval(for: $0.date, using: self.calendar, with: dateUnit)?.lowerBound ?? self.calendar.startOfDay(for: $0.date)
                    }
                        .compactMapValues {
                            ($0.map(\.value).reduce(0, +) / Double($0.count), $0.count)
                        }
                }
        }
        
        /// Returns a closed date interval, if possible for the given date
        /// Adjusts the upper bound to be inclusive on both the upper and lower bounds without overlapping adjacent intervals
        private func getInterval(
            for date: Date,
            using calendar: Calendar,
            with dateUnit: Calendar.Component
        ) -> Range<Date>? {
            guard let interval = calendar.dateInterval(of: dateUnit, for: date),
                  let adjustedEnd = calendar.date(byAdding: .second, value: -1, to: interval.end) else {
                return nil
            }
            return interval.start..<adjustedEnd
        }
    }
}
