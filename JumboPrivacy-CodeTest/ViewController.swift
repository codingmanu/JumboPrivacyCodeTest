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
    
    private var operations = [JumboOperation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        operationTableView.delegate = self
        operationTableView.dataSource = self
        
    }
    
    @IBAction func addOperationButtonTapped(_ sender: Any) {
        operations.append(JumboOperation(id: "Operation \(operations.count + 1)"))
        
        DispatchQueue.main.async { [weak self] in
            self?.operationTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        operations[indexPath.row].start()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = OperationCell()
        
        let operation = operations[indexPath.row]
        cell.configure(operation)
        
        return cell
    }
}
