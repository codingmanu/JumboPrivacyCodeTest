//
//  JumboOperation.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import Foundation

enum OperationStatus {
    case ready
    case started
    case inProgress(progress: Float)
    case failed
    case finished
}

class JumboOperation: NSObject {
    
    let id: String
    private lazy var handler = SampleOperationHandler()
    
    init(id: String) {
        self.id = id
        super.init()
    }
    
    func setDelegate(_ delegate: OperationStatusDelegate) {
        self.handler.delegate = delegate
    }
    
    func start() {
        switch getStatus() {
        case .ready, .failed:
            handler.runOperation(self)
        default:
            return
        }
    }
    
    func getStatus() -> OperationStatus {
        return self.handler.status
    }
}
