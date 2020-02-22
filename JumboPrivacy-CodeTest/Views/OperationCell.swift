//
//  OperationCell.swift
//  JumboPrivacy-CodeTest
//
//  Created by Manuel S. Gomez on 2/21/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import UIKit

class OperationCell: UITableViewCell {
        
    private lazy var idLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    private lazy var progressView = UIProgressView(frame: .zero)
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    func configure(_ operation: JumboOperation) {
        
        idLabel.text = operation.id

        operation.setDelegate(self)
        
        addSubview(idLabel)
        addSubview(progressView)
        addSubview(messageLabel)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            idLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            idLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            idLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            progressView.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            messageLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
        self.setStatus(status: operation.getStatus())
    }
    
    func setStatus(status: OperationStatus) {
        
        switch status {
        case .ready:
            self.messageLabel.text = "Tap to start"
            self.resetProgress()
        case .started:
            self.operationStarted()
        case .inProgress(let progress):
            self.progressUpdated(progress)
        case .failed:
            self.operationFailed()
        case .finished:
            self.operationFinished()
        }
    }
    
    private func resetProgress() {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.setProgress(0, animated: true)
        }
    }
    
    private func operationStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = "Operation started"
        }
    }
    
    private func operationFailed() {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = "Operation failed. Tap to restart."
        }
    }
    
    private func progressUpdated(_ progress: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = "In progress"
            self?.progressView.setProgress(progress / 100, animated: true)
        }
    }
    
    private func operationFinished() {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = "Operation finished"
            self?.progressView.setProgress(1.0, animated: true)
        }
    }
}

extension OperationCell: OperationStatusDelegate {

    func operationStatusChanged(status: OperationStatus) {
        setStatus(status: status)
    }
}

