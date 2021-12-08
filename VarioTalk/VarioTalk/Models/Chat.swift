//
//  Chat.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/05.
//

import Foundation

class Chat: Codable {
    var title: String!
    var lastMessage: String!
    var timestamp: Int!
    var id: String!
//    var primaryTitle: String!
    
    init (id: String, title: String, lastMessage: String, timestamp: Int) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = timestamp
//        self.primaryTitle = primaryTitle
    }
}

class Message: Codable {
    var content: String!
    var sender: String!
    var timestamp: Int!
    
    init(content: String, sender: String, timestamp: Int) {
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
}

//"chats": {
//    "one": {
//      "title": "Historical Tech Pioneers",
//      "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
//      "timestamp": 1459361875666
//    },
//    "two": { ... },
//    "three": { ... }
//},
