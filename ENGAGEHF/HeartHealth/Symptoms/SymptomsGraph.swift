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

struct SymptomsGraph: View {
    var data: [SymptomScore]
    var granularity: DateGranularity
    var symptomType: SymptomsType
    
    @State private var viewState: ViewState = .idle
    @State private var selectedInterval: DateInterval?
    
    private let annotationHeight: CGFloat = 60
    
    private let calendar = Calendar.current
    private let endDate = Date()
    
    
    private var dateDomain: DateInterval {
        do {
            return try granularity.getDateInterval(endDate: endDate)
        } catch {
            viewState = .error(HeartHealthError.invalidDate(endDate))
            return DateInterval(start: .now, end: .now)
        }
    }
    
    // Key: Interval start date
    // Value: The average score during that interval
    private var binnedData: [Date: Double] {
        let filteredData = data.filter { dateDomain.contains($0.date) }
        
        var unaveragedBins: [Date: [Double]] = [:]
        for dataPoint in filteredData {
            guard let binStartDate = getInterval(for: dataPoint.date)?.start else {
                continue
            }
            
            if !unaveragedBins.keys.contains(binStartDate) {
                unaveragedBins[binStartDate] = []
            }
            
            unaveragedBins[binStartDate]?.append(dataPoint[keyPath: symptomType.symptomScoreKeyMap])
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
        Chart(graphableData) { score in
            if let selectedInterval {
                RuleMark(x: .value("Date", selectedInterval.start, unit: granularity.intervalComponent))
                    .foregroundStyle(Color(.lightGray).opacity(0.5))
                    .annotation(
                        position: .topLeading,
                        overflowResolution: .init(x: .fit, y: .disabled)
                    ) {
                        PointDetails(
                            interval: selectedInterval,
                            value: binnedData[selectedInterval.start] ?? 0.0,
                            idealHeight: annotationHeight
                        )
                    }
            }
            
            LineMark(
                x: .value("Date", score.date, unit: granularity.intervalComponent),
                y: .value("Score", score.value)
            )
            
            PointMark(
                x: .value("Date", score.date, unit: granularity.intervalComponent),
                y: .value("Score", score.value)
            )
        }
        .onChange(of: symptomType) { selectedInterval = nil }
        
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                // Convert the tap location to the coordinate space of the plot area
                                let origin = geometry[proxy.plotFrame!].origin
                                let location = CGPoint(
                                    x: value.location.x - origin.x,
                                    y: value.location.y - origin.y
                                )
                                
                                // Get the start-date of the tapped interval, if any
                                if let (date, value) = proxy.value(at: location, as: (Date, Double).self) {
                                    guard let pointInterval = getInterval(for: date),
                                          binnedData[pointInterval.start] != nil else {
                                        // Clicking on "empty space" clears the graph
                                        selectedInterval = nil
                                        return
                                    }
                                    selectedInterval = pointInterval
                                }
                            }
                    )
            }
        }
        
        .chartYScale(domain: 0...100)
        .chartXScale(domain: dateDomain.start...dateDomain.end)
        
        .chartYAxis {
            AxisMarks(
                values: [0, 50, 100]
            ) {
                AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
            }
            
            AxisMarks(
                values: [0, 25, 50, 75, 100]
            ) {
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: data.count))
        }
        
        .frame(maxWidth: .infinity, idealHeight: 200)
        .padding(.top, annotationHeight + 4)
        .viewStateAlert(state: $viewState)
    }
    
    
    func getInterval(for date: Date) -> DateInterval? {
        calendar.dateInterval(of: granularity.intervalComponent, for: date)
    }
}


#Preview {
    SymptomsGraph(data: [], granularity: .weekly, symptomType: .overall)
}
