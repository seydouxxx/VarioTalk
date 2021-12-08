//
//  Context.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/02.
//

import Foundation
import FirebaseDatabase
import Firebase
import UIKit

class UserInfoContext {
    static let shared = UserInfoContext()
    
    var username: String!
    var email: String!
    
    private init() {}
}

class Constants {
    static let shared = Constants()
    
    
    var dbUrl: String = "https://variotalk-5c614-default-rtdb.asia-southeast1.firebasedatabase.app/"
    var chatBackgroundColor: UIColor = .blue.withAlphaComponent(0.1)
    
    private init() {}
}
