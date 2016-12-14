//
//  Vendor.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Vendor: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    let searchScope = ["name","city","phone","department"]
    
    @IBOutlet weak var tableView: UITableView?
    
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()
 
    var pasteBoard = UIPasteboard.general
    var refreshControl: UIRefreshControl!
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var users:[[String:AnyObject]]!
    var foundUsers:[[String:AnyObject]]!
    var userDetails:[String:AnyObject]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("Vendors", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton

        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        users = []
        foundUsers = []
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(Vendor.searchButton))
        navigationItem.rightBarButtonItems = [addButton,searchButton]
        
        parseData()
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Vend.navColor
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(Vendor.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = .white
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.Vend.navColor
        }
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
        parseData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Button
    
    func newData() {
        
        self.performSegue(withIdentifier: "newvendSegue", sender: self)
        
    }

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return _feedItems.count 
        }
        return foundUsers.count
        //return filteredString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        if tableView == self.tableView{
            cellIdentifier = "Cell"
        }else{
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.vendsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.vendtitleLabel!.font = Font.celltitlePad
            cell.vendsubtitleLabel!.font = Font.cellsubtitle
            cell.vendlikeLabel.font = Font.celltitle

        } else {
            cell.vendtitleLabel!.font = Font.celltitle
            cell.vendsubtitleLabel!.font = Font.cellsubtitle
            cell.vendlikeLabel.font = Font.News.newslabel2
        }
        
        if (tableView == self.tableView) {
            
            cell.vendtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Vendor") as? String
            cell.vendsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Profession") as? String
 
        } else {
            
            cell.vendtitleLabel!.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "Vendor") as? String
    
            cell.vendsubtitleLabel.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Profession") as? String
        }
        
        cell.vendreplyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.vendreplyButton .setImage(replyimage, for: UIControlState())
        
        cell.vendlikeButton.tintColor = .lightGray
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        cell.vendlikeButton .setImage(likeimage, for: UIControlState())
        
        cell.vendreplyLabel.text! = ""
        
        if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
            cell.vendreplyButton!.tintColor = .lightGray
        } else {
            cell.vendreplyButton!.tintColor = Color.Vend.buttonColor
        }
        
        if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
            cell.vendlikeButton!.tintColor = Color.Vend.buttonColor
            cell.vendlikeLabel.text! = "Active"
            cell.vendlikeLabel.adjustsFontSizeToFitWidth = true
        } else {
            cell.vendlikeButton!.tintColor = .lightGray
            cell.vendlikeLabel.text! = ""
        }
        
        let myLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        myLabel.backgroundColor = Color.Vend.labelColor
        myLabel.textColor = .white
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.masksToBounds = true
        myLabel.text = "Vendor"
        myLabel.font = Font.headtitle
        myLabel.layer.cornerRadius = 25.0
        myLabel.isUserInteractionEnabled = true
        cell.addSubview(myLabel)
        
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
        vw.backgroundColor = Color.Vend.navColor
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Vendor\n", _feedItems.count)
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = Color.Vend.buttonColor
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
        separatorLineView2.backgroundColor = Color.Vend.buttonColor
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
        separatorLineView3.backgroundColor = Color.Vend.buttonColor
        vw.addSubview(separatorLineView3)
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let query = PFQuery(className:"Vendors")
            query.whereKey("objectId", equalTo:((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!)
            
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
            
            _feedItems.removeObject(at: indexPath.row)
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
        
        let query = PFQuery(className:"Vendors")
        query.limit = 1000
        query.order(byAscending: "Vendor")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
                
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Vendors")
        query1.whereKey("Active", equalTo:1)
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        //query1.order(byDescending: "createdAt")
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
        UISearchBar.appearance().barTintColor = Color.Vend.navColor
        
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {

    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == resultsController.tableView {
            userDetails = foundUsers[indexPath.row]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        } else {
            self.performSegue(withIdentifier: "vendordetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "vendordetailSegue" {
            
            let formatter = NumberFormatter()
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            
            controller.formController = "Vendor"
            let indexPath = self.tableView!.indexPathForSelectedRow!.row
            controller.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
            
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            var LeadNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "VendorNo") as? Int
            formatter.numberStyle = .none
            if LeadNo == nil {
                LeadNo = 0
            }
            controller.leadNo =  formatter.string(from: LeadNo! as NSNumber)
            
            var Active:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Active")as? Int
            if Active == nil {
                Active = 0
            }
            controller.active = formatter.string(from: Active! as NSNumber)
            
            controller.date = (_feedItems[indexPath] as AnyObject).value(forKey: "WebPage") as? String
            controller.name = (_feedItems[indexPath] as AnyObject).value(forKey: "Vendor") as? String
            controller.address = (_feedItems[indexPath] as AnyObject).value(forKey: "Address") as? String
            controller.city = (_feedItems[indexPath] as AnyObject).value(forKey: "City") as? String
            controller.state = (_feedItems[indexPath] as AnyObject).value(forKey: "State") as? String
            controller.zip = (_feedItems[indexPath] as AnyObject).value(forKey: "Zip") as? String
            controller.amount = (_feedItems[indexPath] as AnyObject).value(forKey: "Profession") as? String
            controller.tbl11 = (_feedItems[indexPath] as AnyObject).value(forKey: "Phone") as? String
            controller.tbl12 = (_feedItems[indexPath] as AnyObject).value(forKey: "Phone1") as? String
            controller.tbl13 = (_feedItems[indexPath] as AnyObject).value(forKey: "Phone3") as? String
            controller.tbl14 = (_feedItems[indexPath] as AnyObject).value(forKey: "Phone3") as? String
            controller.tbl15 = (_feedItems[indexPath] as AnyObject).value(forKey: "Assistant") as? NSString
            controller.tbl21 = (_feedItems[indexPath] as AnyObject).value(forKey: "Email") as? NSString
            controller.tbl22 = (_feedItems[indexPath] as AnyObject).value(forKey: "Department") as? String
            controller.tbl23 = (_feedItems[indexPath] as AnyObject).value(forKey: "Office") as? String
            controller.tbl24 = (_feedItems[indexPath] as AnyObject).value(forKey: "Manager") as? String
            controller.tbl25 = (_feedItems[indexPath] as AnyObject).value(forKey: "Profession") as? String
            
            let dateUpdated = (_feedItems[indexPath] as AnyObject).value(forKey: "updatedAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            controller.tbl26 = (_feedItems[indexPath] as AnyObject).value(forKey: "WebPage") as? NSString
            controller.comments = (_feedItems[indexPath] as AnyObject).value(forKey: "Comments") as? String
            controller.l11 = "Phone"; controller.l12 = "Phone1"
            controller.l13 = "Phone2"; controller.l14 = "Phone3"
            controller.l15 = "Assistant"; controller.l21 = "Email"
            controller.l22 = "Department"; controller.l23 = "Office"
            controller.l24 = "Manager"; controller.l25 = "Profession"
            controller.l16 = "Last Updated"; controller.l26 = "Web Page"
            controller.l1datetext = "Web Page:"
            controller.lnewsTitle = Config.NewsVend
            
        }
        
        if segue.identifier == "newvendSegue" {
            let controller = segue.destination as? EditData
            controller?.formController = "Vendor"
            controller?.status = "New"
        }
        
    }
    
}
//-----------------------end------------------------------
