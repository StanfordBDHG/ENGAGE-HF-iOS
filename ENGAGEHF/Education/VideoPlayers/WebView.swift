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
    
    
    func makeCoordinator() -> ProgressCoordinator {
        ProgressCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.allowsLinkPreview = true
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
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
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: any Error) {
            parent.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: String(localized: "defaultLoadingError")))
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: any Error) {
            parent.viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: String(localized: "defaultLoadingError")))
        }
    }
}
