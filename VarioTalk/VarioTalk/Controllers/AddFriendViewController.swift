//
//  AddFriendViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/02.
//

import UIKit
import Firebase

protocol FriendAdded: AnyObject {
    func friendAdded()
}

class AddFriendViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var myEmailLabel: UILabel!
    @IBOutlet weak var resultView: UIStackView!
    @IBOutlet weak var resultImageContainer: UIView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultNameLabel: UILabel!
    @IBOutlet weak var resultEmailLabel: UILabel!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dummyButton: UIButton!
    
    let db = Firestore.firestore()
    var delegate: FriendAdded?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }
    
    private func initView() {
        
        self.noResultLabel.isHidden = true
        self.resultView.isHidden = true
        self.resultView.backgroundColor = .systemGray6
        self.resultImageContainer.backgroundColor = .systemGray6
        self.resultView.layer.cornerRadius = 10
        self.resultView.layer.masksToBounds = true
        
        self.textField.text = ""
        self.closeButton.setTitle("", for: .normal)
        self.dummyButton.setTitle("", for: .normal)
        
        self.textField.borderStyle = .none
        self.textField.addTarget(self, action: #selector(submitTextField(_:)), for: .editingDidEndOnExit)
        
        self.myEmailLabel.text = UserInfoContext.shared.email
        
    }
    
    private func resetView() {
        UIView.animate(withDuration: 0.2) {
            self.initView()
        }
    }
    
    @objc func submitTextField(_ sender: UITextField) {
        guard let query = sender.text else { return }
        
        let ref = self.db.collection("User").document(query)
        ref.getDocument { document, error in
            if let error = error {
                print("Error occured during searching user. \(error)")
                self.noResultLabel.isHidden = false
                self.resultView.isHidden = true
            } else if let document = document {
                guard let data = document.data(),
                      let targetEmail = (data["email"] as? String),
                      let targetUsername = (data["username"] as? String),
                      let targetImage = (data["image"] as? [Float]) else {
                          self.noResultLabel.isHidden = false
                          self.resultView.isHidden = true
                          return
                      }
                let size = self.resultImageView.frame.size
                self.resultNameLabel.text = targetUsername
                self.resultEmailLabel.text = targetEmail
                self.resultImageView.image = UIColor(red: CGFloat(targetImage[0]), green: CGFloat(targetImage[1]), blue: CGFloat(targetImage[2]), alpha:CGFloat(targetImage[3])).image(size)
                self.resultImageView.layer.cornerRadius = 20
                self.resultImageView.layer.masksToBounds = true
                self.noResultLabel.isHidden = true
                self.addFriendButton.isHidden = false
                self.resultView.isHidden = false
                
                if UserInfoContext.shared.email == query {
                    self.addFriendButton.isHidden = true
                }
            }
        }
    }
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addFriendButtonPressed(_ sender: UIButton) {
        guard let targetEmail = self.resultEmailLabel.text else { return }
        let ref = self.db.collection("User").whereField("email", isEqualTo: UserInfoContext.shared.email!)
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("error occured during adding friend. \(error)")
            } else {
                let document = snapshot?.documents.first
                
                if var friends = document?.data()["friends"] as? [String] {
                    
                    if !friends.contains(targetEmail) {
                        friends.append(targetEmail)
                        document?.reference.updateData([
                            "friends": friends
                        ])
                    }
//                    let checker = friends.allSatisfy {
//                        $0["email"] as! String != self.resultEmailLabel.text!
//                    }
//                    if checker {
//                        friends.append([
//                            "username": self.resultNameLabel.text!,
//                            "email": self.resultEmailLabel.text!,
//                            "image": self.targetRGB ?? [0, 0, 0, 0]
//                        ])
//                        document?.reference.updateData([
//                            "friends": friends
//                        ])
//                    }
                }
                self.resetView()
                self.delegate?.friendAdded()
            }
        }
    }
}
