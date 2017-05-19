//
//  CustomTableCell.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 10/12/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Firebase

class CustomTableCell: UITableViewCell {
    //firebase
    var post: BlogModel? {
        didSet {
            
            setupNameAndProfileImage()
            
            /*
            self.checkUserNameAlreadyExist(newUserName: "Peter Balsamo") { isExist in
                if isExist {
                    print("Username exist")
                }
                else {
                    print("create new user")
                }
            } */

            //guard let postImageUrl = post?.profileImageUrl else {return}
            //customImageView.loadImage(urlString: postImageUrl)
            customImageView.image = #imageLiteral(resourceName: "profile-rabbit-toy")
            
            //usernameLabel.text = post?.user.username
            //print(post?.user.username)
            //guard let profileImageUrl = profileImageUrl else {return}
            //customImageView.loadImage(urlString: profileImageUrl)
            
            blogtitleLabel.text = post?.postBy
            blogsubtitleLabel.text = post?.subject
            blogmsgDateLabel.text = post?.creationDate.timeAgoDisplay()
            
            var Liked:Int? = post?.liked as? Int
            if Liked == nil { Liked = 0 }
            numLabel?.text = "\(Liked!)"
            
            var CommentCount:Int? = post?.commentCount as? Int
            if CommentCount == nil { CommentCount = 0 }
            commentLabel?.text = "\(CommentCount!)"

            //setupAttributedCaption()
        }
    }
    
    func checkUserNameAlreadyExist(newUserName: String, completion: @escaping(Bool) -> Void) {
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrdered(byChild: "profileImageUrl").queryEqual(toValue: newUserName)
            .observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
                
                if snapshot.exists() {
                    completion(true)
                }
                else {
                    completion(false)
                }
            })
    }
    
    private func setupNameAndProfileImage() {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let user = UserModel(uid: username, dictionary: value as! [String : Any])
            print("Crap", user)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

        
        /*
        if let id = user?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    //self.textLabel?.text = dictionary["username"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImage(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        } */
    }
    
    let customImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.frame = CGRect(x: 15, y: 11, width: 50, height: 50)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = (imageView.frame.size.width) / 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.masksToBounds = true
        return imageView
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        
        addSubview(customImageView)
    }



    // Snapshot Controller
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var snaptitleLabel: UILabel!
    @IBOutlet weak var snapdetailLabel: UILabel!
    
    // Ad Controller
    @IBOutlet weak var adtitleLabel: UILabel!
    
    // Product Controller
    @IBOutlet weak var prodtitleLabel: UILabel!
    
    // Job Controller
    @IBOutlet weak var jobtitleLabel: UILabel!
    
    // salesman Controller
    @IBOutlet weak var salestitleLabel: UILabel!
    
    // BUser Controller
    @IBOutlet weak var usertitleLabel: UILabel!
    @IBOutlet weak var usersubtitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // Lead Controller
    @IBOutlet weak var leadtitleLabel: UILabel!
    @IBOutlet weak var leadsubtitleLabel: UILabel!
    @IBOutlet weak var leadImageView: UIImageView!
    @IBOutlet weak var leadreplyButton: UIButton!
    @IBOutlet weak var leadlikeButton: UIButton!
    @IBOutlet weak var leadreplyLabel: UILabel!
    @IBOutlet weak var leadlikeLabel: UILabel!
    
    // LeadDetailController
    @IBOutlet weak var leadtitleDetail: UILabel!
    @IBOutlet weak var leadsubtitleDetail: UILabel!
    @IBOutlet weak var leadreadDetail: UILabel!
    @IBOutlet weak var leadnewsDetail: UILabel!
    
    // Customer Controller
    @IBOutlet weak var custtitleLabel: UILabel!
    @IBOutlet weak var custsubtitleLabel: UILabel!
    @IBOutlet weak var custImageView: UIImageView!
    @IBOutlet weak var custreplyButton: UIButton!
    @IBOutlet weak var custlikeButton: UIButton!
    @IBOutlet weak var custreplyLabel: UILabel!
    @IBOutlet weak var custlikeLabel: UILabel!
    
    // Vendor Controller
    @IBOutlet weak var vendtitleLabel: UILabel!
    @IBOutlet weak var vendsubtitleLabel: UILabel!
    @IBOutlet weak var vendImageView: UIImageView!
    @IBOutlet weak var vendreplyButton: UIButton!
    @IBOutlet weak var vendlikeButton: UIButton!
    @IBOutlet weak var vendreplyLabel: UILabel!
    @IBOutlet weak var vendlikeLabel: UILabel!
    
    // Employee Controller
    @IBOutlet weak var employtitleLabel: UILabel!
    @IBOutlet weak var employsubtitleLabel: UILabel!
    @IBOutlet weak var employImageView: UIImageView!
    @IBOutlet weak var employreplyButton: UIButton!
    @IBOutlet weak var employlikeButton: UIButton!
    @IBOutlet weak var employreplyLabel: UILabel!
    @IBOutlet weak var employlikeLabel: UILabel!

    // BlogEditView
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var msgDateLabel: UILabel!
    @IBOutlet weak var blogImageView: UIImageView!
    
    // BlogController
    @IBOutlet weak var blogtitleLabel: UILabel!
    @IBOutlet weak var blogsubtitleLabel: UILabel!
    @IBOutlet weak var blogmsgDateLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    
}

