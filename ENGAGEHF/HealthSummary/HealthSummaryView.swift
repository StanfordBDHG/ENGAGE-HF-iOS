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
    @State private var healthSummaryDocument: PDFDocument?
    @State private var viewState: ViewState = .idle
    
    private let sharePreviewImage = Image(systemName: "heart.text.square")
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let healthSummaryDocument {
                    PDFViewer(document: healthSummaryDocument)
                } else {
                    ProgressView("Generating Health Summary")
                }
            }
                .task {
                    await self.generateHealthSummary()
                }
                .toolbar {
                    if let healthSummaryDocument {
                        ToolbarItem(placement: .confirmationAction) {
                            ShareLink(
                                item: healthSummaryDocument,
                                preview: SharePreview("Health Summary", image: sharePreviewImage)
                            )
                        }
                    }
                }
                .viewStateAlert(state: $viewState)
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
}


#Preview {
    HealthSummaryView()
}
