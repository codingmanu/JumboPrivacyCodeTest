//
//  JumboScriptProvider.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import Foundation

enum JumboScript: String {
    case codeTest = "https://jumboassetsv1.blob.core.windows.net/publicfiles/interview_bundle.js"
}

enum JumboScriptProviderError: Error {
    case wrongURL
    case networkError
    case invalidResponse
    case decodingError
}

class JumboScriptProvider {
    
    static var scripts = Dictionary<JumboScript, String>()
    
    static func getOperationScript(script: JumboScript, completion: @escaping (Result<String, JumboScriptProviderError>) -> Void ) {
        
        if let savedScript = scripts[script] {
            print("Using cached script.")
            completion(.success(savedScript))
            return
        }
        
        let url = URL(string: script.rawValue)!
        
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
            scripts[script] = stringData
            completion(.success(stringData))
            
        }.resume()
    }
}
