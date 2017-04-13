//
//  Blog.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
//import Firebase
import Parse
import Social

class Blog: UIViewController {
    
    let searchScope = ["subject", "date", "rating", "postby"]
    
    @IBOutlet weak var tableView: UITableView?

    var _feedItems = NSMutableArray()
    var _feedheadItems2 = NSMutableArray()
    var _feedheadItems3 = NSMutableArray()
    var filteredString = NSMutableArray()
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers = [String]()
    
    //var vw = UIView()
    let header = UIView()
    
    var buttonView: UIView?
    var likeButton: UIButton?
    var isReplyClicked = true
    var posttoIndex: String?
    var userIndex: String?
    var titleLabel = String()
    var defaults = UserDefaults.standard
    
    // MARK: NavigationController Hidden
    var lastContentOffset: CGFloat = 0.0
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.twitterText
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false

        setupTableView()
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(Blog.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        setupNavigationBarItems()
        setupTwitterNavigationBarItems()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = .clear //UIColor(white:0.90, alpha:1.0)
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        //self.tableView!.tableFooterView = UIView(frame: .zero)
        // MARK: - TableHeader
        self.automaticallyAdjustsScrollViewInsets = false //fix
        header.backgroundColor = Color.Blog.navColor
        //header.frame = CGRect(x: 0, y: 0, width: (tableView?.frame.width)!, height: 90)
        //self.tableView!.tableHeaderView = header
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    
    // MARK: - NavigationController Hidden
    
    func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
            self.tableView!.tableHeaderView = nil
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
            self.tableView!.tableHeaderView = header
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject) {
        parseData()
        //self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    
    func newButton(sender: AnyObject) {
        
        isReplyClicked = false
        self.performSegue(withIdentifier: "blognewSegue", sender: self)
    }
    
    func likeSetButton(sender:UIButton) {

        sender.isSelected = true
        sender.tintColor = Color.twitterBlue
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        let query = PFQuery(className:"Blog")
        query.whereKey("objectId", equalTo:((_feedItems.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
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
    
    // MARK: - Parse

    func parseData() {
        
        let query = PFQuery(className:"Blog")
        query.limit = 1000
        query.whereKey("ReplyId", equalTo:NSNull())
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let temp : NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView?.reloadData()
            } else {
                print("Error9")
            }
        }
        
        let query1 = PFQuery(className:"Blog")
        query1.limit = 1000
        //query1.whereKey("Rating", equalTo:"5")
        query1.whereKey("Liked", notEqualTo:NSNull())
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        query1.order(byDescending: "createdAt")
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems2 = temp.mutableCopy() as! NSMutableArray
                self.tableView?.reloadData()
            } else {
                print("Error10")
            }
        }
        
        let query3 = PFUser.query()
        query3?.limit = 1000
        query3?.cachePolicy = PFCachePolicy.cacheThenNetwork
        query3?.order(byDescending: "createdAt")
        query3?.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems3 = temp.mutableCopy() as! NSMutableArray
                self.tableView?.reloadData()
            } else {
                print("Error11")
            }
        }
    }
    
    // MARK: - AlertController
    
    func showShare(sender: UIButton) {
        
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        let socialText = (self._feedItems[indexPath!.row] as AnyObject).value(forKey: "Subject") as? String
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) in
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                if socialText!.characters.count <= 140 {
                    twitterComposeVC?.setInitialText(socialText)
                    //twitterComposeVC?.add(imageView.image)
                    twitterComposeVC?.add(URL(string: "http://lotpb.github.io/UnitedWebPage/index.html"))
                } else {
                    let index = socialText!.characters.index(socialText!.startIndex, offsetBy: 140)
                    let subText = socialText!.substring(to: index)
                    twitterComposeVC?.setInitialText("\(subText)")
                }
                
                self.present(twitterComposeVC!, animated: true)
            } else {
                self.simpleAlert(title: "Alert", message: "You are not logged in to your Twitter account.")
            }
        }
        
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) in
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                vc?.setInitialText(socialText)
                //vc.add(imageView.image!)
                vc?.add(URL(string: "http://lotpb.github.io/UnitedWebPage/index.html"))
                self.present(vc!, animated: true)
            }
            else {
                self.simpleAlert(title: "Alert", message: "You are not connected to your Facebook account.")
            }
        }
        
        let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.default) { (action) in
            let activityViewController = UIActivityViewController(activityItems: [socialText!], applicationActivities: nil)
            //activityViewController.excludedActivityTypes = [UIActivityTypeMail]
            self.present(activityViewController, animated: true)
        }
        let followAction = UIAlertAction(title: "Follow", style: .default) { (alert: UIAlertAction!) in
            NSLog("You pressed button one")
        }
        let blockAction = UIAlertAction(title: "Block this Message", style: .default) { (alert: UIAlertAction!) in
            NSLog("You pressed button two")
        }
        let reportAction = UIAlertAction(title: "Report this User", style: .destructive) { (alert: UIAlertAction!) in
            NSLog("You pressed button one")
        }
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) in
        }
        actionSheet.addAction(followAction)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(reportAction)
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            //actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        self.present(actionSheet, animated: true)
    }
    
    // MARK: - imgLoadSegue
    
    func imgLoadSegue(sender:UITapGestureRecognizer) {
        titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "PostBy") as? String)!
        self.performSegue(withIdentifier: "bloguserSegue", sender: self)
    }
    
    // MARK: - Segues
    
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
                VC!.textcontentsubject = String(format: "%@", "@\(posttoIndex!.removingWhitespaces()) ")
                VC!.textcontentpostby = defaults.string(forKey: "usernameKey")
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
extension Blog: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableCell else { fatalError("Unexpected Index Path") }
        
        cell.selectionStyle = .none
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
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
                        
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
            if Liked == nil { Liked = 0 }
            cell.numLabel?.text = "\(Liked!)"
            
            var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey:"CommentCount") as? Int
            if CommentCount == nil { CommentCount = 0 }
            cell.commentLabel?.text = "\(CommentCount!)"
            
        } else {
            
            cell.blogtitleLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"PostBy") as? String
            cell.blogsubtitleLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"Subject") as? String
            cell.blogmsgDateLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"MsgDate") as? String
            cell.numLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"Liked") as? String
            cell.commentLabel?.text = (filteredString[indexPath.row] as AnyObject).value(forKey:"CommentCount") as? String
        }
        
        cell.replyButton.tintColor = .lightGray
        cell.replyButton.setImage(#imageLiteral(resourceName: "Commentfilled").withRenderingMode(.alwaysTemplate), for: .normal)
        cell.replyButton .addTarget(self, action: #selector(replySetButton), for: .touchUpInside)
        
        cell.likeButton.tintColor = .lightGray
        cell.likeButton.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        cell.likeButton.addTarget(self, action: #selector(likeSetButton), for: .touchUpInside)
        
        cell.flagButton.tintColor = .lightGray
        cell.flagButton.setImage(#imageLiteral(resourceName: "Flag").withRenderingMode(.alwaysTemplate), for: .normal)
        cell.flagButton .addTarget(self, action: #selector(flagSetButton), for: .touchUpInside)
        
        cell.actionBtn.tintColor = .lightGray
        cell.actionBtn.setImage(#imageLiteral(resourceName: "nav_more_icon").withRenderingMode(.alwaysTemplate), for: .normal)
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
        
        let text = (cell.blogsubtitleLabel.text!) as NSString
        let attributedText = NSMutableAttributedString(string: text as String)
        
        let boldRange = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: Color.Blog.weblinkText]
        let highlightedRange = [NSBackgroundColorAttributeName: Color.Blog.phonelinkText]
        let underlinedRange = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let tintedRange1 = [NSForegroundColorAttributeName: Color.Blog.weblinkText]
        
        attributedText.addAttributes(boldRange, range: text.range(of: "VCSY"))
        attributedText.addAttributes(highlightedRange, range: text.range(of: "(516)241-4786"))
        attributedText.addAttributes(underlinedRange, range: text.range(of: "Lost", options: .caseInsensitive))
        attributedText.addAttributes(underlinedRange, range: text.range(of: "Made", options: .caseInsensitive))
        
        let input = (cell.blogsubtitleLabel.text!) as String
        let types: NSTextCheckingResult.CheckingType = [.date, .address, .phoneNumber, .link]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        for match in matches {
            let url = input.substring(with: match.range.range(for: text as String)!)
            attributedText.addAttributes(tintedRange1, range: text.range(of: url))
        }
        
        cell.blogsubtitleLabel!.attributedText = attributedText
        
        //--------------------------------------------------
        
        return cell
    }
}

extension Blog: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "blogeditSegue", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                return 90.0
            } else {
                return CGFloat.leastNormalMagnitude //0.0
            }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myLabel1:UILabel = UILabel(frame: CGRect.init(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = Color.goldColor
        myLabel1.textAlignment = .center
        myLabel1.text = String(format: "%@%d", "posts\n", _feedItems.count)
        myLabel1.font = Font.celltitle14m
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.layer.borderColor = Color.Blog.borderColor.cgColor
        myLabel1.layer.borderWidth = 1
        myLabel1.layer.masksToBounds = true
        myLabel1.isUserInteractionEnabled = true
        header.addSubview(myLabel1)
        
        let separatorLineView1 = UIView.init(frame: CGRect.init(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = Color.Blog.borderColor
        header.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect.init(x: 80, y: 15, width: 50, height: 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = Color.goldColor
        myLabel2.textAlignment = .center
        myLabel2.text = String(format: "%@%d", "likes\n", _feedheadItems2.count)
        myLabel2.font = Font.celltitle14m
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.layer.borderColor = Color.Blog.borderColor.cgColor
        myLabel2.layer.borderWidth = 1
        myLabel2.layer.masksToBounds = true
        myLabel2.isUserInteractionEnabled = true
        header.addSubview(myLabel2)
        
        let separatorLineView2 = UIView.init(frame: CGRect.init(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = Color.Blog.borderColor
        header.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: CGRect.init(x: 150, y: 15, width: 50, height: 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = Color.goldColor
        myLabel3.textAlignment = .center
        myLabel3.text = String(format: "%@%d", "users\n", _feedheadItems3.count)
        myLabel3.font = Font.celltitle14m
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.layer.borderColor = Color.Blog.borderColor.cgColor
        myLabel3.layer.borderWidth = 1
        myLabel3.layer.masksToBounds = true
        myLabel3.isUserInteractionEnabled = true
        header.addSubview(myLabel3)
        
        let separatorLineView3 = UIView.init(frame: CGRect.init(x: 150, y: 75, width: 50, height: 2.5))
        separatorLineView3.backgroundColor = Color.Blog.borderColor
        header.addSubview(separatorLineView3)
        
        return header
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
                query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) in
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
        //fix searchbar behind navbar
        //searchController.hidesNavigationBarDuringPresentation = false //fix added
        //searchController.searchBar.searchBarStyle = .minimal //fix added
        //definesPresentationContext = true //fix added
        self.present(searchController, animated: true)
    }
}

extension Blog: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
} 
