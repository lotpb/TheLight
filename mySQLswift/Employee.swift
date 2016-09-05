//
//  Employee.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Employee: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    //let navColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
    //let labelColor = UIColor(red: 0.31, green: 0.23, blue: 0.17, alpha: 1.0)

    let searchScope = ["name","city","phone","active"]
    
    @IBOutlet weak var tableView: UITableView?

    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()

    var pasteBoard = UIPasteboard.general
    var refreshControl: UIRefreshControl!
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var users:[[String:AnyObject]]!
    var foundUsers = [String]()
    var userDetails:[String:AnyObject]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("myEmployee", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        //self.tableView!.rowHeight = 65
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        users = []
        foundUsers = []
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Employee.newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(Employee.searchButton))
        let buttons:NSArray = [addButton,searchButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        parseData()
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Employ.navColor
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(Employee.refreshData), for: UIControlEvents.valueChanged)
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
        self.navigationController?.navigationBar.barTintColor = Color.Employ.navColor
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
        
        self.performSegue(withIdentifier: "newemploySegue", sender: self)
        
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return _feedItems.count ?? 0
        }
        return foundUsers.count
        //return filteredString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView{
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.employsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.employtitleLabel!.font = Font.celltitle
            cell.employsubtitleLabel!.font = Font.cellsubtitle

        } else {
            cell.employtitleLabel!.font = Font.celltitle
            cell.employsubtitleLabel!.font = Font.cellsubtitle
        }
        
        if (tableView == self.tableView) {
            
            cell.employtitleLabel!.text = String(format: "%@ %@ %@", (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "First") as? String)!,
                (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Last") as? String)!,
                (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Company") as? String)!)
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                cell.employsubtitleLabel!.text = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "Title") as? String
            } else {
                cell.employsubtitleLabel!.text = ""
            }
            
        } else {

            cell.employtitleLabel!.text = String(format: "%@ %@ %@", (filteredString[(indexPath as NSIndexPath).row].value(forKey: "First") as? String)!, (filteredString[(indexPath as NSIndexPath).row].value(forKey: "Last") as? String)!, (filteredString[(indexPath as NSIndexPath).row].value(forKey: "Company") as? String)!)
            cell.employsubtitleLabel!.text = filteredString[(indexPath as NSIndexPath).row].value(forKey: "Title") as? String
        }
        
        cell.employreplyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.employreplyButton .setImage(replyimage, for: UIControlState())
        
        cell.employlikeButton.tintColor = .lightGray
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        cell.employlikeButton .setImage(likeimage, for: UIControlState())
        
        cell.employreplyLabel.text! = ""
        
        if (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Comments") as? String == nil) || (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Comments") as? String == "") {
            cell.employreplyButton!.tintColor = .lightGray
        } else {
            cell.employreplyButton!.tintColor = Color.Employ.buttonColor
        }
        
        if (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Active") as? Int == 1 ) {
            cell.employlikeButton!.tintColor = Color.Employ.buttonColor
            cell.employlikeLabel.text! = "Active"
            cell.employlikeLabel.adjustsFontSizeToFitWidth = true
        } else {
            cell.employlikeButton!.tintColor = .lightGray
            cell.employlikeLabel.text! = ""
        }
        
        let myLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        myLabel.backgroundColor = Color.Employ.labelColor
        myLabel.text = "Employ"
        myLabel.textColor = .white
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.contentsGravity = kCAGravityResize
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 25.0
        myLabel.font = Font.headtitle
        myLabel.isUserInteractionEnabled = true
        myLabel.tag = (indexPath as NSIndexPath).row
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
        vw.backgroundColor = Color.Employ.navColor
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Employ\n", _feedItems.count)
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = Color.Employ.buttonColor
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
        separatorLineView2.backgroundColor = Color.Employ.buttonColor
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
        separatorLineView3.backgroundColor = Color.Employ.buttonColor
        vw.addSubview(separatorLineView3)
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let query = PFQuery(className:"Employee")
            query.whereKey("objectId", equalTo:(self._feedItems.object(at: (indexPath as NSIndexPath).row).value(forKey: "objectId") as? String)!)
            
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
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        if (action == #selector(NSObject.copy)) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
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
        UISearchBar.appearance().barTintColor = Color.Employ.navColor
        
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let firstNameQuery = PFQuery(className:"Leads")
        firstNameQuery.whereKey("Last", contains: searchController.searchBar.text)
        
       // let lastNameQuery = PFQuery(className:"Leads")
       // lastNameQuery.whereKey("LastName", matchesRegex: "(?i)\(searchController.searchBar.text)")
        
        let query = PFQuery.orQuery(withSubqueries: [firstNameQuery])
        
        query.findObjectsInBackground { (results:[PFObject]?, error:Error?) -> Void in
            
            if error != nil {
                
                let myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle:UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.present(myAlert, animated: true, completion: nil)
                
                return
            }
            
            if let objects = results {

                let temp: NSArray = objects as NSArray
                self.filteredString = temp.mutableCopy() as! NSMutableArray
                print(self.filteredString)
                self.tableView!.reloadData()
                }
        }
    }
    
    func parseData() {
        
        let query = PFQuery(className:"Employee")
        query.limit = 100
        query.order(byAscending: "createdAt")
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
        
        let query1 = PFQuery(className:"Employee")
        query1.whereKey("Active", equalTo:1)
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        //query1.orderByDescending("createdAt")
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
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == resultsController.tableView {
            //userDetails = foundUsers[indexPath.row]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        } else {
            self.performSegue(withIdentifier: "employdetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "employdetailSegue" {
            
            let formatter = NumberFormatter()
            
            let controller = segue.destination as? LeadDetail
            controller!.formController = "Employee"
            let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
            controller?.objectId = _feedItems[indexPath].value(forKey: "objectId") as? String
            
            var LeadNo:Int? = _feedItems[indexPath].value(forKey: "EmployeeNo") as? Int
            formatter.numberStyle = .none
            if LeadNo == nil {
                LeadNo = 0
            }
            controller?.leadNo =  formatter.string(from: LeadNo!)
            
            var Active:Int? = _feedItems[indexPath].value(forKey: "Active")as? Int
            if Active == nil {
                Active = 0
            }
            controller?.active = formatter.string(from: Active!)
            
            controller?.date = _feedItems[indexPath].value(forKey: "Email") as? String
            controller?.name = String(format: "%@ %@ %@", (_feedItems[indexPath].value(forKey: "First") as? String)!, (_feedItems[indexPath].value(forKey: "Last") as? String)!, (_feedItems[indexPath].value(forKey: "Company") as? String)!)
            controller?.address = _feedItems[indexPath].value(forKey: "Street") as? String
            controller?.city = _feedItems[indexPath].value(forKey: "City") as? String
            controller?.state = _feedItems[indexPath].value(forKey: "State") as? String
            controller?.zip = _feedItems[indexPath].value(forKey: "Zip") as? String
            controller?.amount = _feedItems[indexPath].value(forKey: "Title") as? String
            controller?.tbl11 = _feedItems[indexPath].value(forKey: "HomePhone") as? String
            controller?.tbl12 = _feedItems[indexPath].value(forKey: "WorkPhone") as? String
            controller?.tbl13 = _feedItems[indexPath].value(forKey: "CellPhone") as? String
            controller?.tbl14 = _feedItems[indexPath].value(forKey: "SS") as? String
            controller?.tbl15 = _feedItems[indexPath].value(forKey: "Middle") as? String
            controller?.tbl21 = _feedItems[indexPath].value(forKey: "Email") as? String
            controller?.tbl22 = _feedItems[indexPath].value(forKey: "Department") as? String
            controller?.tbl23 = _feedItems[indexPath].value(forKey: "Title") as? String
            controller?.tbl24 = _feedItems[indexPath].value(forKey: "Manager") as? String
            controller?.tbl25 = _feedItems[indexPath].value(forKey: "Country") as? String
        
            let dateUpdated = _feedItems[indexPath].value(forKey: "updatedAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller?.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            controller?.tbl26 = _feedItems[indexPath].value(forKey: "First") as? String
            controller?.tbl27 = _feedItems[indexPath].value(forKey: "Company") as? String
            controller?.custNo = _feedItems[indexPath].value(forKey: "Last") as? String
            controller?.comments = _feedItems[indexPath].value(forKey: "Comments") as? String
            controller?.l11 = "Home"; controller?.l12 = "Work"
            controller?.l13 = "Mobile"; controller?.l14 = "Social"
            controller?.l15 = "Middle"; controller?.l21 = "Email"
            controller?.l22 = "Department"; controller?.l23 = "Title"
            controller?.l24 = "Manager"; controller?.l25 = "Country"
            controller?.l16 = "Last Updated"; controller?.l26 = "First"
            controller?.l1datetext = "Email:"
            controller?.lnewsTitle = "Employee News: Health benifits cancelled immediately, ineffect starting today."
            
        }
        
        if segue.identifier == "newemploySegue" {
            let controller = segue.destination as? EditData
            controller!.formController = "Employee"
            controller!.status = "New"
        }
        
    }
    
}
//-----------------------end------------------------------