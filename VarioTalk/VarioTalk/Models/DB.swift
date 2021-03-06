//
//  DB.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/06.
//


import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class DB {
    static let shared = DB()
    
    var userDB = Firestore.firestore()
    var chatRef = Database.database(url: Constants.shared.dbUrl).reference()
    
}

//MARK: - DB Work about User
extension DB {
    
    // My email -> all friends email as [String]
    func getMyFriendsEmails(from email: String, completion: @escaping ([String]) -> Void) {
        userDB.collection("User").document(UserInfoContext.shared.email!).getDocument { document, error in
            if let data = document?.data() {
                UserInfoContext.shared.username = (data["username"] as! String)
                
                if let friends = data["friends"] as? [String] {
                    completion(friends)
                }
            }
        }
    }
    
    // email -> UserInfo as Dictionary
    func getUserInfo(from email: String, completion: @escaping ([String: Any]) -> Void) {
        var result: [String: Any] = [:]
        userDB.collection("User").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error occured during get friends info. \(error)")
            } else if let document = snapshot?.documents.first {
                if let username = document.data()["username"] as? String,
                   let email = document.data()["email"] as? String,
                   let image = document.data()["image"] as? [Float] {
                    result = [
                        "username": username,
                        "email": email,
                        "image": image
                    ]
                    completion(result)
                }
            }
        }
    }
    
    // email -> chat id list as [String]
    func getChatIds(from email: String, completion: @escaping ([String]) -> Void) {
        userDB.collection("User").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let chatIds = snapshot?.documents.first?.data()["chats"] as? [String] {
                completion(chatIds)
            }
        }
    }
    
}

//MARK: - Get Chatting Room List
extension DB {
    
    func observeChatRoom(from chatId: String, completion: @escaping () -> Void) {
        
    }
    
    // chatId -> chat metadata as Chat
    func loadChatData(from chatId: String, completion: @escaping (Chat) -> Void) {
        var title = ""
        var lastMessage = ""
        var timestamp = 0
        chatRef.child("chats/\(chatId)").observeSingleEvent(of: DataEventType.value) { snapshot in
            if let data = snapshot.value as? NSDictionary {
                title = data["title"] as! String
                lastMessage = data["lastMessage"] as! String
                timestamp = data["timestamp"] as! Int
                
                let chat = Chat(id: chatId, title: title, lastMessage: lastMessage, timestamp: timestamp)
                completion(chat)
            }
        }
    }
    // chatId -> userInfo as NSDictionary
    func getUserInfoFromChatId(with chatId: String, completion: @escaping ([String: Any]) -> Void) {
        chatRef.child("participants/\(chatId)").getData { error, snapshot in
            if let data = (snapshot.value as? NSDictionary)?.allValues {
                let partnerEmail = (data as! [String]).filter { $0 != UserInfoContext.shared.email }.first!
                self.getUserInfo(from: partnerEmail, completion: { userInfo in
                    completion(userInfo)
                })
            }
        }
    }
    // email -> chatId
    func findChatWithEmail(with email: String, completion: @escaping (String) -> Void) {
        var resultId = ""
        self.getChatIds(from: UserInfoContext.shared.email) { chatIds in
            if chatIds.count == 0 {
                completion(resultId)
            }
            for i in chatIds.startIndex..<chatIds.endIndex {
                self.chatRef.child("participants/\(chatIds[i])").getData { error, snapshot in
                    if let data = (snapshot.value as? NSDictionary)?.allValues as? [String] {
                        if data.count == 2,
                           data.contains(UserInfoContext.shared.email),
                           data.contains(email) {
                            resultId = chatIds[i]
                        }
                        
                        if i == chatIds.endIndex-1 {
                            completion(resultId)
                        }
                    }
                }
            }
        }
    }
    
    // email -> chatId as String
    func createNewChat(with email: String, message: Message, completion: @escaping (String) -> Void) {
        let chatId = UUID().uuidString
        
        guard let msgContent = message.content else { return }
        guard let msgSender = message.sender else { return }
        guard let msgTimestamp = message.timestamp else { return }
        guard let msgIsRead = message.isRead else { return }
        
        // ????????? ?????? ??????
        chatRef.child("messages/\(chatId)/message1").setValue([
            "message": msgContent,
            "sender": msgSender,
            "timestamp": msgTimestamp,
            "isRead": msgIsRead
        ])
        self.getUserInfo(from: email, completion: { friendInfo in
            // ????????? ?????? ??????
            self.chatRef.child("participants/\(chatId)").setValue([
                (friendInfo["username"] as! String): email,
                UserInfoContext.shared.username: UserInfoContext.shared.email
            ])
            // ?????? ??????????????? ??????
            self.chatRef.child("chats/\(chatId)").setValue([
                "title": "\(UserInfoContext.shared.username!),\(friendInfo["username"] as! String)",
                "lastMessage": msgContent,
                "timestamp": msgTimestamp,
                "id": chatId
            ])
        })
        // ??? ?????? ????????? chatId ??????
        userDB.collection("User").whereField("email", isEqualTo: UserInfoContext.shared.email!).getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                if var chats = document["chats"] as? [String] {
                    chats.append(chatId)
                    document.reference.updateData([
                        "chats": chats
                    ])
                }
            }
        }
        // ?????? ?????? ????????? chatId ??????
        userDB.collection("User").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                if var chats = document["chats"] as? [String] {
                    chats.append(chatId)
                    document.reference.updateData([
                        "chats": chats
                    ])
                }
            }
        }
        completion(chatId)
    }
    
    //
    func sendMessage(to chatId: String, message: Message, completion: @escaping () -> Void) {
        guard let msgContent = message.content else { return }
        guard let msgSender = message.sender else { return }
        guard let msgTimestamp = message.timestamp else { return }
        guard let msgIsRead = message.isRead else { return }
        
        var prevTitle = ""
        
        self.countMessagesInChat(in: chatId) { count in
            self.chatRef.child("messages/\(chatId)/message\(count+1)").setValue([
                "message": msgContent,
                "sender": msgSender,
                "timestamp": msgTimestamp,
                "isRead": msgIsRead
            ])
        }
        self.chatRef.child("chats/\(chatId)").getData { error, snapshot in
            if let data = snapshot.value as? NSDictionary {
                prevTitle = data["title"] as! String
            }
        }
        self.chatRef.child("chats/\(chatId)").setValue([
            "lastMessage": msgContent,
            "timestamp": msgTimestamp,
            "title": prevTitle,
            "id": chatId
        ])
    }
    
    func countMessagesInChat(in chatId: String, completion: @escaping (UInt) -> Void) {
        chatRef.child("messages/\(chatId)").getData { error, snapshot in
            completion(snapshot.childrenCount)
        }
    }
    
    // TODO: Function Complement
    // chatId -> ??
    func setMessagesIsRead(for chatId: String, completion: @escaping (String) -> Void) {
        chatRef.child("messages/\(chatId)").getData { error, snapshot in
            if let values = (snapshot.value as? NSDictionary)?.allValues,
               let keys = (snapshot.value as? NSDictionary)?.allKeys {
                for i in keys.startIndex..<keys.endIndex {
                    guard let message = values[i] as? NSDictionary else { return }
                    if (message["sender"] as! String) != UserInfoContext.shared.email {
                        self.chatRef.child("messages/\(chatId)/\(keys[i])").updateChildValues(["isRead": true])
                    }
                }
//                values.forEach { message in
//                    guard let message = message as? NSDictionary else { return }
//                    if (message["sender"] as! String) != UserInfoContext.shared.email {
//
//                    }
//                }
            }
        }
    }
}
