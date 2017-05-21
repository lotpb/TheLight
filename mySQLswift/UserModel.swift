//
//  User.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import Foundation
import Firebase

struct UserModel {
    let uid: String
    let username: String
    let profileImageUrl: String
    let phone: String
    //var facebookID: String
    //let emailVerified: String
    //let currentLocation: String
    
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        //self.facebookID = facebookID
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
