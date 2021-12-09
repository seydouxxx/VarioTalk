//
//  Chat.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/05.
//

import Foundation

class ChatInfo: Codable {
    var userInfo: UserInfo!
    var chat: Chat!
    
    init(userInfo: UserInfo, chat: Chat) {
        self.userInfo = userInfo
        self.chat = chat
    }
}
class Chat: Codable {
    var title: String!
    var lastMessage: String!
    var timestamp: Int!
    var id: String!
    
    init (id: String, title: String, lastMessage: String, timestamp: Int) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
}
class UserInfo: Codable {
    var username: String!
    var email: String!
    var image: [Float]
    
    init(username: String, email: String, image: [Float]) {
        self.username = username
        self.email = email
        self.image = image
    }
}

class Message: Codable {
    var content: String!
    var sender: String!
    var timestamp: Int!
    var isRead: Bool!
    
    init(content: String, sender: String, timestamp: Int, isRead: Bool) {
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
        self.isRead = isRead
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
