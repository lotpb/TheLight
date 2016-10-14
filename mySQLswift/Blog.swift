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
    
    //var messages = [Message]()
    //var messagesDictionary = [String: Message]()
    //var users = [User]()
    //var usersDictionary = [String: User]()
    
    var buttonView: UIView?
    var likeButton: UIButton?
    var refreshControl: UIRefreshControl!
    let searchController = UISearchController(searchResultsController: nil)

    var isReplyClicked = true
    var posttoIndex: String?
    var userIndex: String?
    var titleLabel = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: view.frame.height))
        titleLabel.text = "myBlog"
        titleLabel.textColor = .white
        titleLabel.font = Font.navlabel
        titleLabel.textAlignment = NSTextAlignment.center
        navigationItem.titleView = titleLabel
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        parseData()
        setupTableView()
        setupNavBarButtons()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = Color.Blog.navColor
        self.refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Last updated on \(NSDate())", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(Blog.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
        /*
         if let split = self.splitViewController {
         let controllers = split.viewControllers
         self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
         } */
        
        /*
         FIRAuth.auth()?.signIn(withEmail: "eunitedws@verizon.net", password: "united", completion: { (user, error) in
         
         if error != nil {
         print(error)
         return
         }
         self.observeMessages()
         //self.observeUser()
         //self.checkIfUserIsLoggedIn()
         }) */

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.Blog.navColor
        }
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
        self.tableView!.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.tableView!.estimatedSectionHeaderHeight = 90
        self.tableView!.sectionFooterHeight = UITableViewAutomaticDimension;
        self.tableView!.estimatedSectionFooterHeight = 0
        self.tableView!.backgroundColor =  UIColor(white:0.90, alpha:1.0)
    }
    
    func setupNavBarButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(Blog.newButton))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(Blog.searchButton))
        navigationItem.rightBarButtonItems = [addButton,searchButton]
    }
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject) {
        parseData()
        self.refreshControl?.endRefreshing()
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return filteredString.count
        }
        else {
            return _feedItems.count
        }
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableCell else { fatalError("Unexpected Index Path") }
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.blogtitleLabel!.font =  Font.Blog.celltitle
            cell.blogsubtitleLabel!.font =  Font.Blog.cellsubtitle
            cell.blogmsgDateLabel.font = Font.Blog.celldate
            cell.numLabel.font = Font.Blog.cellLabel
            cell.commentLabel.font = Font.Blog.cellLabel
            
        } else {
            
            cell.blogtitleLabel!.font =  Font.Blog.celltitle
            cell.blogsubtitleLabel!.font =  Font.Blog.cellsubtitle
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

        if searchController.isActive {
            cell.blogtitleLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"PostBy") as? String
            cell.blogsubtitleLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"Subject") as? String
            cell.blogmsgDateLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"MsgDate") as? String
            cell.numLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"Liked") as? String
            cell.commentLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"CommentCount") as? String
        } else {
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
        }
        
        cell.replyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.replyButton .setImage(replyimage, for: .normal)
        cell.replyButton .addTarget(self, action: #selector(replySetButton), for: UIControlEvents.touchUpInside)
        
        cell.likeButton.tintColor = .lightGray
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(likeimage, for: .normal)
        cell.likeButton.addTarget(self, action: #selector(likeSetButton), for: UIControlEvents.touchUpInside)

        cell.flagButton.tintColor = .lightGray
        let reportimage : UIImage? = UIImage(named:"Flag.png")!.withRenderingMode(.alwaysTemplate)
        cell.flagButton .setImage(reportimage, for: .normal)
        cell.flagButton .addTarget(self, action: #selector(flagSetButton), for: UIControlEvents.touchUpInside)
  
        cell.actionBtn.tintColor = .lightGray
        let actionimage : UIImage? = UIImage(named:"nav_more_icon.png")!.withRenderingMode(.alwaysTemplate)
        cell.actionBtn .setImage(actionimage, for: .normal)
        cell.actionBtn .addTarget(self, action: #selector(showShare), for: UIControlEvents.touchUpInside)
        
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
        
        let text = (cell.blogsubtitleLabel.text!) as NSString
        let attributedText = NSMutableAttributedString(attributedString: (cell.blogsubtitleLabel.attributedText!))

        let boldRange = text.range(of: NSLocalizedString("VCSY", comment: ""))
        let tintedRange = text.range(of: NSLocalizedString("eunited@verizon.com", comment: ""))
        let tintedRange1 = text.range(of: NSLocalizedString("http://www.eunited.com", comment: ""))
        let highlightedRange = text.range(of: NSLocalizedString("(516)241-4786", comment: ""))
        let underlinedRange = text.range(of: NSLocalizedString("Lost", comment: ""))
        
        // Add bold.
        let boldFontDescriptor = cell.blogsubtitleLabel.font.fontDescriptor.withSymbolicTraits(.traitBold)
        let boldFont = UIFont(descriptor: boldFontDescriptor!, size: 24)
        attributedText.addAttribute(NSFontAttributeName, value: boldFont, range: boldRange)
        
        // Add tint.
        attributedText.addAttribute(NSForegroundColorAttributeName, value: Color.Blog.emaillinkText, range: tintedRange)
        attributedText.addAttribute(NSForegroundColorAttributeName, value: Color.Blog.weblinkText, range: tintedRange1)
        
        // Add highlight.
        attributedText.addAttribute(NSBackgroundColorAttributeName, value: Color.Blog.phonelinkText, range: highlightedRange)
        
        // Add underline.
        attributedText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: underlinedRange)
        /*
        // Append a space with matching font of the rest of the body text.
        let appendedSpace = NSMutableAttributedString.init(string: " ")
        appendedSpace.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, 1))
        attributedText.append(appendedSpace) */
        
        cell.blogsubtitleLabel!.attributedText  = attributedText

//--------------------------------------------------

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            return 90.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = Color.Blog.navColor
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Blog\n", _feedItems.count)
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.layer.borderColor = Color.Blog.borderbtnColor
        myLabel1.layer.borderWidth = 1
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = .white
        vw.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: 80, y: 15, width: 50, height: 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = NSTextAlignment.center
        myLabel2.layer.masksToBounds = true
        myLabel2.text = String(format: "%@%d", "Likes\n", _feedheadItems2.count)
        myLabel2.font = Font.headtitle
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.layer.borderColor = Color.Blog.borderbtnColor
        myLabel2.layer.borderWidth = 1
        myLabel2.isUserInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: CGRect(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = .white
        vw.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: CGRect(x: 150, y: 15, width: 50, height: 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = .black
        myLabel3.textAlignment = NSTextAlignment.center
        myLabel3.layer.masksToBounds = true
        myLabel3.text = String(format: "%@%d", "Users\n", _feedheadItems3.count)
        myLabel3.font = Font.headtitle
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.layer.borderColor = Color.Blog.borderbtnColor
        myLabel3.layer.borderWidth = 1
        myLabel3.isUserInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        let separatorLineView3 = UIView(frame: CGRect(x: 150, y: 75, width: 50, height: 2.5))
        separatorLineView3.backgroundColor = .white
        vw.addSubview(separatorLineView3)
        
        return vw
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
        sender.tintColor = .red
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
    
    // MARK: - Search
    
    func searchButton(_ sender: AnyObject) {
        //UIApplication.sharedApplication().statusBarHidden = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = Color.Blog.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true, completion: nil)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
 
    }
    
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
                VC!.textcontentpostby = PFUser.current()!.value(forKey: "username") as? String
                VC!.replyId = String(format:"%@", userIndex!)
            } else {
                VC!.formStatus = "New"
                VC!.textcontentpostby = PFUser.current()!.username
            }
        }
        if segue.identifier == "bloguserSegue" {
                let controller = segue.destination as? LeadUserController
                controller!.formController = "Blog"
                controller!.postBy = titleLabel
        }
    }
    
}

    // MARK: - UISearchBar Delegate
extension Blog: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension Blog: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
} 
