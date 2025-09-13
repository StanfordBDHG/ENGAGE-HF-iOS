//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI
import WebKit
import Spezi


// Note: This view prints the following errors to the console:
//
// Warning: -[BETextInput attributedMarkedText] is unimplemented
// Failed to request allowed query parameters from WebPrivacy.
//
// However, this seems to be a bug on Apple's end and can be ignored:
// https://stackoverflow.com/questions/78395514/failed-to-request-allowed-query-parameters-from-webprivacy
//
struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var viewState: ViewState
    @State private var retryCount = 0
    private let maxRetries = 3
    
    func makeCoordinator() -> ProgressCoordinator {
        ProgressCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.allowsLinkPreview = true
        webView.navigationDelegate = context.coordinator
        
        loadURL(in: webView)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func loadURL(in webView: WKWebView) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}


extension WebView {
    class ProgressCoordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
            parent.viewState = .processing
#if DEBUG
            if ProcessInfo.processInfo.isPreviewSimulator {
                sleep(4)
            }
#endif
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            parent.viewState = .idle
            parent.retryCount = 0
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: any Error) {
            handleError(error, webView: webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: any Error) {
            handleError(error, webView: webView)
        }
        
        private func handleError(_ error: Error, webView: WKWebView) {
            if parent.retryCount < parent.maxRetries {
                parent.retryCount += 1
                parent.viewState = .processing
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.parent.loadURL(in: webView)
                }
            } else {
                parent.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: String(localized: "defaultLoadingError")))
            }
        }
    }
}
