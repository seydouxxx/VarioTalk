//
//  ChatListViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/01.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var addChatButton: UIButton!
    
    var chatRef: DatabaseReference!
    var db = Firestore.firestore()
//    var chatIds: [String] = []
    var chatData: [Chat] = []
    var chatInfo: [ChatInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initView()
    }
    private func initView() {
        self.navigationController?.navigationBar.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.searchButton.setTitle("", for: .normal)
        self.addChatButton.setTitle("", for: .normal)
        
        self.tableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListTableViewCell")
        
        DB.shared.getChatIds(from: UserInfoContext.shared.email) { chatIds in
            chatIds.forEach { id in
                DB.shared.chatRef.child("chats/\(id)").observe(.value) { snapshot in
                    if let data = snapshot.value as? NSDictionary {
                        guard let title = data["title"] as? String else { return }
                        guard let id = data["id"] as? String else { return }
                        guard let lastMessage = data["lastMessage"] as? String else { return }
                        guard let timestamp = data["timestamp"] as? Int else { return }
                        let chat = Chat(id: id, title: title, lastMessage: lastMessage, timestamp: timestamp)
                        DB.shared.getUserInfoFromChatId(with: id) { userInfo in
                            let username = userInfo["username"] as! String
                            let email = userInfo["email"] as! String
                            let image = userInfo["image"] as! [Float]
                            
                            let userInfo = UserInfo(username: username, email: email, image: image)
                            
                            self.chatInfo = self.chatInfo.filter { chatInfo in
                                chatInfo.chat.id != chat.id
                            }
                            
                            self.chatInfo.append(ChatInfo(
                                userInfo: userInfo,
                                chat: chat))
                            
                            self.chatInfo.sort { $0.chat.timestamp > $1.chat.timestamp }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func openChat(with friendInfo: [String: Any]) {
        
        guard let username = friendInfo["username"] as? String else { return }
        guard let email = friendInfo["email"] as? String else { return }
        guard let image = friendInfo["image"] as? [Float] else { return }
        
        print(username, email, image)
        let board = UIStoryboard.init(name: "Main", bundle: nil)
        let chatVC = board.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        DB.shared.findChatWithEmail(with: friendInfo["email"] as! String) { chatId in
            
            print("-----")
            print(chatId)
            print("-----")
            chatVC.chatId = chatId == "" ? nil : chatId
            chatVC.friendInfo = UserInfo(username: username, email: email, image: image)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
    }
    @IBAction func addChatButtonPressed(_ sender: UIButton) {
        //  call openNewChat
        
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell() }
        let chatInfo = self.chatInfo[indexPath.row]
        cell.nameLabel.text = chatInfo.userInfo.username
        cell.chatImageView.image = UIColor(red: CGFloat(chatInfo.userInfo.image[0]), green: CGFloat(chatInfo.userInfo.image[1]), blue: CGFloat(chatInfo.userInfo.image[2]), alpha: CGFloat(chatInfo.userInfo.image[3])).image(cell.chatImageView.frame.size)
        cell.lastMessageLabel.text = chatInfo.chat.lastMessage
        
        let calendar = Calendar.current
        let elapsedDate = calendar.dateComponents([.day], from: Date(timeIntervalSince1970: Double(chatInfo.chat.timestamp)), to: Date()).day!
        if elapsedDate < 1 {
            cell.timestampLabel.text = dateFormatterInTime(from: chatInfo.chat.timestamp)
        } else if elapsedDate < 2 {
            cell.timestampLabel.text = "어제"
        } else {
            cell.timestampLabel.text = dateFormatterInDate(from: chatInfo.chat.timestamp)
        }
        
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.chatId = self.chatInfo[indexPath.row].chat.id
        chatVC.friendInfo = self.chatInfo[indexPath.row].userInfo
        self.navigationController?.pushViewController(chatVC, animated: true)
        return
    }
}
