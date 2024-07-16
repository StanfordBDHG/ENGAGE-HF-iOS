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

struct VitalsGraph: View {
    var data: [VitalGraphMeasurement]
    var granularity: DateGranularity
    var displayUnit: String
    
    /// Allow for custom modifiers on the Chart
    var chartModifier: AnyModifier?
    
    @State private var viewState: ViewState = .idle
    @State private var selectedInterval: DateInterval?
    
    private let annotationHeight: CGFloat = 60
    private let calendar = Calendar.current
    
    
    /// The range of dates to include in the data
    private var dataDateRange: DateInterval {
        /// Get range according to the granularity and relative to the current date
        do {
            return try granularity.getDateInterval(endDate: .now)
        } catch {
            viewState = .error(HeartHealthError.invalidDate(.now))
            return DateInterval(start: .now, end: .now)
        }
    }
    
    /// The range of dates to display on the X-axis of the graph
    /// Pad the beginning and end of dataDateRange to the nearest interval
    private var graphDateRange: ClosedRange<Date> {
        guard let upperBoundDate = getInterval(for: dataDateRange.end)?.end,
              let lowerBoundDate = getInterval(for: dataDateRange.start)?.start else {
            viewState = .error(HeartHealthError.invalidDate(.now))
            return Date()...Date()
        }
        
        return lowerBoundDate...upperBoundDate
    }
    
    /// Aggregate the given data into averge scores over each interval at the given granularity
    /// Key: Interval start date
    /// Value: The average score during that interval
    private var binnedData: [Date: Double] {
        let filteredData = data.filter { dataDateRange.contains($0.date) }
        
        var unaveragedBins: [Date: [Double]] = [:]
        for dataPoint in filteredData {
            guard let binStartDate = getInterval(for: dataPoint.date)?.start else {
                continue
            }
            
            if !unaveragedBins.keys.contains(binStartDate) {
                unaveragedBins[binStartDate] = []
            }
            
            unaveragedBins[binStartDate]?.append(dataPoint.value)
        }
        
        var averagedBins: [Date: Double] = [:]
        for (startDate, values) in unaveragedBins {
            guard !values.isEmpty else {
                averagedBins[startDate] = 0.0
                continue
            }
            
            averagedBins[startDate] = values.reduce(0, +) / Double(values.count)
        }
        
        return averagedBins
    }
    
    /// The aggregated data, in a RandomAccessCollection as required for the Chart
    private var graphableData: [VitalGraphMeasurement] {
        binnedData.map { startDate, value in
            VitalGraphMeasurement(
                date: startDate,
                value: value
            )
        }
        .sorted { $0.date < $1.date }
    }
    
    
    var body: some View {
        Chart {
            if let selectedInterval {
                RuleMark(x: .value("Date", selectedInterval.start, unit: granularity.intervalComponent))
                    .foregroundStyle(Color(.lightGray).opacity(0.5))
                    .annotation(
                        position: .top,
                        overflowResolution: .init(x: .fit, y: .disabled)
                    ) {
                        PointDetails(
                            interval: selectedInterval,
                            value: String(format: "%.1f", binnedData[selectedInterval.start] ?? 0.0),
                            unit: displayUnit,
                            idealHeight: annotationHeight
                        )
                    }
            }
            
            ForEach(graphableData) { score in
                LineMark(
                    x: .value("Date", score.date, unit: granularity.intervalComponent),
                    y: .value("Score", score.value)
                )
                
                PointMark(
                    x: .value("Date", score.date, unit: granularity.intervalComponent),
                    y: .value("Score", score.value)
                )
            }
        }
        // Make sure to reset selected interval when, for example, a different symptom score type is selected
        .onChange(of: data) { selectedInterval = nil }
        .onChange(of: granularity) { selectedInterval = nil }
        .onAppear {
            print("Graph Appeared")
            selectedInterval = nil
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                setSelectedInterval(value: value, proxy: proxy, geometry: geometry)
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                setSelectedInterval(value: value, proxy: proxy, geometry: geometry)
                            }
                    )
            }
        }
        .chartXScale(domain: graphDateRange)
        .modifier(chartModifier ?? AnyModifier(EmptyModifier()))
        .frame(maxWidth: .infinity, idealHeight: 200)
        .padding(.top, annotationHeight + 4)
        .viewStateAlert(state: $viewState)
    }
    
    
    private func setSelectedInterval(value: GestureValue, proxy: ChartProxy, geometry: GeometryProxy) {
        // Convert the tap location to the coordinate space of the plot area
        let origin = geometry[proxy.plotFrame!].origin
        let location = CGPoint(
            x: value.eventLocation.x - origin.x,
            y: value.eventLocation.y - origin.y
        )
        
        // Get the start-date of the tapped interval, if any
        if let (date, _) = proxy.value(at: location, as: (Date, Double).self) {
            guard let pointInterval = getInterval(for: date),
                  binnedData[pointInterval.start] != nil else {
                // Clicking on "empty space" clears the graph
                selectedInterval = nil
                return
            }
            selectedInterval = pointInterval
        }
    }
    
    private func getInterval(for date: Date) -> DateInterval? {
        guard let interval = calendar.dateInterval(of: granularity.intervalComponent, for: date),
              let adjustedEnd = calendar.date(byAdding: .second, value: -1, to: interval.end) else {
            return nil
        }
        
        return DateInterval(start: interval.start, end: adjustedEnd)
    }
}


#Preview {
    VitalsGraph(data: [], granularity: .weekly, displayUnit: "lbs")
}
