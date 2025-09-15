//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziViews
import SwiftUI


private struct AddMeasurementViewPreviewWrapper: View {
    @State var measurement: GraphSelection?
    let targetMeasurement: GraphSelection
    
    
    var body: some View {
        NavigationStack {
            Button("Trigger Sheet") {
                measurement = targetMeasurement
            }
                .sheet(item: $measurement, onDismiss: { measurement = nil }) { measurement in
                    AddMeasurementView(for: measurement)
                }
        }
    }
    
    
    init(for measurementType: GraphSelection) {
        self.targetMeasurement = measurementType
    }
}


struct AddMeasurementView: View {
    private struct NumberInputRow: View {
        @Binding var fieldDetails: FieldDetails
        
        
        var body: some View {
            HStack {
                Text(fieldDetails.title)
                    .foregroundStyle(.secondary)
                Spacer()
                TextField("", value: $fieldDetails.value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Input: \(fieldDetails.title)")
            }
        }
    }
    
    
    private let type: GraphSelection
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var fields: [FieldDetails]
    @State private var viewState: ViewState = .idle
    
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .foregroundStyle(.secondary)
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .foregroundStyle(.secondary)
                ForEach($fields) { $field in
                    NumberInputRow(fieldDetails: $field)
                }
            }
            .navigationTitle(type.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    AddMeasurementAsyncButton(type: type, fields: fields, date: date, viewState: $viewState)
                        .disabled(fields.contains { $0.value == nil })
                }
            }
        }
            .viewStateAlert(state: $viewState)
    }
    
    
    init(for type: GraphSelection) {
        self.type = type
        
        switch type {
        case .bloodPressure:
            self.fields = [
                FieldDetails(title: "Systolic"),
                FieldDetails(title: "Diastolic")
            ]
        case .weight:
            self.fields = [
                FieldDetails(title: Locale.current.measurementSystem == .us ? "lb" : "kg")
            ]
        case .heartRate:
            self.fields = [
                FieldDetails(title: "BPM")
            ]
        default:
            self.fields = []
            self.viewState = .error(HeartHealthError.addingSymptoms)
        }
    }
}


#Preview("Body Weight") {
    AddMeasurementViewPreviewWrapper(for: .weight)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Heart Rate") {
    AddMeasurementViewPreviewWrapper(for: .heartRate)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}

#Preview("Blood Pressure") {
    AddMeasurementViewPreviewWrapper(for: .bloodPressure)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
