//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SwiftUI


struct PDFViewer: UIViewRepresentable {
    let pdfData: Data
    
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: pdfData)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
