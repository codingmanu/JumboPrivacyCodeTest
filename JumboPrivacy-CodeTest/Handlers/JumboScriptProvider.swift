//
//  JumboScriptProvider.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import Foundation

// Could contain many different scripts to download
enum JumboScript: String {
    case codeTest = "https://jumboassetsv1.blob.core.windows.net/publicfiles/interview_bundle.js"
}

// Basic error handling
enum JumboScriptProviderError: Error {
    case wrongURL
    case networkError
    case invalidResponse
    case decodingError
}

/*
 This object downloads the script, creates an HTML page containing it, saves it to disk and returns
 the file URL so the handler can load it into the WKWebView.
 */
class JumboScriptProvider {
   
    private static let scriptName = "interview_bundle"
    private static var sampleScriptURL = getDocumentsFolderURL().appendingPathComponent(scriptName).appendingPathExtension("js")
    private static var sampleWebURL = getDocumentsFolderURL().appendingPathComponent(scriptName).appendingPathExtension("html")
    
    // Returns the URL for the new file HTML created.
    static func getOperationWebPage(script: JumboScript, completion: @escaping (Result<URL, JumboScriptProviderError>) -> Void ) {
        
        // Checks if the files exists. I'm not checking if the file is outdated or not.
        if FileManager.default.fileExists(atPath: sampleScriptURL.path) && FileManager.default.fileExists(atPath: sampleWebURL.path) {
            completion(.success(sampleWebURL))
        }
        
        // If the file doesn't exist, we download it. Please ignore the force unwrapping ere.
        let url = URL(string: script.rawValue)!
        
        // Could switch to downloadTask
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if error != nil {
                completion(.failure(.networkError))
            }
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            guard let stringData = String(data: data, encoding: .utf8) else {
                completion(.failure(.decodingError))
                return
            }
            try? stringData.write(to: sampleScriptURL, atomically: true, encoding: .utf8)
            createHTMLPage()
            completion(.success(sampleWebURL))
            
        }.resume()
    }
    
    // Creates an HTML page containing the script with matching name.
    private static func createHTMLPage() {
        let htmlString = "<html><body><script src=\"\(sampleScriptURL.lastPathComponent)\"></script></body></html>"
        try? htmlString.write(to: sampleWebURL, atomically: true, encoding: .utf8)
    }
    
    // Helper function to get the documents folder to save the script to.
    private static func getDocumentsFolderURL() -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Documents folder not found")
        }
        return url
    }
}
