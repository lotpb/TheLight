//
//  SubscriptionCell.swift
//  youtube
//
//  Created by Brian Voong on 7/9/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse

class SubscriptionCell: FeedCell {
    
    override func fetchVideos() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            let query = PFQuery(className:"Newsios")
            query.limit = 1000
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "newsTitle")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.collectionView.reloadData()
                } else {
                    print("ErrorSub")
                }
            }
        } else {
            //firebase
        }
    }
    
}
