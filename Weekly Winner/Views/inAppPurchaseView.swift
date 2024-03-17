//
//  inAppPurchaseView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 12/30/23.
//

import Foundation
import SwiftUI
import WebKit

struct purchaseView: View {
    @Binding var value: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
//            Link("Open in Safari", destination: URL(string: "https://wppaypal-zuj4eapv2q-ue.a.run.app/?userID=fg57TZhmLmWH9TT3WCA3WuXT7dy2&amount=50")!)
//                .edgesIgnoringSafeArea(.all)
            CustomWebView(url:  URL(string: "https://wppaypal-zuj4eapv2q-uc.a.run.app/?userID=\(StaticUserData.shared.currentUser.id!)&amount=\(Double(value)/100)")!)
        }
        
    }
}


struct CustomWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // Set a custom user agent
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"

        // Enable JavaScript
        webView.configuration.preferences.javaScriptEnabled = true

        // Enable cookies
        webView.configuration.websiteDataStore = .default()

        // Register the script message handler
        webView.configuration.userContentController.add(context.coordinator, name: "logHandler")

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CustomWebView

        init(_ parent: CustomWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("console.log = function(message) { window.webkit.messageHandlers.logHandler.postMessage(message); };", completionHandler: nil)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logHandler", let messageBody = message.body as? String {
                print("JavaScript Console: \(messageBody)")
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Started navigating to: \(webView.url?.absoluteString ?? "unknown")")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed to navigate: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated {
                // Prevent navigation to other pages
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}


