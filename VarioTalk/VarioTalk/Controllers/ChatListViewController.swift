//
//  ChatListViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/01.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var addChatButton: UIButton!
    
    var chatRef: DatabaseReference!
    var db = Firestore.firestore()
    var chatIds: [String] = []
    var chatData: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListTableViewCell")
        
        self.initView()
    }
    private func initView() {
        self.navigationController?.navigationBar.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.searchButton.setTitle("", for: .normal)
        self.addChatButton.setTitle("", for: .normal)
        
        let userRef = self.db.collection("User").whereField("email", isEqualTo: UserInfoContext.shared.email!)
        userRef.getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                self.chatIds = (document.data()["chats"] as? [String])!
                
                self.chatRef = Database.database(url: "https://variotalk-5c614-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                self.loadChats()
                print(self.chatIds)
            }
        }
        
    }
    private func loadChats() {
        self.chatIds.forEach { chatId in
            self.chatRef.child("chats").child(chatId).observe(.value) { snapshot in
                
                if let data = snapshot.value as? NSDictionary {
                    let title = data["title"] as? String ?? ""
                    let lastMessage = data["lastMessage"] as? String ?? ""
                    let timestamp = data["timestamp"] as! Int
                    self.chatData.append(Chat(title: title, lastMessage: lastMessage, timestamp: timestamp))
                    self.tableView.reloadData()
                }
            }
        }
    }
    private func chatReceived() {
        
    }
    
    private func chatAdded() {
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
    }
    @IBAction func addChatButtonPressed(_ sender: UIButton) {
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell() }
        
        let chat = self.chatData[indexPath.row]
        
        cell.nameLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}

//[
//    [
//        "chatID": {
//            lastMessage = "last message contents";
//            timestamp = 1459361875666;
//            title = chatRoomTitle;
//        }
//    ]
//]
//[
//    [
//        "chatID": {
//            lastMessage = "last message contents";
//            timestamp = 1459361875666;
//            title = chatRoomTitle;
//        }
//    ],
//    [
//        "chatID2": {
//            lastMessage = "second Chat content";
//            timestamp = 123123123;
//            title = "second chat title";
//        }
//    ]
//]
