//
//  FriendsListViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/01.
//

import UIKit
import FirebaseAuth
import Firebase
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
        
        guard let docID = UserInfoContext.shared.email else { return }
        self.db.collection("User").document(docID).getDocument { document, error in
            if let document = document, document.exists {
                
                UserInfoContext.shared.username = (document.data()!["username"] as! String)
                
                if let friends = document.data()!["friends"] as? [String] {
                    self.friends = friends
                    self.loadFriends()
                }
                
            } else if let error = error {
                print("error occured during get documents: \(error)")
            }
        }
    }
    
    private func loadFriends() {
        self.friends?.forEach {
            let ref = self.db.collection("User").whereField("email", isEqualTo: $0)
            ref.getDocuments { snapshot, error in
                if let error = error {
                    print("Error occured during get friends info. \(error)")
                } else if let document = snapshot?.documents.first {
                    
                    if let username = document.data()["username"] as? String,
                       let email = document.data()["email"] as? String,
                       let image = document.data()["image"] as? [Float] {
                        print(username, email, image)
                        self.friendsInfo.append([
                            "username": username,
                            "email": email,
                            "image": image
                        ])
                        self.tableView.reloadData()
                    }
                }
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
