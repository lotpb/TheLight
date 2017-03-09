//
//  CustomTableCell.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 10/12/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//


import UIKit


class CustomTableCell: UITableViewCell {
    
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
    
    @IBOutlet weak var replytitleLabel: UILabel!
    @IBOutlet weak var replysubtitleLabel: UILabel!
    @IBOutlet weak var replynumLabel: UILabel!
    @IBOutlet weak var replydateLabel: UILabel!
    @IBOutlet weak var replylikeButton: UIButton!
    @IBOutlet weak var replyImageView: UIImageView!
    
    /*
     lazy var replylikeButton: UIButton = {
     let button = UIButton()
     button.tintColor = .lightGray
     button.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
     button.isHidden = false
     button.addTarget(self, action: #selector(BlogEditController.likeButton), for: .touchUpInside)
     return button
     }() */
    
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
    @IBOutlet weak var blog2ImageView: UIImageView!
    

}
/*
class LeadCell: CustomTableCell {
    
    let myLabel1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Color.Lead.labelColor1
        //label.text = ""
        label.textColor = .white
        label.font = Font.celltitle14m
        label.layer.masksToBounds = true
        return label
    }()
    
    let myLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        //label.text = ""
        label.textColor = .black
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.masksToBounds = true
        return label
    }()
    
    func setupViews() {
        addSubview(myLabel1)
        addSubview(myLabel2)
        
        myLabel1.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        myLabel1.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 20).isActive = true
        myLabel1.widthAnchor.constraint(equalToConstant: 95).isActive = true
        myLabel1.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        myLabel2.topAnchor.constraint(equalTo: self.topAnchor, constant: 33).isActive = true
        myLabel2.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 20).isActive = true
        myLabel2.widthAnchor.constraint(equalToConstant: 95).isActive = true
        myLabel2.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
}
*/
