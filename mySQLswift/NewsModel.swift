//
//  Comment.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 5/3/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import Foundation

struct NewsModel {
    var id: String?
    //let user: User
    let imageUrl: String
    let newsTitle: String
    let newsDetail: String
    let storyLabel: String
    let liked: NSNumber
    let creationDate: Date
    
    init(dictionary: [String: Any]) {
        
        //self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.newsTitle = dictionary["newsTitle"] as? String ?? ""
        self.newsDetail = dictionary["newsDetail"] as? String ?? ""
        self.storyLabel = dictionary["storyText"] as? String ?? ""
        self.liked = dictionary["liked"] as? NSNumber ?? 0
        //self.commentCount = dictionary["commentCount"] as? NSNumber ?? 0
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
