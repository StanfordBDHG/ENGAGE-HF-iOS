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
        private(set) var selectedPoints: [AggregatedMeasurement] = []
        private(set) var multipleTypesPresent = false
        
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
            
            
            self.aggregatedData = processedData
            self.multipleTypesPresent = dataBins.keys.count > 1
            self.selectedPoints = []
        }
        
//        func selectPoint(value: GestureValue, proxy: ChartProxy, geometry: GeometryProxy) {
//            // Convert the tap location to the coordinate space of the plot area
//            let origin = geometry[proxy.plotFrame!].origin
//            let location = CGPoint(
//                x: value.eventLocation.x - origin.x,
//                y: value.eventLocation.y - origin.y
//            )
//            
//            // Get the start-date of the tapped interval, if any
//            if let (date, _) = proxy.value(at: location, as: (Date, Double).self) {
//                
//                guard let pointInterval =
//                        
//                        
//                        
//                        
//                        getInterval(for: date, using: calendar, with: dateGranularity),
//                      let pointValue = binnedData[pointInterval.start] else {
//                    // Clicking on "empty space" clears the graph
//                    selectedPoint = nil
//                    return
//                }
//                selectedPoint = (pointInterval, pointValue)
//            }
//        }
        
        
        // TODO: Update this documentation
        /// Aggregate the given data into averge scores over each interval at the given granularity
        /// Key: Interval start date
        /// Value: The average score during that interval
        private func binData(
            _ data: [VitalMeasurement],
            dateRange: ClosedRange<Date>,
            dateUnit: Calendar.Component
        ) -> SeriesDictionary {
            let filteredData = data.filter { dateRange.contains($0.date) }
            
            return Dictionary(grouping: filteredData) { $0.type }
                .compactMapValues { measurements in
                    Dictionary(grouping: measurements) {
                        getInterval(for: $0.date, using: self.calendar, with: dateUnit)?.start ?? self.calendar.startOfDay(for: $0.date)
                    }
                        .compactMapValues {
                            ($0.map(\.value).reduce(0, +) / Double($0.count), $0.count)
                        }
                }
        }
        
        /// Returns a closed date interval, if possible for the given date
        /// Adjusts the upper bound to be inclusive on both the upper and lower bounds
        private func getInterval(
            for date: Date,
            using calendar: Calendar,
            with dateUnit: Calendar.Component
        ) -> DateInterval? {
            guard let interval = calendar.dateInterval(of: dateUnit, for: date),
                  let adjustedEnd = calendar.date(byAdding: .second, value: -1, to: interval.end) else {
                return nil
            }
            return DateInterval(start: interval.start, end: adjustedEnd)
        }
    }
}
