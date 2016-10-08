//
//  AccountCell.swift
//  TheLight
//
//  Created by Peter Balsamo on 9/22/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices //kUTTypeImage
//import CoreLocation
//import MessageUI

class AccountCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var image = ["History", "My Videos", "Notifications", "Watch Later"]
    private var items = ["History", "My Videos", "Notifications", "Watch Later"]
    
    private var image1 = ["profile-rabbit-toy", "taylor_swift_profile", "thumbUp", "taylor_swift_profile"]
    private var items1 = ["All Videos", "Favorites", "Liked videos", "My Top Videos"]
    private var itemsDetail1 = ["80 videos", "106 videos", "76 videos", "42 videos"]
    
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var userimageView: UIImageView?
    

    let headerImageView: UIImageView = {
        let image = UIImage(named:"images")!.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .black
        //imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        let defaults = UserDefaults.standard
        let query:PFQuery = PFUser.query()!
        query.whereKey("username", equalTo:defaults.object(forKey: "usernameKey") as! String!)
        query.limit = 1
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                        imageView.image = UIImage(data: imageData!)
                    }
                }
            }
        }
        //imageView.image = UIImage(named: "profile-rabbit-toy")
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let usertitleLabel: UILabel = {
        let defaults = UserDefaults.standard
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = defaults.object(forKey: "usernameKey") as! String!
        label.sizeToFit()
        label.textColor = .white
        return label
    }()
    
    lazy var nameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .white
        let image : UIImage? = UIImage(named:"minimize")!.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
      //button.addTarget(self, action: #selector(replySetButton), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    /*
     lazy var refreshControl: UIRefreshControl = {
     let refreshControl = UIRefreshControl()
     refreshControl.backgroundColor = Color.Lead.navColor
     refreshControl.tintColor = .white
     let attributes = [NSForegroundColorAttributeName: UIColor.white]
     self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
     //refreshControl.addTarget(self, action: #selector(AccountCell.handleRefresh(_:)), for: UIControlEvents.valueChanged)
     return refreshControl
     }()
     
     let lineSeparatorView: UIView = {
     let view = UIView()
     view.backgroundColor = UIColor(white: 0.9, alpha: 1)
     return view
     }()*/
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let floatingButton = UIButton(frame: CGRect(x: frame.size.width - 70, y: 65, width: 50, height: 50))
        floatingButton.backgroundColor = Color.News.navColor
        floatingButton.tintColor = .white
        floatingButton.layer.cornerRadius = floatingButton.frame.size.width / 2
        let floatimage: UIImage? = UIImage(named:"Camcorder")!.withRenderingMode(.alwaysTemplate)
        floatingButton.setImage(floatimage, for: .normal)
        floatingButton.addTarget(self, action: #selector(selectCamera), for: .touchUpInside)
        
        registerCells()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
      //tableView.addSubview(refreshControl)

        addSubview(headerImageView)
        addSubview(userProfileImageView)
        addSubview(usertitleLabel)
        addSubview(nameButton)
        addSubview(tableView)
        addSubview(floatingButton)

        //horizontal constraints
        addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: headerImageView)
        addConstraintsWithFormat(format: "H:|-16-[v0(44)]", views: userProfileImageView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-10-[v1(15)]", views: usertitleLabel, nameButton)
        addConstraintsWithFormat(format: "H:|-0-[v0]-0-|", views: tableView)
        
        //vertical constraints
        addConstraintsWithFormat(format: "V:|-0-[v0(90)]", views: headerImageView)
        addConstraintsWithFormat(format: "V:|-15-[v0(44)]", views: userProfileImageView)
        addConstraintsWithFormat(format: "V:|-60-[v0(30)]-60-[v1(6)]", views: usertitleLabel, nameButton)
        addConstraintsWithFormat(format: "V:|-91-[v0]-0-|", views: tableView)
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: nameButton, attribute: .top, relatedBy: .equal, toItem: userProfileImageView, attribute: .bottom, multiplier: 1, constant: 13))
        //left constraint
        addConstraint(NSLayoutConstraint(item: nameButton, attribute: .left, relatedBy: .equal, toItem: usertitleLabel, attribute: .right, multiplier: 1, constant: 10))

    }
    
    
    fileprivate func registerCells() {
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(AccountViewCell.self, forCellReuseIdentifier: "accountcell")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return self.items.count
        } else if (section == 1) {
            return self.items1.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if ((indexPath).section == 0) {
            let result:CGFloat = 44
            
            return result
        }
        else if ((indexPath).section == 1) {
            let result:CGFloat = 54
            
            return result
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "accountcell", for: indexPath) as! AccountViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.detailLabel.textColor = UIColor(white: 0.5, alpha: 1)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.titleLabel.font =  Font.celllabel1
            cell.detailLabel.font =  Font.News.newslabel2
            
        } else {
            
            cell.titleLabel.font =  Font.celllabel1
            cell.detailLabel.font =  Font.News.newslabel2

        }
        
        if (indexPath.section == 0) {
            
            cell.titleImage.frame = CGRect(x: 28, y: 12, width: 20, height: 20)
            cell.titleLabel.frame = CGRect(x: 75, y: 10, width: tableView.frame.size.width, height: 20.0)
            
            cell.titleImage.image = UIImage.init(named: self.image[indexPath.row])
            cell.titleLabel.text = self.items[indexPath.row]
            
            return cell
        }
        
        if (indexPath.section == 1) {
            
            cell.titleImage.frame = CGRect(x: 15, y: 10, width: 45, height: 45)
            cell.titleLabel.frame = CGRect(x: 75, y: 10, width: tableView.frame.size.width, height: 20.0)
            cell.detailLabel.frame = CGRect(x: 75, y: 30, width: tableView.frame.size.width, height: 20.0)
            
            cell.titleImage.image = UIImage.init(named: self.image1[indexPath.row])
            cell.titleLabel.text = self.items1[indexPath.row]
            cell.detailLabel.text = self.itemsDetail1[indexPath.row]
            
            return cell
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        } else if (section == 1) {
            return 44
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .white
        
        if (section == 1) {
            
            let topBorder = CALayer()
            let width = CGFloat(2.0)
            topBorder.borderColor = UIColor.lightGray.cgColor
            topBorder.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5)
            topBorder.borderWidth = width
            vw.layer.addSublayer(topBorder)
            vw.layer.masksToBounds = true
            
            let myLabel1:UILabel = UILabel(frame: CGRect(x: 16, y: 12, width: 10, height: 20))
            myLabel1.textColor = .black
            myLabel1.text = "Library (A-Z)"
            myLabel1.sizeToFit()
            //myLabel1.font = Font.headtitle
            vw.addSubview(myLabel1)
            
            let sortButton = UIButton(frame: CGRect(x: 120, y: 18, width: 10, height: 7))
            sortButton.tintColor = .black
            let sortimage : UIImage? = UIImage(named:"minimize")!.withRenderingMode(.alwaysTemplate)
            sortButton.setImage(sortimage, for: .normal)
            //sortButton.addTarget(self, action: #selector(replySetButton), for: UIControlEvents.touchUpInside)
            vw.addSubview(sortButton)
            
            return vw
        }
        return vw
    }
    
    // MARK: - Button
    // MARK: Video
    
    func selectCamera(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.showsCameraControls = true
            //self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.userimageView!.image = pickedImage
            
            //dismiss(animated: true, completion: { () -> Void in
            //})
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class AccountViewCell: UITableViewCell {
    
    let titleImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .yellow
        iv.image = UIImage(named: "taylor_swift_blank_space")
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Taylor Swift - Blank Space"
        label.numberOfLines = 2
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Taylor Swift - Blank Space"
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
  
        addSubview(titleImage)
        addSubview(titleLabel)
        addSubview(detailLabel)
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
