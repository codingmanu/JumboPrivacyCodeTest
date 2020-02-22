//
//  JumboOperation.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import Foundation



// Informs status changes to update the views
protocol OperationStatusDelegate: class {
    func operationStatusChanged(status: OperationStatus)
}

/*
 Class containing the bulk of the operation's logic. On this sample it only contains the ID
 but could contain any data needed to complete that operation. Delegate is implemented here
 to be able to update cells individually.
 */
class JumboOperation: NSObject {
    
    let id: String
    private var handler = SampleOperationHandler.shared
    weak var delegate: OperationStatusDelegate?
    
    init(id: String) {
        self.id = id
        super.init()
    }
    
    func getStatus() -> OperationStatus {
        handler.getOperationStatus(operation: self)
    }
    
    func statusChanged(_ status: OperationStatus) {
        delegate?.operationStatusChanged(status: status)
    }
}
