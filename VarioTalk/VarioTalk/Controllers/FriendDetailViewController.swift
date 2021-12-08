//
//  FriendDetailViewController.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/03.
//

import UIKit
import SnapKit

class FriendDetailViewController: UIViewController {
    
    lazy var viewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    lazy var informationContainer = UIView()
    lazy var imageView = UIImageView()
    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("", for: .normal)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
       return btn
    }()
    lazy var informationStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = .clear
        view.spacing = 30
        return view
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize + 10)
        
        guard let friendName = friendInfo!["username"] as? String else {
            label.text = ""
            return label
        }
        label.text = friendName
        return label
    }()
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        
        guard let friendEmail = friendInfo!["email"] as? String else {
            label.text = ""
            return label
        }
        label.text = friendEmail
        return label
    }()
    
    lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.backgroundColor = .clear
        view.spacing = 30
        return view
    }()
    
    lazy var chatButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        btn.setTitle("", for: .normal)
        btn.addTarget(self, action: #selector(chatButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    lazy var callButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        btn.setTitle("", for: .normal)
        btn.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    var friendInfo: [String: Any]?
    var imageWidth: Constraint?
    var imageHeight: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initView()
    }
    private func initView() {
        self.view.addSubview(self.viewContainer)
        self.viewContainer.addSubview(self.closeButton)
        self.viewContainer.addSubview(self.informationContainer)
        self.viewContainer.addSubview(self.imageView)
        
        self.informationContainer.addSubview(self.informationStackView)
        self.informationStackView.addArrangedSubview(self.nameLabel)
        self.informationStackView.addArrangedSubview(self.emailLabel)
        self.informationStackView.addArrangedSubview(self.buttonStackView)
        
        self.buttonStackView.addArrangedSubview(self.chatButton)
        self.buttonStackView.addArrangedSubview(self.callButton)
        
        self.viewContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalTo(0)
        }
        
        self.closeButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
        }
        
        self.informationContainer.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.centerY)
            $0.leading.trailing.bottom.equalTo(0)
        }
        
        self.imageView.snp.makeConstraints {
            self.imageWidth = $0.width.equalTo(200).constraint
            self.imageHeight = $0.height.equalTo(200).constraint
            $0.centerX.equalTo(self.view)
            $0.centerY.equalTo(self.view)
        }
        self.setImage()
        
        self.informationStackView.snp.makeConstraints {
            $0.top.equalTo(self.informationContainer).offset(150)
            $0.centerX.equalTo(self.view)
        }
        
        self.callButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        
        self.chatButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
        
    }
    private func setImage() {
        guard let friendImage = friendInfo!["image"] as? [Float] else { return }
        let color = UIColor(red: CGFloat(friendImage[0]), green: CGFloat(friendImage[1]), blue: CGFloat(friendImage[2]), alpha: CGFloat(friendImage[3]))
        imageView.image = color.image(CGSize(width: imageWidth!.layoutConstraints[0].constant, height: imageHeight!.layoutConstraints[0].constant))
        self.informationContainer.backgroundColor = color.withAlphaComponent(0.1)
        
        imageView.layer.cornerRadius = imageWidth!.layoutConstraints[0].constant / 2
        imageView.layer.masksToBounds = true
    }
    @objc func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func chatButtonPressed() {
        // go to chatViewController
        let board = UIStoryboard(name: "Main", bundle: nil)
        let mainScreen = board.instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        
        mainScreen.modalPresentationStyle = .fullScreen
        self.present(mainScreen, animated: false) {
            mainScreen.selectedIndex = 1
            ((mainScreen.selectedViewController as! UINavigationController).topViewController as! ChatListViewController).openChat(with: self.friendInfo!)
        }
    }
    @objc func callButtonPressed() {
        // go to callViewController
    }
}
