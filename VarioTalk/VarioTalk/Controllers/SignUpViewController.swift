//
//  SignUpViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/01.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var pwConfirmField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    let db = Firestore.firestore()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.formValid()
    }
    private func initView() {
        self.confirmButton.isEnabled = false
    }
    private func formValid() {
        let mailValid = self.emailField.rx.text.orEmpty.map({ $0.contains("@") && $0.contains(".") })
        let pwValid = self.pwField.rx.text.orEmpty.map({ $0.count > 7 })
        let usernameValid = self.usernameField.rx.text.orEmpty.map({ $0.count > 3 })
        
        
        Observable.combineLatest(mailValid, pwValid, usernameValid, resultSelector: { $0 && $1 && $2 })
            .subscribe(onNext: { v in
                self.confirmButton.isEnabled = v
            }).disposed(by: disposeBag)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        guard self.pwField.text! == self.pwConfirmField.text! else { return }
        
        guard let email = emailField.text,
              let password = pwField.text,
              let username = usernameField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let result = result {
                print("result signup: \(result)")
                
                // Add a new document with a generated ID
//                var ref: DocumentReference? = nil
                self.db.collection("User").document(email).setData([
                    "username": username,
                    "email": email,
                    "image": [Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1],
                    "friends": [],
                    "chats": []
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID")
                    }
                }
//                ref = self.db.collection("User").addDocument(data: [
//                    "username": username,
//                    "email": email,
//                    "friends": []
//                ]) { err in
//                    if let err = err {
//                        print("Error adding document: \(err)")
//                    } else {
//                        print("Document added with ID: \(ref!.documentID)")
//                    }
//                }
                
                self.dismiss(animated: true, completion: nil)
            }
            if let error = error {
                print("error occured during signUp: \(error)")
            }
        }
    }
}
