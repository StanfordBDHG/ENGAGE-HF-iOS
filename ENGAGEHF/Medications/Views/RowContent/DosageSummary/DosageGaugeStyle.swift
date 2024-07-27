//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DosageGaugeStyle: GaugeStyle {
    @ScaledMetric var gaugeHeight: CGFloat = 15
    
    private var currentValueWidth: CGFloat = 0
    private var targetValueWidth: CGFloat = 0
    
    @State private var showTargetLabel = true
    
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let gaugeWidth = geometry.size.width
            let progressWidth: CGFloat = gaugeWidth * configuration.value
            
            VStack {
                configuration.label
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(width: gaugeWidth, height: gaugeHeight)
                        .foregroundStyle(Color(.systemGray6))
                    Capsule()
                        .frame(width: progressWidth, height: gaugeHeight)
                        .foregroundStyle(.accent)
                }
                
                HStack {
                    Spacer()
                        .frame(width: progressWidth)
                    configuration.currentValueLabel
                    Spacer()
                    configuration.maximumValueLabel
                }
            }
        }
        .onAppear {
            // TODO: Calculate label widths for checking overlap
        }
    }
}


#Preview {
    struct DosageGaugeStylePreviewWrapper: View {
        let value = 63.0
        let minimum = 25.0
        let maximum = 150.0
        
        
        var body: some View {
            Gauge(value: value, in: minimum...maximum) {
                Text("Expected Progress: \((value - minimum) / (maximum - minimum))")
            } currentValueLabel: {
                Text(value.asString() + " mg")
            } minimumValueLabel: {
                Text(minimum.asString())
            } maximumValueLabel: {
                Text("Target")
            }
                .gaugeStyle(DosageGaugeStyle())
                .padding()
        }
    }
    
    return DosageGaugeStylePreviewWrapper()
}
