//
//  LeadUserController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/2/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class LeadUserController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellHeadtitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
    let cellHeadsubtitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    let cellHeadlabel = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    
    let ipadtitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
    let ipadsubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    let ipadlabel = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    
    let cellsubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    let celllabel = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    let headtitle = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    
    @IBOutlet weak var tableView: UITableView?

    var _feedItems : NSMutableArray = NSMutableArray()
    var _feedheadItems : NSMutableArray = NSMutableArray()
    var filteredString : NSMutableArray = NSMutableArray()
    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
    var refreshControl: UIRefreshControl!
    
    var emptyLabel : UILabel?
    var objectId : String?
    var leadDate : String?
    var postBy : String?
    var comments : String?
    
    var formController : String?
    
    //var selectedImage : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle(formController, for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = .white
        tableView!.tableFooterView = UIView(frame: .zero)
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.parseData()
        
        //self.selectedImage = UIImage(named:"profile-rabbit-toy.png")
        if (self.formController == "Blog") {
        self.comments = "90 percent of my picks made $$$. The stock whisper has traded over 1000 traders worldwide"
        }
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(LeadUserController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
        emptyLabel = UILabel(frame: self.view.bounds)
        emptyLabel!.textAlignment = NSTextAlignment.center
        emptyLabel!.textColor = .lightGray
        emptyLabel!.text = "You have no customer data :)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = Color.DGrayColor

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.hidesBarsOnSwipe = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject)
    {
        self.tableView!.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return _feedItems.count 
        }
        //return foundUsers.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.blogsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.blogtitleLabel!.font = ipadtitle
            cell.blogsubtitleLabel!.font = ipadsubtitle
            cell.blogmsgDateLabel!.font = ipadlabel
            cell.commentLabel!.font = ipadlabel
        } else {
            cell.blogtitleLabel!.font = Font.celltitle
            cell.blogsubtitleLabel!.font = cellsubtitle
            cell.blogmsgDateLabel!.font = celllabel
            cell.commentLabel!.font = celllabel

        }
        
        let dateStr : String
        let dateFormatter = DateFormatter()
        
        if (self.formController == "Blog") {
            dateStr = ((_feedItems[indexPath.row] as AnyObject).value(forKey: "MsgDate") as? String)!
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else {
            dateStr = ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Date") as? String)!
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
    
        let date:Date = dateFormatter.date(from: dateStr)as Date!
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        if (self.formController == "Blog") {
            
            cell.blogtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "PostBy") as? String
            cell.blogsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Subject") as? String
            cell.blogmsgDateLabel!.text = dateFormatter.string(from: date)as String!
            var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey: "CommentCount")as? Int
            if CommentCount == nil {
                CommentCount = 0
            }
            cell.commentLabel?.text = "\(CommentCount!)"
            
        } else {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            cell.blogtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "LastName") as? String
            cell.blogsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "City") as? String
            cell.blogmsgDateLabel!.text = dateFormatter.string(from: date)as String!
            var CommentCount:Int? = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Amount")as? Int
            if CommentCount == nil {
                CommentCount = 0
            }
            cell.commentLabel?.text = formatter.string(from: CommentCount! as NSNumber)        }
        
        cell.actionBtn.tintColor = .lightGray
        let imagebutton : UIImage? = UIImage(named:"Upload50.png")!.withRenderingMode(.alwaysTemplate)
        cell.actionBtn .setImage(imagebutton, for: UIControlState())
        //actionBtn .addTarget(self, action: "shareButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.replyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.replyButton .setImage(replyimage, for: UIControlState())
        //cell.replyButton .addTarget(self, action: "replyButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if !(cell.commentLabel.text! == "0") {
            cell.commentLabel.textColor = .lightGray
        } else {
            cell.commentLabel.text! = ""
        }
        
        if (cell.commentLabel.text! == "") {
            cell.replyButton.tintColor = .lightGray
        } else {
            cell.replyButton.tintColor = .red
        }
        
        let myLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        if (self.formController == "Leads") {
            myLabel.text = "Cust"
        } else if (self.formController == "Customer") {
            myLabel.text = "Lead"
        } else if (self.formController == "Blog") {
            myLabel.text = "Blog"
        }
        myLabel.backgroundColor = UIColor(red: 0.02, green: 0.75, blue: 1.0, alpha: 1.0)
        myLabel.textColor = .white
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.masksToBounds = true
        myLabel.font = headtitle
        myLabel.layer.cornerRadius = 25.0
        myLabel.isUserInteractionEnabled = true
        cell.addSubview(myLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = UIColor(white:0.90, alpha:1.0)
        //tableView.tableHeaderView = vw
        
        let myLabel4:UILabel = UILabel(frame: CGRect(x: 10, y: 70, width: self.tableView!.frame.size.width-20, height: 50))
        let myLabel5:UILabel = UILabel(frame: CGRect(x: 10, y: 105, width: self.tableView!.frame.size.width-20, height: 50))
        let myLabel6:UILabel = UILabel(frame: CGRect(x: 10, y: 140, width: self.tableView!.frame.size.width-20, height: 50))
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            myLabel4.font = cellHeadtitle
            myLabel5.font = cellHeadsubtitle
            myLabel6.font = cellHeadlabel
        } else {
            myLabel4.font = cellHeadtitle
            myLabel5.font = cellHeadsubtitle
            myLabel6.font = cellHeadlabel
        }
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Count\n", _feedItems.count)
        myLabel1.font = headtitle
        myLabel1.layer.cornerRadius = 25.0
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
        myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        myLabel2.font = headtitle
        myLabel2.layer.cornerRadius = 25.0
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
        myLabel3.text = "Active"
        myLabel3.font = headtitle
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.isUserInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        myLabel4.numberOfLines = 1
        myLabel4.backgroundColor = .clear
        myLabel4.textColor = .black
        myLabel4.layer.masksToBounds = true
        myLabel4.text = self.postBy
        vw.addSubview(myLabel4)
        
        myLabel5.numberOfLines = 0
        myLabel5.backgroundColor = .clear
        myLabel5.textColor = .black
        myLabel5.layer.masksToBounds = true
        myLabel5.text = self.comments
        vw.addSubview(myLabel5)
        
        if (self.formController == "Leads") || (self.formController == "Customer") {
            var dateStr = self.leadDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let date:Date = dateFormatter.date(from: dateStr!) as Date!
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateStr = dateFormatter.string(from: date)as String!
        
            var newString6 : String
            if (self.formController == "Leads") {
                newString6 = String(format: "%@%@", "Lead since ", dateStr!)
                myLabel6.text = newString6
            } else if (self.formController == "Customer") {
                newString6 = String(format: "%@%@", "Customer since ", dateStr!)
                myLabel6.text = newString6
            } else if (self.formController == "Blog") {
                newString6 = String(format: "%@%@", "Member since ", (self.leadDate)!)
                myLabel6.text = newString6
            }
        }
    
        myLabel6.numberOfLines = 1
        myLabel6.backgroundColor = .clear
        myLabel6.textColor = .black
        myLabel6.layer.masksToBounds = true
        //myLabel6.text = newString6
        vw.addSubview(myLabel6)
        
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
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Content Menu
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    private func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        
        if (action == #selector(NSObject.copy)) {
            return true
        }
        return false
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
    
    // MARK: - Parse
    
    func parseData() {
        
        if (self.formController == "Leads") {
            let query = PFQuery(className:"Customer")
            query.limit = 1000
            query.whereKey("LastName", equalTo:self.postBy!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    
                    if (self._feedItems.count == 0) {
                        self.tableView!.addSubview(self.emptyLabel!)
                    } else {
                        self.emptyLabel!.removeFromSuperview()
                    }
                    
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query1 = PFQuery(className:"Leads")
            query1.limit = 1
            query1.whereKey("objectId", equalTo:self.objectId!)
            query1.cachePolicy = PFCachePolicy.cacheThenNetwork
            query1.order(byDescending: "createdAt")
            query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.comments = object!.object(forKey: "Coments") as? String
                    self.leadDate = object!.object(forKey: "Date") as? String
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        } else if (self.formController == "Customer") {
            
            let query = PFQuery(className:"Leads")
            query.limit = 1000
            query.whereKey("LastName", equalTo:self.postBy!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    
                    if (self._feedItems.count == 0) {
                        self.tableView!.addSubview(self.emptyLabel!)
                    } else {
                        self.emptyLabel!.removeFromSuperview()
                    }
                    
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query1 = PFQuery(className:"Customer")
            query1.limit = 1
            query1.whereKey("objectId", equalTo:self.objectId!)
            query1.cachePolicy = PFCachePolicy.cacheThenNetwork
            query1.order(byDescending: "createdAt")
            query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.comments = object!.object(forKey: "Comments") as? String
                    self.leadDate = object!.object(forKey: "Date") as? String
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        } else if (self.formController == "Blog") {
            
            let query = PFQuery(className:"Blog")
            query.limit = 1000
            query.whereKey("PostBy", equalTo:self.postBy!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    
                    if (self._feedItems.count == 0) {
                        self.tableView!.addSubview(self.emptyLabel!)
                    } else {
                        self.emptyLabel!.removeFromSuperview()
                    }
                    
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
            let query1:PFQuery = PFUser.query()!
            query1.whereKey("username",  equalTo:self.postBy!)
            query1.limit = 1
            query1.cachePolicy = PFCachePolicy.cacheThenNetwork
            query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    
                    self.postBy = object!.object(forKey: "username") as? String
                    /*
                    let dateStr = (object!.objectForKey("createdAt") as? NSDate)!
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy"
                    let createAtString = dateFormatter.stringFromDate(dateStr)as String!
                    self.leadDate = createAtString */

                    /*
                    if let imageFile = object!.objectForKey("imageFile") as? PFFile {
                        imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                            self.selectedImage = UIImage(data: imageData!)
                            self.tableView!.reloadData()
                        }
                    } */
                }
            }
            
        }
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
    }
    
}
