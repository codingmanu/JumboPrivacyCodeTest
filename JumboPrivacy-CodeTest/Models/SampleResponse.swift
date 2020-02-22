//
//  SampleResponse.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import Foundation

// Response model object to match the requirements of the messages the script provided returns.

struct SampleResponse: Codable {
    
    enum Message: String, Codable {
        case progress
        case completed
    }
    
    enum State: String, Codable {
        case started
        case error
        case success
    }
    
    let id: String
    let message: Message
    let progress: Double?
    let state: State?
}
