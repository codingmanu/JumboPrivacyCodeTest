//
//  OperationHandler.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import UIKit
import WebKit

enum OperationStatus {
    case notLoaded
    case loading
    case ready
    case started
    case inProgress(progress: Float)
    case failed
    case finished
}

// Holds and controls the status of all operations inside the same JS script.
class SampleOperationHandler: NSObject {
    
    // Implemented as singleton to keep one instance of the WKWebview and JS script for all operations
    static let shared = SampleOperationHandler()
    
    private override init() {
        super.init()
        prepareScript()
    }
    
    // Internal Properties
    private var webView = WKWebView()
    private let controller = WKUserContentController()
    private var operationStatus = Dictionary<JumboOperation, OperationStatus>()
    private var isHandlerReady = false
    
    // MARK: - Script and WKWebView configuration

    // Make sure the script is downloaded and ready to use
    private func prepareScript() {
        JumboScriptProvider.getOperationWebPage(script: .codeTest) { [weak self] (result) in
            switch result {
            case .success(let webUrl):
                self?.loadScriptIntoWebview(webUrl)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /*
     Configures the WKWebView and adding the handler (to get updates from the script)
     and the delegate (to know when the view has finished loading). Loads the html file
     containing the script into the WKWebView.
     */
    private func loadScriptIntoWebview(_ webLocalUrl: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let userController = WKUserContentController()
            userController.add(self, name: "jumbo") // Needs to match the handler name in the JS script, in this case window.webkit.messageHandlers.jumbo
            
            let config = WKWebViewConfiguration()
            config.userContentController = userController
            
            self.webView = WKWebView(frame: .zero, configuration: config)
            self.webView.navigationDelegate = self
            
            self.webView.loadFileURL(webLocalUrl, allowingReadAccessTo: webLocalUrl.deletingLastPathComponent())
        }
    }
    
    // MARK: - Add/Star operations
    func addOperation(operation: JumboOperation) {
        if isHandlerReady {
            operationStatus[operation] = .ready
        } else {
            operationStatus[operation] = .loading
        }
        operation.statusChanged(operationStatus[operation]!)
    }
    
    func startOperation(operation: JumboOperation) {
        operationStatus[operation] = .started
        self.webView.evaluateJavaScript("startOperation('\(operation.id)');") { [weak self] (result, error) in
            guard let self = self else { return }
            if error != nil {
                self.operationStatus[operation] = .failed
            }
        }
        operation.statusChanged(operationStatus[operation]!)
    }
    
    // Since the handler owns the operations, we return a sorted array for the tableView.
    func getOperations() -> [JumboOperation] {
        return Array(operationStatus.keys.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.id < rhs.id
        }))
    }
    
    // Returns the status for the operation
    func getOperationStatus(operation: JumboOperation) -> OperationStatus {
        return operationStatus[operation] ?? .notLoaded
    }
}

// MARK:- Delegate / Handler Extensions

extension SampleOperationHandler: WKNavigationDelegate {
    
    // Changes the status from loading to ready when the WKWebView finishes loading.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isHandlerReady = true
        for operation in operationStatus.keys {
            operationStatus[operation] = .ready
            operation.statusChanged(.ready)
        }
    }
}

extension SampleOperationHandler: WKScriptMessageHandler {
    
    // Handles notifications from the JS script.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // Make sure the message is usable
        guard let stringBody = message.body as? String else { return }
        guard let data = stringBody.data(using: .utf8) else { return }
        
        // Decode the message into a SampleResponse
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(SampleResponse.self, from: data)
            
            // Update the status for the specific operation received in the message
            guard let operation = operationStatus.filter({ (key, value) -> Bool in
                return key.id == response.id
            }).first?.key else { return }
            
            guard var status = operationStatus[operation] else { return }
            
            if response.state == .error {
                status = .failed
            } else if response.message == .completed {
                status = .finished
            }
            if response.progress != nil {
                let progress = Float(response.progress!)
                status = .inProgress(progress: progress)
            }
            
            // Notify the operation that its status changed
            operation.statusChanged(status)
            
            // For debugging purposes.
            print("Response: \(response)")
        } catch let error {
            print("Error decoding: \(error)")
        }
    }
}
