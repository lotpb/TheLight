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
        let query = PFQuery(className:"Newsios")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "newsTitle")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.collectionView.reloadData()
            } else {
                print("Error")
            }
        }
    }

}
