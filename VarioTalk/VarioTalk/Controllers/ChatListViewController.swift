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
                    self.chatData.sort { $0.timestamp > $1.timestamp }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            chatIds.forEach { id in
                DB.shared.chatRef.child("chats/\(id)").observe(.childChanged) { snapshot in
//                    guard let self = self else { return }
                    print(id)
                    // 1. 기존 챗데이터 리스트에서 해당 ID 제거
                    //  2. 추가
                    // 3. 인서트로우
                    DB.shared.loadChatData(from: id) { chat in
                        let chat = chat as Chat
                        self.chatData = self.chatData.filter {
                            $0.id! != id
                        }
                        self.chatData.append(chat)
                        self.chatData.sort { $0.timestamp > $1.timestamp}
                        self.tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    func openChat(with friendInfo: [String: Any]) {
        // 새로운 채팅을 열 때는 대상 userInfo로 접근
        // 챗 db에 friendInfo와의 채팅이 존재하는지 확인
        // 해당 채팅이 존재하면 chatViewController로 chatId 전달하며 present, 아니면 nil 전달하며 present
        guard let friendEmail = friendInfo["email"] as? String else { return }
        var targetChatId: String? = nil
        DB.shared.getChatIds(from: UserInfoContext.shared.email) { chatIds in

        }
//        getChatIds {
//            self.chatIds.forEach { chatId in
//                self.chatRef.child("participants").child(chatId).getData { error, snapshot in
//                    if let error = error {
//                        print("Error occured during get participants data. \(error)")
//                    } else if let data = snapshot.value as? NSDictionary {
//                        let counterpart = data.allValues.filter {
//                            ($0 as! String) != UserInfoContext.shared.email
//                        } as! [String]
//                        print(counterpart)
//                        if counterpart.count == 1 && counterpart.first == friendEmail {
//                            // 타겟 friend와의 채팅 찾음
//                            print(counterpart)
//                            targetChatId = chatId
//                            return
//                        }
//                    }
//                }
//            }
//        }
//        let board = UIStoryboard(name: "Main", bundle: nil)
//        let chatVC = board.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
//        chatVC.friendInfo = friendInfo
//        chatVC.chatId = targetChatId
//        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    private func chatReceived() {
        
    }
    
    private func chatAdded() {
        
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
        } else {
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
