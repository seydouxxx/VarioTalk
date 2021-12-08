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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
    }
    private func initView() {
        self.navigationController?.navigationBar.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.searchButton.setTitle("", for: .normal)
        self.addChatButton.setTitle("", for: .normal)
        
        self.tableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListTableViewCell")
        
        self.chatRef = Database.database(url: Constants.shared.dbUrl).reference()
        
        DB.shared.getChatIds(from: UserInfoContext.shared.email) { chatIds in
            chatIds.forEach { id in
                DB.shared.loadChatData(from: id) { chatData in
                    self.chatData.append(chatData)
                    print("-----------getChatIds")
                    print(self.chatData)
                    self.chatData.sort { $0.timestamp > $1.timestamp }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            chatIds.forEach { id in
                DB.shared.chatRef.child("chats/\(id)").observe(.childChanged) { snapshot in
                    DB.shared.loadChatData(from: id) { chat in
                        let chat = chat as Chat
                        self.chatData = self.chatData.filter {
                            $0.id! != id
                        }
                        self.chatData.append(chat)
                        print("-----------childChanged")
                        print(self.chatData)
                        self.chatData.sort { $0.timestamp > $1.timestamp}
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
            print("load chat list here!")
        }
    }
    //email -> chatId
    func openChat(with friendInfo: [String: Any]) {
        
        //일단 열자
        let board = UIStoryboard.init(name: "Main", bundle: nil)
        let chatVC = board.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.chatId = nil
        chatVC.friendInfo = friendInfo
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
    }
    @IBAction func addChatButtonPressed(_ sender: UIButton) {
        //  call openNewChat
        
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell() }
        
        let chat = self.chatData[indexPath.row]
        
        // 채팅 타이틀 별도 지정 안 되어있고 1대1 채팅인 경우 상대방 이름으로 nameLabel 세팅
        DB.shared.getUserInfoFromChatId(with: self.chatData[indexPath.row].id) { userInfo in
            print("\(indexPath.row) : \(userInfo)")
            if let image = userInfo["image"] as? [Float],
               let name = userInfo["username"] as? String {
                cell.chatImageView.image = UIColor(red: CGFloat(image[0]), green: CGFloat(image[1]), blue: CGFloat(image[2]), alpha: CGFloat(image[3])).image(cell.chatImageView.frame.size)
                cell.nameLabel.text = name
            } else {
                cell.chatImageView.image = UIColor(red: 0, green: 0, blue: 0, alpha: 1).image(cell.chatImageView.frame.size)
                cell.nameLabel.text = chat.title
            }
        }
        cell.lastMessageLabel.text = chat.lastMessage
        
        let calendar = Calendar.current
        let timestampDate = calendar.startOfDay(for: Date(timeIntervalSince1970: Double(chat.timestamp)))
        if 1 > calendar.dateComponents([.day], from: timestampDate, to: Date()).day! {
            cell.timestampLabel.text = dateFormatterInTime(from: chat.timestamp)
        } else if 2 > calendar.dateComponents([.day], from: timestampDate, to: Date()).day! {
            cell.timestampLabel.text = "어제"
        }else {
            cell.timestampLabel.text = dateFormatterInDate(from: chat.timestamp)
        }
        
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.chatId = self.chatData[indexPath.row].id
        DB.shared.getUserInfoFromChatId(with: self.chatData[indexPath.row].id) { friendInfo in
            chatVC.friendInfo = friendInfo
            print(friendInfo)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        return
    }
}
