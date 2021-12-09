//
//  ChatViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/04.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hiddenButton: UIButton!
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var friendInfo: UserInfo!
    var chatId: String?
    var db = Firestore.firestore()
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
    private func initView() {
        self.tabBarController?.tabBar.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.chatTextField.delegate = self
        
        self.titleLabel.text = friendInfo.username
        self.plusButton.setTitle("", for: .normal)
        self.hiddenButton.setTitle("", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapViewToHideKeyboard)))
        
        self.tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        
        print(friendInfo)
        self.loadMessages()
        self.syncMessages()
        guard let chatId = self.chatId else { return }
        DB.shared.setMessagesIsRead(for: chatId) { _ in
            
        }
    }
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let messageText = self.chatTextField.text else { return }
        guard let sender = UserInfoContext.shared.email else { return }
        let timestamp = Int(Date().timeIntervalSince1970)
        let message = Message(content: messageText, sender: sender, timestamp: timestamp, isRead: false)
        print("-*-*")
        print(self.chatId)
        print("-*-*")
        
        if let chatId = self.chatId {
            // 기존 채팅 데이터에 새로운 채팅 내용 추가
            DB.shared.sendMessage(to: chatId, message: message) {
                
            }
        } else {
            // 새로운 채팅 세션인 경우 -> db에 새로운 채팅방 정보 생성
            DB.shared.createNewChat(with: friendInfo.email, message: message) { chatId in
                self.chatId = chatId
                print("chatId: ")
                print(self.chatId)
                self.syncMessages()
            }
        }
        self.chatTextField.text = ""
    }
    func syncMessages() {
        print("sync working?")
        guard let chatId = self.chatId else { return }
        
        print("sync worked!")
        DB.shared.chatRef.child("messages/\(chatId)").observe(.childAdded) { snapshot in
            if let data = snapshot.value as? NSDictionary,
               let msgContent = data["message"] as? String,
               let msgSender = data["sender"] as? String,
               let msgTimestamp = data["timestamp"] as? Int,
               let msgIsRead = data["isRead"] as? Bool {
                self.messages.append(Message(content: msgContent, sender: msgSender, timestamp: msgTimestamp, isRead: msgIsRead))
                let indexPath = IndexPath(row: self.messages.count-1, section: 0)

                self.tableView.insertRows(at: [indexPath], with: .none)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        DB.shared.chatRef.child("messages/\(chatId)").observe(.childChanged) { snapshot in
            print(snapshot.key)
            print(snapshot.value)
            if let data = snapshot.value as? NSDictionary,
               let msgContent = data["message"] as? String,
               let msgSender = data["sender"] as? String,
               let msgTimestamp = data["timestamp"] as? Int,
               let msgIsRead = data["isRead"] as? Bool {
                //TODO: do something
            }
            
        }
    }
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        // TODO: 추후에 통화(오디오/비디오) / 미디어 전송 기능 구현
        
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func loadMessages() {
//        self.chatRef.child("messages").child(chatId).getData { error, snapshot in
//            // 없을 수 있는거 : chatID, messages
//            guard error == nil else {
//                print("Error occured during fetching messages. \(error)")
//                return
//            }
//            guard let messages = snapshot.value as? [String: Any] else { return }
//            let messageData = messages.values
//            messageData.forEach {
//                if let message = $0 as? [String: Any] {
//                    let content = message["message"] as! String
//                    let sender = message["sender"] as! String
//                    let timestamp = message["timestamp"] as! Int
//                    self.messages.append(Message(content: content, sender: sender, timestamp: timestamp))
//                }
//            }
//            self.tableView.reloadData()
//        }
    }
}

//TODO: 델리게이트 패턴 구현해서 채팅 목록에도 즉시 업데이트 되도록 수정해야 함

extension ChatViewController: UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 5
//    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section: \(section)"
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as? ChatTableViewCell else { return UITableViewCell() }
        let message = self.messages[indexPath.row]
        
        cell.messageLabel.text = message.content
        
        // TODO: timestamp 수정해야함
        cell.timeLabel.text = dateFormatterInTime(from: message.timestamp)
        cell.unreadLabel.text = message.isRead ? "" : "1"
        cell.isMine = message.sender == UserInfoContext.shared.email ? true : false
        
        return cell
    }
}
extension ChatViewController: UITableViewDelegate {
    
}

extension ChatViewController: UITextFieldDelegate {
    @objc func keyboardShow(_ notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.3) {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + self.view.safeAreaInsets.bottom - 5)
            }
        }
    }
    @objc func keyboardHide() {
        self.containerView.transform = .identity
    }
    @objc func tapViewToHideKeyboard() {
        self.view.endEditing(true)
    }
}
