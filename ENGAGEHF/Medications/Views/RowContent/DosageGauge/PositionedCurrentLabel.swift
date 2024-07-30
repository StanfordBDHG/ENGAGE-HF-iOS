//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct PositionedCurrentLabel: View {
    let configuration: GaugeStyleConfiguration
    let progressWidth: CGFloat
    let gaugeWidth: CGFloat
    @Binding var currentLabelSize: CGSize
    
    
    var body: some View {
        GeometryReader { geometry in
            let clampedXPosition: CGFloat = {
                if progressWidth < currentLabelSize.width / 2 {
                    return currentLabelSize.width / 2
                }
                if progressWidth > gaugeWidth - currentLabelSize.width / 2 {
                    return gaugeWidth - currentLabelSize.width / 2
                }
                return progressWidth
            }()
            
            configuration.currentValueLabel
                .readSize(CurrentLabelSizeKey.self) {
                    currentLabelSize = $0
                }
                .position(x: clampedXPosition, y: geometry.size.height / 2)
        }
    }
}


#Preview {
    struct PositionedCurrentLabelPreviewWrapper: View {
        @State private var value = 20.0
        private let minimum = 25.0
        private let maximum = 150.0
        
        
        var body: some View {
            VStack {
                Gauge(value: value, in: minimum...maximum) {
                    Text("Expected Progress: \((value - minimum) / (maximum - minimum))")
                } currentValueLabel: {
                    Text(value.asString() + " mg")
                        .background(.yellow)
                } minimumValueLabel: {
                    Text(minimum.asString())
                } maximumValueLabel: {
                    Text("Target")
                }
                    .gaugeStyle(DosageGaugeStyle())
                    .border(.black)
                
                Slider(value: $value, in: (minimum - 5)...(maximum + 5))
                Spacer()
            }
            .padding()
        }
    }
    
    return PositionedCurrentLabelPreviewWrapper()
}
