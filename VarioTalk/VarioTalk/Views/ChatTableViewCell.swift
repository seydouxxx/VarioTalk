//
//  ChatSenderTableViewCell.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/06.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    let messageView = UIView()
    let messageLabel = UILabel()
    let timeLabel = UILabel()
    
    var isMine: Bool! {
        didSet {
            self.messageView.backgroundColor = isMine ? .yellow : .systemGray6
            self.messageLabel.textColor = isMine ? .black : .black
            
            if isMine {
                self.messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
                self.timeLabel.trailingAnchor.constraint(equalTo: self.messageView.leadingAnchor, constant: -10).isActive = true
            } else {
                self.messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
                self.timeLabel.leadingAnchor.constraint(equalTo: self.messageView.trailingAnchor, constant: 10).isActive = true
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.messageView)
        self.addSubview(self.messageLabel)
        self.addSubview(self.timeLabel)
        
        self.messageLabel.numberOfLines = 0
        self.timeLabel.textColor = .lightGray
        self.timeLabel.font = UIFont.systemFont(ofSize: 13)
        
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageView.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.messageView.layer.cornerRadius = 15
        self.messageView.layer.masksToBounds = true
        
        let constraints: [NSLayoutConstraint] = [
            self.messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            self.messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            self.messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            self.messageView.topAnchor.constraint(equalTo: self.messageLabel.topAnchor, constant: -10),
            self.messageView.leadingAnchor.constraint(equalTo: self.messageLabel.leadingAnchor, constant: -15),
            self.messageView.bottomAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 10),
            self.messageView.trailingAnchor.constraint(equalTo: self.messageLabel.trailingAnchor, constant: 15),
            
            self.timeLabel.bottomAnchor.constraint(equalTo: self.messageView.bottomAnchor),
            self.timeLabel.heightAnchor.constraint(equalToConstant: 20)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
