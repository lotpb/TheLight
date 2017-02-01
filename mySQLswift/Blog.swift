//
//  Blog.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Firebase
import Parse
import Social

class Blog: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let searchScope = ["subject", "date", "rating", "postby"]
    
    @IBOutlet weak var tableView: UITableView?

    var _feedItems : NSMutableArray = NSMutableArray()
    var _feedheadItems2 : NSMutableArray = NSMutableArray()
    var _feedheadItems3 : NSMutableArray = NSMutableArray()
    var filteredString : NSMutableArray = NSMutableArray()
    
    var buttonView: UIView?
    var likeButton: UIButton?
    var isReplyClicked = true
    var posttoIndex: String?
    var userIndex: String?
    var titleLabel = String()
    var defaults = UserDefaults.standard
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers = [String]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.twitterText
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(Blog.refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: NavigationController Hidden
    var lastContentOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(Blog.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        parseData()
        setupTableView()
        self.tableView!.addSubview(self.refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarItems()
        setupTwitterNavigationBarItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshData(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 110
        //self.tableView!.sectionHeaderHeight = UITableViewAutomaticDimension;
        //self.tableView!.estimatedSectionHeaderHeight = 90
        self.tableView!.sectionFooterHeight = UITableViewAutomaticDimension;
        self.tableView!.estimatedSectionFooterHeight = 0
        self.tableView!.backgroundColor =  UIColor(white:0.90, alpha:1.0)
        //self.tableView?.contentInset = UIEdgeInsetsMake(-90,0,0,0)
        //self.tableView?.scrollIndicatorInsets = UIEdgeInsetsMake(-90,0,0,0)
        self.automaticallyAdjustsScrollViewInsets = false //fix headerview

        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    /*
    func setupNavBarButtons() {
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(Blog.newButton))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(Blog.searchButton))
        navigationItem.rightBarButtonItems = [addButton,searchButton]
    } */
    
    // MARK: - NavigationController Hidden
    
    func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
    }
    
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject) {
        parseData()
        //self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return _feedItems.count
        } else {
            return filteredString.count
        }
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableCell else { fatalError("Unexpected Index Path") }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.blogsubtitleLabel?.textColor = Color.twitterText
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.blogtitleLabel!.font =  Font.Blog.celltitlePad
            cell.blogsubtitleLabel!.font =  Font.Blog.cellsubtitlePad
            cell.blogmsgDateLabel.font = Font.Blog.celldatePad
            cell.numLabel.font = Font.Blog.cellLabel
            cell.commentLabel.font = Font.Blog.cellLabel
            
        } else {
            
            cell.blogtitleLabel!.font =  Font.Blog.celltitle
            cell.blogsubtitleLabel!.font =  Font.celltitle18r
            cell.blogmsgDateLabel.font = Font.Blog.celldate
            cell.numLabel.font = Font.Blog.cellLabel
            cell.commentLabel.font = Font.Blog.cellLabel
        }
        
        let query:PFQuery = PFUser.query()!
        query.whereKey("username",  equalTo:(self._feedItems[indexPath.row] as AnyObject).value(forKey:"PostBy") as! String)
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                        
                        UIView.transition(with: (cell.blogImageView)!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            cell.blogImageView?.image = UIImage(data: imageData! as Data)
                            }, completion: nil)
                    }
                }
            }
        } 
        
        cell.blogImageView?.layer.cornerRadius = (cell.blogImageView?.frame.size.width)! / 2
        cell.blogImageView?.layer.borderColor = UIColor.lightGray.cgColor
        cell.blogImageView?.layer.borderWidth = 0.5
        cell.blogImageView?.layer.masksToBounds = true
        cell.blogImageView?.isUserInteractionEnabled = true
        cell.blogImageView?.contentMode = .scaleAspectFill
        cell.blogImageView?.tag = indexPath.row
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(imgLoadSegue))
        cell.blogImageView.addGestureRecognizer(tap)
        
        let dateStr = (_feedItems[indexPath.row] as AnyObject).value(forKey: "MsgDate") as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date:NSDate = dateFormatter.date(from: dateStr!)as NSDate!
        
        dateFormatter.dateFormat = "h:mm a"
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
        let secondInDays: TimeInterval = 60 * 60 * 24
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MMM-dd"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        }

        if (tableView == self.tableView) {
            
            cell.blogtitleLabel?.text = (_feedItems[indexPath.row] as AnyObject).value(forKey:"PostBy") as? String
            cell.blogsubtitleLabel?.text = (_feedItems[indexPath.row] as AnyObject).value(forKey:"Subject") as? String
            cell.blogmsgDateLabel?.text = dateFormatter.string(from: date as Date)as String!
            
            var Liked:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey:"Liked")as? Int
            if Liked == nil {
                Liked = 0
            }
            cell.numLabel?.text = "\(Liked!)"
            
            var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey:"CommentCount") as? Int
            if CommentCount == nil {
                CommentCount = 0
            }
            cell.commentLabel?.text = "\(CommentCount!)"
            
        } else {
            
            cell.blogtitleLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"PostBy") as? String
            cell.blogsubtitleLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"Subject") as? String
            cell.blogmsgDateLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"MsgDate") as? String
            cell.numLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"Liked") as? String
            cell.commentLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"CommentCount") as? String
        }
        
        cell.replyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.replyButton .setImage(replyimage, for: .normal)
        cell.replyButton .addTarget(self, action: #selector(replySetButton), for: .touchUpInside)
        
        cell.likeButton.tintColor = .lightGray
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(likeimage, for: .normal)
        cell.likeButton.addTarget(self, action: #selector(likeSetButton), for: .touchUpInside)

        cell.flagButton.tintColor = .lightGray
        let reportimage : UIImage? = UIImage(named:"Flag.png")!.withRenderingMode(.alwaysTemplate)
        cell.flagButton .setImage(reportimage, for: .normal)
        cell.flagButton .addTarget(self, action: #selector(flagSetButton), for: .touchUpInside)
  
        cell.actionBtn.tintColor = .lightGray
        let actionimage : UIImage? = UIImage(named:"nav_more_icon.png")!.withRenderingMode(.alwaysTemplate)
        cell.actionBtn .setImage(actionimage, for: .normal)
        cell.actionBtn .addTarget(self, action: #selector(showShare), for: .touchUpInside)
        
        if !(cell.numLabel.text! == "0") {
            cell.numLabel.textColor = Color.Blog.buttonColor
        } else {
            cell.numLabel.text! = ""
        }
        
        if !(cell.commentLabel.text! == "0") {
            cell.commentLabel.textColor = .lightGray
        } else {
            cell.commentLabel.text! = ""
        }
        
        if (cell.commentLabel.text! == "") {
            cell.replyButton.tintColor = .lightGray
        } else {
            cell.replyButton.tintColor = Color.Blog.buttonColor
        }
        
//---------------------NSDataDetector-----------------------------
        
        let input = (cell.blogsubtitleLabel.text!) as String
        let types: NSTextCheckingResult.CheckingType = [.date, .address, .phoneNumber, .link]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        for match in matches {

            let text = (cell.blogsubtitleLabel.text!) as NSString
            let url = input.substring(with: match.range.range(for: text as String)!)
            let attributedText = NSMutableAttributedString(string: text as String)

            let boldRange = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24)]
            let highlightedRange = [NSBackgroundColorAttributeName: Color.Blog.phonelinkText]
            let underlinedRange = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            let tintedRange1 = [NSForegroundColorAttributeName: Color.Blog.weblinkText]
            
            attributedText.addAttributes(boldRange, range: text.range(of: "VCSY", options: .caseInsensitive))
            attributedText.addAttributes(highlightedRange, range: text.range(of: "(516)241-4786"))
            attributedText.addAttributes(underlinedRange, range: text.range(of: "Lost", options: .caseInsensitive))
            attributedText.addAttributes(tintedRange1, range: text.range(of: url))
            
            /*
             // Append a space with matching font of the rest of the body text.
             let appendedSpace = NSMutableAttributedString.init(string: " ")
             appendedSpace.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, 1))
             attributedText.append(appendedSpace) */
            
            // Add tint.
            //let tintedRange = text.range(of: NSLocalizedString("eunited@verizon.com", comment: ""))
            //attributedText.addAttribute(NSForegroundColorAttributeName, value: Color.Blog.emaillinkText, range: tintedRange)
            //let tintedRange1 = text.range(of: NSLocalizedString("http://www.eunited.com", comment: ""))
            
            // create our NSTextAttachment
            //let image1Attachment = NSTextAttachment()
            //image1Attachment.image = UIImage(named: "DeleteGeotification.png")

            //let image1String = NSAttributedString(attachment: image1Attachment)
            //attributedText.append(image1String)
            //attributedText.append(NSAttributedString(string: " End of text"))
            
            cell.blogsubtitleLabel!.attributedText = attributedText
        }
        
        //--------------------------------------------------
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                return 90.0
            } else {
                return 0.0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let vw = UIView()
            vw.backgroundColor = Color.Blog.navColor
            //tableView.tableHeaderView = vw
            
            let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
            myLabel1.numberOfLines = 0
            myLabel1.backgroundColor = .white
            myLabel1.textColor = Color.twitterBlue
            myLabel1.textAlignment = .center
            myLabel1.layer.masksToBounds = true
            myLabel1.text = String(format: "%@%d", "Blog\n", _feedItems.count)
            myLabel1.font = Font.celltitle14m
            myLabel1.layer.cornerRadius = 25.0
            myLabel1.layer.borderColor = Color.Blog.borderbtnColor
            myLabel1.layer.borderWidth = 2
            myLabel1.isUserInteractionEnabled = true
            vw.addSubview(myLabel1)
            
            let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
            separatorLineView1.backgroundColor = Color.Blog.borderColor
            vw.addSubview(separatorLineView1)
            
            let myLabel2:UILabel = UILabel(frame: CGRect(x: 80, y: 15, width: 50, height: 50))
            myLabel2.numberOfLines = 0
            myLabel2.backgroundColor = .white
            myLabel2.textColor = Color.twitterBlue
            myLabel2.textAlignment = .center
            myLabel2.layer.masksToBounds = true
            myLabel2.text = String(format: "%@%d", "Likes\n", _feedheadItems2.count)
            myLabel2.font = Font.celltitle14m
            myLabel2.layer.cornerRadius = 25.0
            myLabel2.layer.borderColor = Color.Blog.borderbtnColor
            myLabel2.layer.borderWidth = 2
            myLabel2.isUserInteractionEnabled = true
            vw.addSubview(myLabel2)
            
            let separatorLineView2 = UIView(frame: CGRect(x: 80, y: 75, width: 50, height: 2.5))
            separatorLineView2.backgroundColor = Color.Blog.borderColor
            vw.addSubview(separatorLineView2)
            
            let myLabel3:UILabel = UILabel(frame: CGRect(x: 150, y: 15, width: 50, height: 50))
            myLabel3.numberOfLines = 0
            myLabel3.backgroundColor = .white
            myLabel3.textColor = Color.twitterBlue
            myLabel3.textAlignment = .center
            myLabel3.layer.masksToBounds = true
            myLabel3.text = String(format: "%@%d", "Users\n", _feedheadItems3.count)
            myLabel3.font = Font.celltitle14m
            myLabel3.layer.cornerRadius = 25.0
            myLabel3.layer.borderColor = Color.Blog.borderbtnColor
            myLabel3.layer.borderWidth = 2
            myLabel3.isUserInteractionEnabled = true
            vw.addSubview(myLabel3)
            
            let separatorLineView3 = UIView(frame: CGRect(x: 150, y: 75, width: 50, height: 2.5))
            separatorLineView3.backgroundColor = Color.Blog.borderColor
            vw.addSubview(separatorLineView3)

            return vw
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let query = PFQuery(className:"Blog")
            query.whereKey("objectId", equalTo:((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!)
            
            let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
            
            let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
                query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) -> Void in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                            self.refreshData(self)
                        }
                    }
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.refreshData(self)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(destroyAction)
            self.present(alertController, animated: true) {
            }
            
            _feedItems.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Button
    
    func newButton(sender: AnyObject) {
        
        isReplyClicked = false
        self.performSegue(withIdentifier: "blognewSegue", sender: self)
    }
    
    func likeSetButton(sender:UIButton) {

        likeButton?.isSelected = true
        sender.tintColor = Color.twitterBlue
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        let query = PFQuery(className:"Blog")
        query.whereKey("objectId", equalTo:((_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                object!.incrementKey("Liked")
                object!.saveInBackground()
            }
        }
    }
    
    func replySetButton(sender:UIButton) {
 
        isReplyClicked = true
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        posttoIndex = (_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "PostBy") as? String
        userIndex = (_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String
        self.performSegue(withIdentifier: "blognewSegue", sender: self)
    }
    
    func flagSetButton(_ sender:UIButton) {
    }
    
    // MARK: - NavigationController Hidden
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }

    
    
    // MARK: - Firebase
    /*
//-----------------------------------------
    func observeUser() {
        let ref = FIRDatabase.database().reference().child("Users")
        ref.observe(.childAdded, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                print(self.users)
                
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                DispatchQueue.main.async(execute: {
                    self.tableView!.reloadData()
                })
            }
            
            }, withCancel: nil)
    }
    
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("Blog")
        ref.observe(.childAdded, with: { (snapshot) in
            //print(snapshot.value)
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                if let toId = message.objectId {
                    self.messagesDictionary[toId] = message
                    
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(isOrderedBefore: { (message1, message2) -> Bool in
                        
                        return message1.MsgDate > message2.MsgDate
                    })
                }
                
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                DispatchQueue.main.async(execute: {
                    self.tableView!.reloadData()
                })
            }
            
            }, withCancel: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Crap")
            //performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeys(dictionary)
                //self.setupNavBarWithUser(user)
            }
            
            }, withCancel: nil)
    } */
 
//-----------------------------------------
    
    // MARK: - Parse

    func parseData() {
        
        let query = PFQuery(className:"Blog")
        query.limit = 1000
        query.whereKey("ReplyId", equalTo:NSNull())
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp : NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView?.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Blog")
        query1.limit = 1000
        //query1.whereKey("Rating", equalTo:"5")
        query1.whereKey("Liked", notEqualTo:NSNull())
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        query1.order(byDescending: "createdAt")
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems2 = temp.mutableCopy() as! NSMutableArray
                self.tableView?.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query3 = PFUser.query()
        query3?.limit = 1000
        query3?.cachePolicy = PFCachePolicy.cacheThenNetwork
        query3?.order(byDescending: "createdAt")
        query3?.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems3 = temp.mutableCopy() as! NSMutableArray
                self.tableView?.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    // MARK: - AlertController
    
    func showShare(sender:UIButton) {
        
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        let socialText = (self._feedItems[indexPath!.row] as AnyObject).value(forKey: "Subject") as? String
        
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) -> Void in
                
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                    let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    
                    if socialText!.characters.count <= 140 {
                        twitterComposeVC?.setInitialText(socialText)
                    } else {
                        let index = socialText!.characters.index(socialText!.startIndex, offsetBy: 140)
                        let subText = socialText!.substring(to: index)
                        twitterComposeVC?.setInitialText("\(subText)")
                    }
                    
                    self.present(twitterComposeVC!, animated: true, completion: nil)
                } else {
                    self.showAlertMessage(message: "You are not logged in to your Twitter account.")
                }
            }
            
            let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) -> Void in
                
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                    let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    //facebookComposeVC.setInitialText(socialText)
                    //facebookComposeVC.addImage(detailImageView.image!)
                    facebookComposeVC?.add(URL(string: "http://lotpb.github.io/UnitedWebPage/index.html"))
                    self.present(facebookComposeVC!, animated: true, completion: nil)
                }
                else {
                    self.showAlertMessage(message: "You are not connected to your Facebook account.")
                }
            }
            
            let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.default) { (action) -> Void in
                
                let activityViewController = UIActivityViewController(activityItems: [socialText!], applicationActivities: nil)
                //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
                self.present(activityViewController, animated: true, completion: nil)
                
            }
            let follow = UIAlertAction(title: "Follow", style: .default) { (alert: UIAlertAction!) -> Void in
                NSLog("You pressed button one")
            }
            let block = UIAlertAction(title: "Block this Message", style: .default) { (alert: UIAlertAction!) -> Void in
                NSLog("You pressed button two")
            }
            let report = UIAlertAction(title: "Report this User", style: .destructive) { (alert: UIAlertAction!) -> Void in
                NSLog("You pressed button one")
            }
            let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) -> Void in
            }
            actionSheet.addAction(follow)
            actionSheet.addAction(block)
            actionSheet.addAction(report)
            actionSheet.addAction(tweetAction)
            actionSheet.addAction(facebookPostAction)
            actionSheet.addAction(moreAction)
            actionSheet.addAction(dismissAction)
            
            self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showAlertMessage(message: String!) {
        let alertController = UIAlertController(title: "EasyShare", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - imgLoadSegue
    
    func imgLoadSegue(sender:UITapGestureRecognizer) {
        titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "PostBy") as? String)!
        self.performSegue(withIdentifier: "bloguserSegue", sender: self)
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "blogeditSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blogeditSegue" {
            
            let VC = segue.destination as? BlogEditController
            let myIndexPath = self.tableView!.indexPathForSelectedRow!.row
            VC!.objectId = (_feedItems[myIndexPath] as AnyObject).value(forKey: "objectId") as? String
            VC!.msgNo = (_feedItems[myIndexPath] as AnyObject).value(forKey: "MsgNo") as? String
            VC!.postby = (_feedItems[myIndexPath] as AnyObject).value(forKey: "PostBy") as? String
            VC!.subject = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Subject") as? String
            VC!.msgDate = (_feedItems[myIndexPath] as AnyObject).value(forKey: "MsgDate") as? String
            VC!.rating = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Rating") as? String
            VC!.liked = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Liked") as? Int
            VC!.replyId = (_feedItems[myIndexPath] as AnyObject).value(forKey: "ReplyId") as? String
        }
        if segue.identifier == "blognewSegue" {
            
            let VC = segue.destination as? BlogNewController
            
            if isReplyClicked == true {
                VC!.formStatus = "Reply"
                VC!.textcontentsubject = String(format:"@%@", posttoIndex!)
                VC!.textcontentpostby = defaults.string(forKey: "usernameKey") //PFUser.current()!.value(forKey: "username") as? String
                VC!.replyId = String(format:"%@", userIndex!)
            } else {
                VC!.formStatus = "New"
                VC!.textcontentpostby = defaults.string(forKey: "usernameKey") //PFUser.current()?.username
            }
        }
        if segue.identifier == "bloguserSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadUserController
            
            controller.formController = "Blog"
            controller.postBy = titleLabel
            
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
}

// MARK: - detect a URL in a String using NSDataDetector

extension NSRange {
    
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}

    // MARK: - UISearchBar Delegate
extension Blog: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = Color.Blog.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true, completion: nil)
    }
}

extension Blog: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let firstNameQuery = PFQuery(className:"Leads")
        firstNameQuery.whereKey("First", contains: searchController.searchBar.text)
        
        let lastNameQuery = PFQuery(className:"Leads")
        lastNameQuery.whereKey("LastName", matchesRegex: "(?i)\(searchController.searchBar.text)")
        
        let query = PFQuery.orQuery(withSubqueries: [firstNameQuery, lastNameQuery])
        query.findObjectsInBackground { (results:[PFObject]?, error:Error?) -> Void in
            
            if error != nil {
                self.simpleAlert(title: "Alert", message: (error?.localizedDescription)!)
                return
            }
            if let objects = results {
                self.foundUsers.removeAll(keepingCapacity: false)
                for object in objects {
                    let firstName = object.object(forKey: "First") as! String
                    let lastName = object.object(forKey: "LastName") as! String
                    let fullName = firstName + " " + lastName
                    
                    self.foundUsers.append(fullName)
                    print(fullName)
                }
                DispatchQueue.main.async {
                    self.resultsController.tableView.reloadData()
                    self.searchController.resignFirstResponder()
                }
            }
        }
    }
} 
