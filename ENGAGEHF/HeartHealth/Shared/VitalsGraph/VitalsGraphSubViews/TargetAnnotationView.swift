//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

#if DEBUG || TEST
import Charts
#endif
import SwiftUI


struct TargetAnnotationView: View {
    let target: SeriesTarget
    
    
    var body: some View {
        Text(target.label)
            .font(.caption2)
            .bold()
            .padding(4)
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 4))
    }
    
    
    init(_ target: SeriesTarget) {
        self.target = target
    }
}


#if DEBUG || TEST
#Preview {
    Chart {
        RuleMark(y: .value("Target", 95.0))
            .foregroundStyle(.red)
            .annotation(
                position: .bottomLeading,
                overflowResolution: .init(x: .fit, y: .disabled)
            ) {
                TargetAnnotationView(
                    SeriesTarget(value: 95.0, unit: "lb", date: Date(), label: "Dry Weight")
                )
            }
    }
}
#endif
