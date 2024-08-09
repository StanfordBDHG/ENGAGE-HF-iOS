//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum CurrentLabelAlignment {
    case leading
    case dynamic
}


struct DosageGaugeStyle: GaugeStyle {
    private let currentLabelAlignment: CurrentLabelAlignment
    @ScaledMetric private var gaugeHeight: CGFloat = 15
    
    @State private var gaugeWidth: CGFloat = 0.0
    @State private var currentLabelSize: CGSize = .zero
    @State private var targetLabelSize: CGSize = .zero
    
    
    init(currentLabelAlignment: CurrentLabelAlignment = .dynamic) {
        self.currentLabelAlignment = currentLabelAlignment
    }
    
    
    func makeBody(configuration: Configuration) -> some View {
        let progressWidth: CGFloat = gaugeWidth * configuration.value
        
        
        VStack {
            configuration.label
            
            CapsuleStack(gaugeWidth: gaugeWidth, gaugeHeight: gaugeHeight, progressWidth: progressWidth)
                .readSize(GaugeSizeKey.self) {
                    gaugeWidth = $0.width
                }
            
            if currentLabelAlignment == .dynamic {
                ZStack {
                    PositionedCurrentLabel(
                        configuration: configuration,
                        progressWidth: progressWidth,
                        gaugeWidth: gaugeWidth,
                        currentLabelSize: $currentLabelSize
                    )
                    
                    if progressWidth + currentLabelSize.width / 2 < gaugeWidth - targetLabelSize.width {
                        HStack {
                            Spacer()
                            configuration.maximumValueLabel
                                .readSize(TargetLabelSizeKey.self) {
                                    targetLabelSize = $0
                                }
                        }
                    }
                }
            } else {
                HStack(alignment: .firstTextBaseline) {
                    configuration.currentValueLabel
                    Spacer()
                    configuration.maximumValueLabel
                }
            }
        }
            .fixedSize(horizontal: false, vertical: true)
    }
}


#Preview {
    struct DosageGaugeStylePreviewWrapper: View {
        @State private var value = 20.0
        private let minimum = 25.0
        private let maximum = 150.0
        
        
        var body: some View {
            VStack {
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
                
                Slider(value: $value, in: (minimum - 5)...(maximum + 5))
                Spacer()
            }
                .padding()
        }
    }
    
    return DosageGaugeStylePreviewWrapper()
}
