//
//  TitleBar.swift
//  TheLight
//
//  Created by Peter Balsamo on 7/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit

class TitleBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.rgb(red: 230, green: 32, blue: 31)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"
    let imageNames = ["home", "trending", "subscriptions", "account"]
    
    var homeController: SalesmanController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(TitleCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        
        setupHorizontalBar()
    }
    
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
    
    func setupHorizontalBar() {
        
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalBarView)
        
        //new school way of laying out our views
        //in ios9
        //need x, y, width, height constraints
        
        horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftAnchorConstraint?.isActive = true
        
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/4).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        homeController?.scrollToMenuIndex(menuIndex: (indexPath as NSIndexPath).item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TitleCell
        
        cell.imageView1.image = UIImage(named: imageNames[(indexPath as NSIndexPath).item])?.withRenderingMode(.alwaysTemplate)
        cell.tintColor = UIColor.rgb(red: 91, green: 14, blue: 13)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TitleCell: CollectionViewCell {
    /*
    let myLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white()
        label.textColor = UIColor.black()
        label.textAlignment = NSTextAlignment.center
        label.layer.masksToBounds = true
        //label.text = String(format: "%@%d", "Leads\n", _feedItems.count)
        label.font = Font.headtitle
        label.layer.cornerRadius = 25.0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let myLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white()
        label.textColor = UIColor.black()
        label.textAlignment = NSTextAlignment.center
        label.layer.masksToBounds = true
        //label.text = String(format: "%@%d", "Leads\n", _feedItems.count)
        label.font = Font.headtitle
        label.layer.cornerRadius = 25.0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let myLabel3: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white()
        label.textColor = UIColor.black()
        label.textAlignment = NSTextAlignment.center
        label.layer.masksToBounds = true
        //label.text = String(format: "%@%d", "Leads\n", _feedItems.count)
        label.font = Font.headtitle
        label.layer.cornerRadius = 25.0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    
    let separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    
    let separatorView3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    */
    
    let imageView1: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.rgb(red: 91, green: 14, blue: 13)
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            imageView1.tintColor = isHighlighted ? UIColor.white : UIColor.rgb(red: 91, green: 14, blue: 13)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView1.tintColor = isSelected ? UIColor.white : UIColor.rgb(red: 91, green: 14, blue: 13)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView1)
        addConstraintsWithFormat(format: "H:[v0(28)]", views: imageView1)
        addConstraintsWithFormat(format: "V:[v0(28)]", views: imageView1)
        
        addConstraint(NSLayoutConstraint(item: imageView1, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView1, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}
