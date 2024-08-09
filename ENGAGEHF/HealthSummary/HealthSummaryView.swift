//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFunctions
import SpeziViews
import SwiftUI


struct HealthSummaryView: View {
    @State private var healthSummaryData: Data?
    @State private var viewState: ViewState = .idle
    
    
    var body: some View {
        ZStack {
            if let healthSummaryData {
                PDFViewer(pdfData: healthSummaryData)
            } else {
                ProgressView("Loading Health Summary")
            }
        }
            .task {
                do {
                    guard let userId = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    let exportHealthSummary = Functions.functions().httpsCallable("exportHealthSummary")
                    
                    let result = try await exportHealthSummary.call([ "userId": userId ])
                    
                    print(type(of: result.data), result.data)
                    
                    self.healthSummaryData = result.data as? Data
                } catch {
                    viewState = .error(AnyLocalizedError(error: error))
                }
            }
    }
}


#Preview {
    HealthSummaryView()
}
