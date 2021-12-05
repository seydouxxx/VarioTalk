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
    
    init (title: String, lastMessage: String, timestamp: Int) {
        self.title = title
        self.lastMessage = lastMessage
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
