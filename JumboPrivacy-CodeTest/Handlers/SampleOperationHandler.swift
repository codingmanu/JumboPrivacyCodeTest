//
//  OperationHandler.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import UIKit
import WebKit

protocol OperationStatusDelegate: class {
    func operationStatusChanged(status: OperationStatus)
}

class SampleOperationHandler: NSObject, WKNavigationDelegate {

    var webView = WKWebView()
    let controller = WKUserContentController()
    weak var delegate: OperationStatusDelegate?
    var status: OperationStatus = .ready {
        didSet {
            self.delegate?.operationStatusChanged(status: status)
        }
    }
    
    override init() {

    }
    
    func runOperation(_ operation: JumboOperation) {
        JumboScriptProvider.getOperationScript(script: .codeTest) { [weak self] (result) in
            switch result {
            case .success(let script):
                print("Script loaded")
                self?.runScript(script, operation: operation)
            default:
                print("Error")
            }
        }
    }
    
    private func runScript(_ script: String, operation: JumboOperation) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            let userController = WKUserContentController()
            userController.add(self, name: "jumbo")
            
            let config = WKWebViewConfiguration()
            config.userContentController = userController
            
            let script = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            config.userContentController.addUserScript(script)
            
            self.webView = WKWebView(frame: .zero, configuration: config)
            
            let htmlString = """
            <html>
                <script>\(script)</script>
                <script>startOperation("\(operation.id)");</script>
            </html>
            """
            
            self.webView.loadHTMLString(htmlString, baseURL: nil)
            self.status = .started
            self.delegate?.operationStatusChanged(status: self.status)
        }
    }
}

extension SampleOperationHandler: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let stringBody = message.body as? String else { return }
        guard let data = stringBody.data(using: .utf8) else { return }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(SampleResponse.self, from: data)
            
            if response.state == .error {
                status = .failed
            } else if response.message == .completed {
                status = .finished
            }
            if response.progress != nil {
                let progress = Float(response.progress!)
                status = .inProgress(progress: progress)
            }
                        
            print("Response: \(response)")
        } catch let error {
            print("Error decoding: \(error)")
        }
    }
}
