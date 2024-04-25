//
//  ContentView.swift
//  wkwebviewTest
//
//  Created by Luka Lešić on 25.04.24.
//

import SwiftUI
import Observation
import UIKit
import WebKit

struct ContentView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text("WKWebView and native Swift communication test")
                .font(.footnote)
            viewModel.webView
        }
        .alert("\(viewModel.email), \(viewModel.name)", isPresented: $viewModel.shouldTriggerAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

@Observable
class ViewModel: NSObject, WKScriptMessageHandler {
    
    var webView: WebView?
    var email: String = ""
    var name: String = ""
    var shouldTriggerAlert = false
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let data = message.body as? [String : String], let name = data["name"], let email = data["email"] {
            showUser(email: email, name: name)
        }
    }
    
    override init() {
        super.init()
        self.webView = WebView(configuration: getWKWebViewConfiguration())
    }
    
    func getWKWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()
        userController.add(self, name: "observer")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        return configuration
    }

    private func showUser(email: String, name: String) {
        self.email = email
        self.name = name
        shouldTriggerAlert = true
    }
}

struct WebView: UIViewRepresentable {
    
    let webView: WKWebView
    
    init(configuration: WKWebViewConfiguration) {
        webView = WKWebView(frame: .zero, configuration: configuration)
        loadPage()
    }
    
    func loadPage() {
        if let url = Bundle.main.url(forResource: "form", withExtension: "html") {
            webView.load(URLRequest(url: url))
        }
    }
        
    func makeUIView(context: Context) -> WKWebView {
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
       if let url = Bundle.main.url(forResource: "form", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("File not found")
        }
    }
}
