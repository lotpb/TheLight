//
//  Parse.swift
//  TheLight
//
//  Created by Peter Balsamo on 4/16/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse


extension UIViewController {
    /*
    func deleteBlog(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            let query = PFQuery(className:"Blog")
            query.whereKey("objectId", equalTo: name)
            query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground()
                        self.navigationController?.popViewController(animated: true)
                        //if (self.commentNum! > 0) {
                        self.deincrementComment()
                        //}
                    }
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            return
        }
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    } */
    
}
