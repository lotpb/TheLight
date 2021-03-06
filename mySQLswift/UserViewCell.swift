//
//  UserProfilePhotoCell.swift
//  Firegram
//
//  Created by Nithin Reddy Gaddam on 4/29/17.
//  Copyright © 2017 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
//import Firebase


class UserViewCell: UICollectionViewCell {
    
    var user: UserModel? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            customImageView.loadImage(urlString: profileImageUrl)
            usertitleLabel.text = user?.username
            
            //setupEditFollowButton()
            
        }
    }
    
    let customImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usertitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.textColor = .black
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = Font.celltitle14m
        label.adjustsFontSizeToFitWidth = true
        label.clipsToBounds = true
        return label
    }()
    
    let loadingSpinner: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    func setupViews() {
        addSubview(customImageView)
        addSubview(usertitleLabel)
        addSubview(loadingSpinner)
        
        customImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        customImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        customImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        customImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -13).isActive = true
        customImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        customImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        usertitleLabel.topAnchor.constraint(equalTo: customImageView.bottomAnchor, constant: 0).isActive = true
        usertitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        usertitleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        usertitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        loadingSpinner.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingSpinner.widthAnchor.constraint(equalToConstant: 20).isActive = true
        loadingSpinner.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
}
