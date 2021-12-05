//
//  Context.swift
//  VarioTalk
//
//  Created by Seydoux on 2021/12/02.
//

import Foundation

class UserInfoContext {
    static let shared = UserInfoContext()
    
    var username: String!
    var email: String!
    
    private init() {}
}
