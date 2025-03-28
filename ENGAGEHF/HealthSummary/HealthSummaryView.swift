//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFunctions
import PDFKit
import SpeziViews
import SwiftUI


struct HealthSummaryView: View {
    private enum ShareState {
        case pdf
        case qrCode
    }
    
    @State private var healthSummaryDocument: PDFDocument?
    @State private var viewState: ViewState = .idle
    @State private var url: String?
    @State private var code: String?
    @State private var expirationTime: Date?
    @State private var shareState: ShareState = .pdf
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var timeRemaining: Int? {
        guard let expirationTime = expirationTime else {
            return nil
        }
        let remaining = Int(expirationTime.timeIntervalSince(currentTime))
        return remaining > 0 ? remaining : 0
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if shareState == .pdf {
                    pdfView
                } else {
                    qrCodeView
                }
            }
                .toolbar {
                    shareButton
                    shareModeSelector
                }
                .viewStateAlert(state: $viewState)
        }
        .onReceive(timer) { time in
            currentTime = time
            if let timeRemaining = self.timeRemaining, timeRemaining <= 0 {
                Task {
                    await self.fetchLink()
                }
            }
        }
    }
    
    
    private var pdfView: some View {
        ZStack {
            if let healthSummaryDocument {
                PDFViewer(document: healthSummaryDocument)
            } else {
                ProgressView("Generating Health Summary")
            }
        }
        .task {
            await generateHealthSummary()
        }
    }
    
    private var qrCodeView: some View {
        ZStack {
            if let url, let code, let timeRemaining {
                QRCodeShareView(url: url, code: code, timeRemaining: timeRemaining)
            } else {
                ProgressView("Generating QR Code")
            }
        }
        .task {
            await fetchLink()
        }
    }
    
    private var shareButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if let healthSummaryDocument, shareState == .pdf {
                ShareLink(
                    item: healthSummaryDocument,
                    preview: SharePreview("Health Summary", image: Image(.engagehfIcon))
                )
                .accessibilityLabel("Share Link")
            } else if let url, shareState == .qrCode {
                ShareLink(
                    // swiftlint:disable:next force_unwrapping
                    item: URL(string: url)!,
                    preview: SharePreview("Health Summary Link", image: Image(.engagehfIcon))
                )
                .accessibilityLabel("Share Link")
            }
        }
    }
    
    private var shareModeSelector: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("Health Summary Share Mode", selection: $shareState) {
                Text("PDF").tag(ShareState.pdf)
                Text("QR Code").tag(ShareState.qrCode)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func generateHealthSummary() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }

            let exportHealthSummary = Functions.functions().httpsCallable("exportHealthSummary")
            let result = try await exportHealthSummary.call([ "userId": userId ] )
            
            let dataDictionary = result.data as? [String: Any]
            let content = dataDictionary?["content"] as? String
            
            guard let contentData = content.flatMap({ Data(base64Encoded: $0) }) else {
                return
            }
            
            self.healthSummaryDocument = PDFDocument(data: contentData)
        } catch {
            self.viewState = .error(
                AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: String(localized: "Process timed out.")
                )
            )
        }
    }
    
    private func fetchLink() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            let shareHealthSummary = Functions.functions().httpsCallable("shareHealthSummary")
            let result = try await shareHealthSummary.call([ "userId": userId ] )
            
            let dataDictionary = result.data as? [String: Any]
            self.url = dataDictionary?["url"] as? String
            self.code = dataDictionary?["code"] as? String
            if let expiresAtString = dataDictionary?["expiresAt"] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds,
                    .withTimeZone
                ]
                if let expiresAt = formatter.date(from: expiresAtString) {
                    let timeInterval = expiresAt.timeIntervalSinceNow
                    if timeInterval > 0 && timeInterval < 60 * 10 {
                        self.expirationTime = expiresAt
                    }
                }
            }
        } catch {
            self.viewState = .error(
                AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: String(localized: "Process timed out.")
                )
            )
        }
    }
}


#Preview {
    HealthSummaryView()
}
