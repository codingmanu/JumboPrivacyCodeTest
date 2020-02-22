//
//  ViewController.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var operationTableView: UITableView!
       
    // The handler owns the list of operations.
    private var handler = SampleOperationHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        operationTableView.delegate = self
        operationTableView.dataSource = self
        
    }
    
    @IBAction func addOperationButtonTapped(_ sender: Any) {
        let operation = JumboOperation(id: "Operation \(handler.getOperations().count + 1)")
        handler.addOperation(operation: operation)
        
        DispatchQueue.main.async { [weak self] in
            self?.operationTableView.reloadData()
        }
    }
}

// MARK: - Protocol Extensions

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handler.startOperation(operation: handler.getOperations()[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return handler.getOperations().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = OperationCell()
        
        let operation = handler.getOperations()[indexPath.row]
        cell.configure(operation)
        
        return cell
    }
}
