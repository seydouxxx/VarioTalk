//
//  FriendsListViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/01.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import RxCocoa
import RxSwift

class FriendsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFriendButton: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    
    var friends: [String]?
    var friendsInfo: [[String: Any]] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        
        self.tableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendTableViewCell")
    }
    
    private func initView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.searchFriendButton.setTitle("", for: .normal)
        self.addFriendButton.setTitle("", for: .normal)
        self.friendsInfo = []
        DB.shared.getMyFriendsEmails(from: UserInfoContext.shared.email!) { friends in
            self.friends = friends
            self.loadFriends()
        }
    }
    
    private func loadFriends() {
        self.friends?.forEach {
            DB.shared.getUserInfo(from: $0) {
                self.friendsInfo.append($0)
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func searchFriendButtonPressed(_ sender: UIButton) {
        
    }
    @IBAction func addFriendButtonPressed(_ sender: UIButton) {
        guard let addFriendVC = self.storyboard?.instantiateViewController(withIdentifier: "AddFriendViewController") as? AddFriendViewController else { return }
        addFriendVC.delegate = self
        self.present(addFriendVC, animated: true, completion: nil)
    }
}
extension FriendsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsInfo.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell else { return UITableViewCell() }
        
        let friendInfo = self.friendsInfo[indexPath.row]
        if let friendName = friendInfo["username"] as? String {
            cell.nameLabel.text = friendName
        }
        if let friendImage = friendInfo["image"] as? [Float] {
            cell.friendImage.image = UIColor(red: CGFloat(friendImage[0]), green: CGFloat(friendImage[1]), blue: CGFloat(friendImage[2]), alpha: CGFloat(friendImage[3])).image(cell.friendImage.frame.size)
        }
        return cell
    }
}
extension FriendsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendDetailVC = FriendDetailViewController()
        
        friendDetailVC.friendInfo = self.friendsInfo[indexPath.row]
        friendDetailVC.modalPresentationStyle = .fullScreen
        self.present(friendDetailVC, animated: true, completion: nil)
    }
}

extension FriendsListViewController: FriendAdded {
    func friendAdded() {
        self.initView()
    }
}
