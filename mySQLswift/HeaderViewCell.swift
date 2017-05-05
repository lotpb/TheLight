//
//  HeaderViewCell.swift
//  TheLight
//
//  Created by Peter Balsamo on 5/3/17.
//  Copyright © 2017 Peter Balsamo. All rights reserved.
//

import UIKit

class HeaderViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    let header: UIView = {
        let view = UIView()
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 90)
        view.backgroundColor = Color.Lead.navColor
        return view
    }()
    
    let myLabel1: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = CGRect.init(x: 10, y: 15, width: 50, height: 50)
        label.text = ""
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 25.0
        label.layer.borderColor = Color.Blog.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let myLabel2: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = CGRect.init(x: 80, y: 15, width: 50, height: 50)
        label.text = ""
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 25.0
        label.layer.borderColor = Color.Blog.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let myLabel3: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = CGRect.init(x: 150, y: 15, width: 50, height: 50)
        label.text = ""
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = Color.goldColor
        label.textAlignment = .center
        label.font = Font.celltitle14m
        label.layer.cornerRadius = 25.0
        label.layer.borderColor = Color.Blog.borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let separatorView1: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 10, y: 75, width: 50, height: 2.5)
        return view
    }()
    
    let separatorView2: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 80, y: 75, width: 50, height: 2.5)
        return view
    }()
    
    let separatorView3: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 150, y: 75, width: 50, height: 2.5)
        return view
    }()
    
    func setupViews() {
        
        addSubview(header)
        header.addSubview(myLabel1)
        header.addSubview(myLabel2)
        header.addSubview(myLabel3)
        header.addSubview(separatorView1)
        header.addSubview(separatorView2)
        header.addSubview(separatorView3)
    }
}
