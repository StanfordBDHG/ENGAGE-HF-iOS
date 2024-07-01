//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct RecordFormatPicker: View {
    @Binding var recordFormat: RecordFormat
    
    @ScaledMetric private var width: CGFloat = 70
    @ScaledMetric private var height: CGFloat = 30
    
    
    var body: some View {
        Picker("Record Picker", selection: $recordFormat) {
            Image(systemName: "chart.xyaxis.line").tag(RecordFormat.graph)
                .accessibilityLabel("Graph Record Format")
            Image(systemName: "list.bullet").tag(RecordFormat.list)
                .accessibilityLabel("List Record Format")
        }
            .pickerStyle(.segmented)
            .frame(width: width, height: height)
    }
}


#Preview {
    RecordFormatPicker(recordFormat: .constant(.list))
}
