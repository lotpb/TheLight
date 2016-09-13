//
//  Lead.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Lead: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    let searchScope = ["name","city","phone","date","active"]
    
    @IBOutlet weak var tableView: UITableView?
    
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()
  
    var pasteBoard = UIPasteboard.general
    var refreshControl: UIRefreshControl!
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers = [String]()
    
    var objectIdLabel = String()
    var titleLabel = String()
    var dateLabel = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.red], for:.selected)
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("myLeads", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton

        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 89
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = .clear
        self.automaticallyAdjustsScrollViewInsets = false
        
        foundUsers = []
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Lead.newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(Lead.searchButton))
        let buttons:NSArray = [addButton,searchButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]

        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Lead.navColor
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(Lead.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
        parseData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = Color.Lead.navColor
        
        //animateTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.hidesBarsOnSwipe = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Refresh
    
    func refreshData(_ sender:AnyObject) {
        
        parseData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Button
    
    func newData() {
        
        self.performSegue(withIdentifier: "newleadSegue", sender: self)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"

        } else {
            cellIdentifier = "UserFoundCell"

        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: tableView.frame.size.width - 105, y: 0, width: 95, height: 32))
        myLabel1.backgroundColor = Color.Lead.labelColor1
        myLabel1.textColor = .white
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.font = Font.headtitle
        cell.addSubview(myLabel1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: tableView.frame.size.width - 105, y: 33, width: 95, height: 33))
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = NSTextAlignment.center
        myLabel2.layer.masksToBounds = true
        myLabel2.font = Font.headtitle
        cell.addSubview(myLabel2)
        
        cell.leadsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.leadtitleLabel!.font = Font.celltitle
            cell.leadsubtitleLabel!.font = Font.cellsubtitle
            cell.leadreplyLabel.font = Font.cellreply
            cell.leadlikeLabel.font = Font.celllike
            myLabel1.font = Font.celllabel1
            myLabel2.font = Font.celllabel2
            
        } else {
            
            cell.leadtitleLabel!.font = Font.celltitle
            cell.leadsubtitleLabel!.font =  Font.cellsubtitle
            cell.leadreplyLabel.font = Font.cellreply
            cell.leadlikeLabel.font = Font.celllike
            myLabel1.font = Font.celllabel1
            myLabel2.font = Font.celllabel2
        }
        
        if (tableView == self.tableView) {
            
            cell.leadtitleLabel!.text = (_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "LastName") as? String
            
            myLabel1.text = (_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "Date") as? String
            myLabel2.text = (_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "CallBack") as? String
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                cell.leadsubtitleLabel!.text = (_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "City") as? String
            } else {
                cell.leadsubtitleLabel!.text = ""
            }
        
        } else {

            cell.leadtitleLabel!.text = (filteredString[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "LastName") as? String
            cell.leadsubtitleLabel!.text = (filteredString[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "City") as? String
            myLabel1.text = (filteredString[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "Date") as? String
            myLabel2.text = (filteredString[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "CallBack") as? String
        }
        
        cell.leadreplyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.leadreplyButton .setImage(replyimage, for: UIControlState())
        
        cell.leadlikeButton.tintColor = .lightGray
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        cell.leadlikeButton .setImage(likeimage, for: UIControlState())
        
        cell.leadreplyLabel.text! = ""
        
        if ((_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "Coments") as? String == nil) || ((_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "Coments") as? String == "") {
            cell.leadreplyButton!.tintColor = .lightGray
        } else {
            cell.leadreplyButton!.tintColor = Color.Lead.buttonColor
        }
        
        if ((_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
            cell.leadlikeButton!.tintColor = Color.Lead.buttonColor
            cell.leadlikeLabel.text! = "Active"
            cell.leadlikeLabel.adjustsFontSizeToFitWidth = true
        } else {
            cell.leadlikeButton!.tintColor = .lightGray
            cell.leadlikeLabel.text! = ""
        }
        
        let myLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        myLabel.backgroundColor = Color.Lead.labelColor
        myLabel.textColor = .white
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.masksToBounds = true
        myLabel.text = "Lead"
        myLabel.font = Font.headtitle
        myLabel.layer.cornerRadius = 25.0
        myLabel.isUserInteractionEnabled = true
        myLabel.tag = (indexPath as NSIndexPath).row
        cell.addSubview(myLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Lead.imgLoadSegue))
        myLabel.addGestureRecognizer(tap)
        
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
        vw.backgroundColor = Color.Lead.navColor
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Leads\n", _feedItems.count)
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = Color.Lead.buttonColor
        vw.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: 80, y: 15, width: 50, height: 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = NSTextAlignment.center
        myLabel2.layer.masksToBounds = true
        myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        myLabel2.font = Font.headtitle
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.isUserInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: CGRect(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = Color.Lead.buttonColor
        vw.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: CGRect(x: 150, y: 15, width: 50, height: 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = .black
        myLabel3.textAlignment = NSTextAlignment.center
        myLabel3.layer.masksToBounds = true
        myLabel3.text = String(format: "%@%d", "Events\n", 3)
        myLabel3.font = Font.headtitle
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.isUserInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        let separatorLineView3 = UIView(frame: CGRect(x: 150, y: 75, width: 50, height: 2.5))
        separatorLineView3.backgroundColor = Color.Lead.buttonColor
        vw.addSubview(separatorLineView3)
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let query = PFQuery(className:"Leads")
            query.whereKey("objectId", equalTo:((self._feedItems.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "objectId") as? String)!)
            
            let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
            
            let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
                
                query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) -> Void in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                            //self.refreshData(self)
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
            
            _feedItems.removeObject(at: (indexPath as NSIndexPath).row)
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
    
    // MARK: - Search
    
    func searchButton(_ sender: AnyObject) {
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsBookmarkButton = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.scopeButtonTitles = searchScope
        //tableView!.tableHeaderView = searchController.searchBar
        tableView!.tableFooterView = UIView(frame: .zero)
        UISearchBar.appearance().barTintColor = Color.Lead.navColor
        
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        /*
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.foundUsers(searchString, scope: selectedScopeButtonIndex)
        self.tableView!.reloadData() */
        
        /*
        self.foundUsers.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self._feedItems as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.foundUsers = array as! [String]
        self.resultsController.tableView.reloadData() */
        
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

    // MARK: - Parse

    func parseData() {
        
        let query = PFQuery(className:"Leads")
        query.limit = 1000
        query.order(byDescending: "createdAt")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Leads")
        query1.whereKey("Active", equalTo:1)
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    // MARK: - imgLoadSegue
    
    func imgLoadSegue(_ sender:UITapGestureRecognizer) {
        objectIdLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "objectId") as? String)!
        dateLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "Date") as? String)!
        titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "LastName") as? String)!
        self.performSegue(withIdentifier: "leaduserSegue", sender: self)
    }

    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == resultsController.tableView {
            //userDetails = foundUsers[indexPath.row]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        } else {
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                let storyBoard : UIStoryboard = UIStoryboard (name: "Main", bundle: nil);
                let objSecondryViewController :LeadDetail = storyBoard.instantiateViewController(withIdentifier: "SecondryViewController") as! LeadDetail
                //objSecondryViewController.selectedColor = cell.textLabel?.text
                showDetailViewController(objSecondryViewController, sender: self)
                
            } else {
                self.performSegue(withIdentifier: "showDetail2", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail2" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let controller = segue.destination as? LeadDetail
            controller?.formController = "Leads"
            let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
            controller?.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
            
            var LeadNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "LeadNo") as? Int
            if LeadNo == nil {
                LeadNo = 0
            }
            controller?.leadNo = formatter.string(from: LeadNo! as NSNumber)

            var Zip:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Zip")as? Int
            if Zip == nil {
                Zip = 0
            }
            controller?.zip = formatter.string(from: Zip! as NSNumber)
            
            var Amount:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Amount")as? Int
            if Amount == nil {
                Amount = 0
            }
            controller?.amount = formatter.string(from: Amount! as NSNumber)
            
            var SalesNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "SalesNo")as? Int
            if SalesNo == nil {
                SalesNo = 0
            }
            controller?.tbl22 = formatter.string(from: SalesNo! as NSNumber)
            
            var JobNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "JobNo")as? Int
            if JobNo == nil {
                JobNo = 0
            }
            controller?.tbl23 = formatter.string(from: JobNo! as NSNumber)
            
            var AdNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "AdNo")as? Int
            if AdNo == nil {
                AdNo = 0
            }
            controller?.tbl24 = formatter.string(from: AdNo! as NSNumber)
            
            var Active:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Active")as? Int
            if Active == nil {
                Active = 0
            }
            controller?.tbl25 = formatter.string(from: Active! as NSNumber)
            controller?.tbl21 = (_feedItems[indexPath] as AnyObject).value(forKey: "AptDate") as? NSString
            
            let dateUpdated = (_feedItems[indexPath] as AnyObject).value(forKey: "updatedAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM d, yy"
            controller?.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            controller?.date = (_feedItems[indexPath] as AnyObject).value(forKey: "Date") as? String
            controller?.name = (_feedItems[indexPath] as AnyObject).value(forKey: "LastName") as? String
            controller?.address = (_feedItems[indexPath] as AnyObject).value(forKey: "Address") as? String
            controller?.city = (_feedItems[indexPath] as AnyObject).value(forKey: "City") as? String
            controller?.state = (_feedItems[indexPath] as AnyObject).value(forKey: "State") as? String
            controller?.tbl11 = (_feedItems[indexPath] as AnyObject).value(forKey: "CallBack") as? String
            controller?.tbl12 = (_feedItems[indexPath] as AnyObject).value(forKey: "Phone") as? String
            controller?.tbl13 = (_feedItems[indexPath] as AnyObject).value(forKey: "First") as? String
            controller?.tbl14 = (_feedItems[indexPath] as AnyObject).value(forKey: "Spouse") as? String
            controller?.tbl15 = (_feedItems[indexPath] as AnyObject).value(forKey: "Email") as? NSString
            controller?.tbl26 = (_feedItems[indexPath] as AnyObject).value(forKey: "Photo") as? NSString
            controller?.comments = (_feedItems[indexPath] as AnyObject).value(forKey: "Coments") as? String
            controller?.active = formatter.string(from: Active! as NSNumber)
            controller?.l11 = "Call Back"; controller?.l12 = "Phone"
            controller?.l13 = "First"; controller?.l14 = "Spouse"
            controller?.l15 = "Email"; controller?.l21 = "Apt Date"
            controller?.l22 = "Salesman"; controller?.l23 = "Job"
            controller?.l24 = "Advertiser"; controller?.l25 = "Active"
            controller?.l16 = "Last Updated"; controller?.l26 = "Photo"
            controller?.l1datetext = "Lead Date:"
            controller?.lnewsTitle = Config.NewsLead
        }
        
        if segue.identifier == "leaduserSegue" {
            let controller = segue.destination as? LeadUserController
            controller!.formController = "Leads"
            controller!.objectId = objectIdLabel
            controller!.postBy = titleLabel
            controller!.leadDate = dateLabel
        }
        
        if segue.identifier == "newleadSegue" {
            let controller = segue.destination as? EditData
            controller!.formController = "Leads"
            controller!.status = "New"
        }
        
    }
    
}
//-----------------------end------------------------------

