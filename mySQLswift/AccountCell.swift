//
//  AccountCell.swift
//  TheLight
//
//  Created by Peter Balsamo on 9/22/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
//import Parse

class AccountCell: UICollectionViewCell {
    
    let headerImageView: UIImageView = {
        let image = UIImage(named: "")
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = UIImage(named: "profile-rabbit-toy")
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let usertitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Peter Balsamo"
        label.textColor = .white
        //label.numberOfLines = 2
        return label
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        //tableView.delegate = self
        //tableView.dataSource = self
        return tableView
    }()
    
    /*
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }() */
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(headerImageView)
        addSubview(userProfileImageView)
        addSubview(usertitleLabel)
        addSubview(lineSeparatorView)
        addSubview(tableView)

        //horizontal constraints
        addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: headerImageView)
        addConstraintsWithFormat(format: "H:|-16-[v0(44)]", views: userProfileImageView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: usertitleLabel)
        addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: tableView)
        
        //vertical constraints
        addConstraintsWithFormat(format: "V:|-0-[v0(90)]", views: headerImageView)
        addConstraintsWithFormat(format: "V:|-15-[v0(44)]", views: userProfileImageView)
        addConstraintsWithFormat(format: "V:|-60-[v0(30)]", views: usertitleLabel)
 
        //lineSeparatorView.anchorToTop(nil, left: leftAnchor, bottom: headerImageView.topAnchor, right: rightAnchor)
        //lineSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = "Peter Balsamo"
        //cell.detailTextLabel?.text =
        
        return cell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
