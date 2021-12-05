//
//  ViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/01.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.observeForm()
        
        // TODO: Code for testing
        self.mailField.text = "admin@variotalk.com"
        self.pwField.text = "admin123"
    }
    
    private func initView() {
        self.signInButton.isEnabled = false
        self.signInButton.backgroundColor = .lightGray
        self.signInButton.layer.cornerRadius = 10
        self.signInButton.layer.masksToBounds = true
        
        self.mailField.delegate = self
        self.pwField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapViewToHideKeyboard)))
    }
    
    private func observeForm() {
        let mailValid = self.mailField.rx.text.orEmpty.map(mailValidation)
        let pwValid = self.pwField.rx.text.orEmpty.map(pwValidation)
        
        Observable.combineLatest(mailValid, pwValid, resultSelector: { $0 && $1 })
            .subscribe(onNext: { v in
                self.signInButton.isEnabled = v
            }).disposed(by: disposeBag)
    }
    
    private func mailValidation(_ mail: String) -> Bool {
        return mail.contains("@") && mail.contains(".")
    }
    private func pwValidation(_ password: String) -> Bool {
        return password.count > 7
    }

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        guard let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return }
        self.present(signUpVC, animated: true, completion: nil)
    }
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        guard let email = self.mailField.text,
              let password = self.pwField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                guard let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LoginSuccess") as? UITabBarController else { return }

                UserInfoContext.shared.email = result.user.email!
                
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: true, completion: nil)
                
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            
        }
    }
    
}
extension LoginViewController: UITextFieldDelegate {
    @objc func keyboardShow(_ notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            }
        }
    }
    @objc func keyboardHide() {
        self.view.transform = .identity
    }
    @objc func tapViewToHideKeyboard() {
        self.view.endEditing(true)
    }
}
