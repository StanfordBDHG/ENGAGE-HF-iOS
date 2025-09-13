//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
// Based on: https://forums.developer.apple.com/forums/thread/708538
//

public import CoreTransferable
import Foundation
public import PDFKit
import SwiftUI
import UniformTypeIdentifiers

#if compiler(>=6)
extension PDFDocument: @retroactive Transferable {}
#else
extension PDFKit.PDFDocument: SwiftUI.Transferable {}
#endif


extension PDFDocument {
    /// Transfer representation.
    @TransferRepresentationBuilder<PDFDocument> public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .pdf) { pdf in
            if let data = pdf.dataRepresentation() {
                return data
            } else {
                return Data()
            }
        } importing: { data in
            if let pdf = PDFDocument(data: data) {
                return pdf
            } else {
                return PDFDocument()
            }
        }
        DataRepresentation(exportedContentType: .pdf) { pdf in
            if let data = pdf.dataRepresentation() {
                return data
            } else {
                return Data()
            }
        }
    }
}
