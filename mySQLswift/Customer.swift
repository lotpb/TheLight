//
//  Customer.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/13/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Customer: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    let searchScope = ["name","city","phone","date", "active"]
    
    @IBOutlet weak var tableView: UITableView?
    var _feedItems : NSMutableArray = NSMutableArray()
    var _feedheadItems : NSMutableArray = NSMutableArray()
    var filteredString : NSMutableArray = NSMutableArray()
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var users:[[String:AnyObject]]!
    var foundUsers:[String] = []

    var userDetails:[String:AnyObject]!
    
    var refreshControl:UIRefreshControl!
    
    var objectIdLabel = String()
    var titleLabel = String()
    var dateLabel = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("myCustomer", for: UIControlState())
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
        
        users = []
        foundUsers = []
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Customer.newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(Customer.searchButton))
        let buttons:NSArray = [addButton,searchButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]

        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Cust.navColor
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(Customer.refreshData), for: UIControlEvents.valueChanged)
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
        self.navigationController?.navigationBar.barTintColor = Color.Cust.navColor
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
        
        self.performSegue(withIdentifier: "newcustSegue", sender: self)
        
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

        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: tableView.frame.size.width - 105, y: 0, width: 95, height: 32))
        myLabel1.backgroundColor = Color.Cust.labelColor1
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
        
        cell.custsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.custtitleLabel!.font = Font.celltitle
            cell.custsubtitleLabel!.font = Font.cellsubtitle
            cell.custreplyLabel.font = Font.cellreply
            cell.custlikeLabel.font = Font.celllike
            myLabel1.font = Font.celllabel1
            myLabel2.font = Font.celllabel2
            
        } else {
            
            cell.custtitleLabel!.font = Font.celltitle
            cell.custsubtitleLabel!.font =  Font.cellsubtitle
            cell.custreplyLabel.font = Font.cellreply
            cell.custlikeLabel.font = Font.celllike
            myLabel1.font = Font.celllabel1
            myLabel2.font = Font.celllabel2
        }
        
        if (tableView == self.tableView) {
            
            cell.custtitleLabel!.text = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "LastName") as? String
            cell.custlikeLabel!.text = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "Rate") as? String
            myLabel1.text = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "Date") as? String
            
            var Amount:Int? = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "Amount")as? Int
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if Amount == nil {
                Amount = 0
            }
            myLabel2.text =  formatter.string(from: Amount!)
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                cell.custsubtitleLabel!.text = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "City") as? String
            } else {
                cell.custsubtitleLabel!.text = ""
            }
           
        } else {
            
            cell.custtitleLabel!.text = filteredString[(indexPath as NSIndexPath).row].value(forKey: "LastName") as? String
            cell.custsubtitleLabel!.text = filteredString[(indexPath as NSIndexPath).row].value(forKey: "City") as? String
            cell.custlikeLabel!.text = filteredString[(indexPath as NSIndexPath).row].value(forKey: "Rate") as? String
            myLabel1.text = filteredString[(indexPath as NSIndexPath).row].value(forKey: "Date") as? String
            myLabel2.text = filteredString[(indexPath as NSIndexPath).row].value(forKey: "Amount") as? String
            
        }
        
        cell.custreplyButton.tintColor = .lightGray
        let replyimage : UIImage? = UIImage(named:"Commentfilled.png")!.withRenderingMode(.alwaysTemplate)
        cell.custreplyButton .setImage(replyimage, for: UIControlState())
        
        if (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Comments") as? String == nil) || (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Comments") as? String == "") {
            cell.custreplyButton!.tintColor = .lightGray
        } else {
            cell.custreplyButton!.tintColor = Color.Cust.buttonColor
        }
        
        if (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Active") as? Int == 1 ) {
            cell.custreplyLabel.text! = "Active"
            cell.custreplyLabel.adjustsFontSizeToFitWidth = true
        } else {
            cell.custreplyLabel.text! = ""
        }
        
        cell.custlikeButton.tintColor = .lightGray
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        cell.custlikeButton .setImage(likeimage, for: UIControlState())

        if (_feedItems[(indexPath as NSIndexPath).row].value(forKey: "Rate") as? String == "A" ) {
            cell.custlikeButton!.tintColor = Color.Cust.buttonColor
        } else {
            cell.custlikeButton!.tintColor = .lightGray
        }
        
        let myLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        myLabel.backgroundColor = Color.Cust.labelColor
        myLabel.text = "Cust"
        myLabel.textColor = .white
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.contentsGravity = kCAGravityResize
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 25.0
        myLabel.font = Font.headtitle
        myLabel.isUserInteractionEnabled = true
        myLabel.tag = (indexPath as NSIndexPath).row
        cell.addSubview(myLabel)

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Customer.imgLoadSegue))
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
        vw.backgroundColor = Color.Cust.navColor
        //self.tableView!.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Cust\n", _feedItems.count)
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.isUserInteractionEnabled = true
        myLabel1.layer.borderColor = UIColor.lightGray.cgColor
        myLabel1.layer.borderWidth = 1
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = Color.Cust.buttonColor
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
        myLabel2.layer.borderColor = UIColor.lightGray.cgColor
        myLabel2.layer.borderWidth = 1
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: CGRect(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = Color.Cust.buttonColor
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
        myLabel3.layer.borderColor = UIColor.lightGray.cgColor
        myLabel3.layer.borderWidth = 1
        vw.addSubview(myLabel3)
        
        let separatorLineView3 = UIView(frame: CGRect(x: 150, y: 75, width: 50, height: 2.5))
        separatorLineView3.backgroundColor = Color.Cust.buttonColor
        vw.addSubview(separatorLineView3)
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let query = PFQuery(className:"Customer")
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
        UISearchBar.appearance().barTintColor = Color.Cust.navColor
        
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
        self.foundUsers.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[cd] %@", searchController.searchBar.text!)
        
        let array = (_feedItems as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.foundUsers = array as! [String]
        //print(self.foundUsers)
        dispatch_async(dispatch_get_main_queue()) {
            //self.resultsController.tableView.reloadData()
            self.searchController.resignFirstResponder()
        } */
    }
    
    // MARK: - Parse
    
    func parseData() {
        
        let query = PFQuery(className:"Customer")
        query.limit = 1000
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Customer")
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
        objectIdLabel = (_feedItems.object(at: (sender.view!.tag)).value(forKey: "objectId") as? String)!
        dateLabel = (_feedItems.object(at: (sender.view!.tag)).value(forKey: "Date") as? String)!
        titleLabel = (_feedItems.object(at: (sender.view!.tag)).value(forKey: "LastName") as? String)!
        self.performSegue(withIdentifier: "custuserSeque", sender: self)
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == resultsController.tableView {
            userDetails = filteredString[(indexPath as NSIndexPath).row] as! [String : AnyObject]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        } else {
            self.performSegue(withIdentifier: "custdetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "custdetailSegue" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let controller = segue.destination as? LeadDetail
            controller!.formController = "Customer"
            let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
            controller?.objectId = _feedItems[indexPath].value(forKey: "objectId") as? String
            
            var CustNo:Int? = _feedItems[indexPath].value(forKey: "CustNo") as? Int
            if CustNo == nil {
                CustNo = 0
            }
            controller?.custNo =  formatter.string(from: CustNo!)
            
            var LeadNo:Int? = _feedItems[indexPath].value(forKey: "LeadNo") as? Int
            if LeadNo == nil {
                LeadNo = 0
            }
            controller?.leadNo =  formatter.string(from: LeadNo!)
            
            var Zip:Int? = _feedItems[indexPath].value(forKey: "Zip")as? Int
            if Zip == nil {
                Zip = 0
            }
            controller?.zip =  formatter.string(from: Zip!)
            
            var Amount:Int? = _feedItems[indexPath].value(forKey: "Amount")as? Int
            if Amount == nil {
                Amount = 0
            }
            controller?.amount =  formatter.string(from: Amount!)
            
            var SalesNo:Int? = _feedItems[indexPath].value(forKey: "SalesNo")as? Int
            if SalesNo == nil {
                SalesNo = 0
            }
            controller?.tbl22 = formatter.string(from: SalesNo! as Int)
            
            var JobNo:Int? = _feedItems[indexPath].value(forKey: "JobNo")as? Int
            if JobNo == nil {
                JobNo = 0
            }
            controller?.tbl23 = formatter.string(from: JobNo!)
            
            var AdNo:Int? = _feedItems[indexPath].value(forKey: "ProductNo")as? Int
            if AdNo == nil {
                AdNo = 0
            }
            controller?.tbl24 = formatter.string(from: AdNo!)
            
            var Quan:Int? = _feedItems[indexPath].value(forKey: "Quan")as? Int
            if Quan == nil {
                Quan = 0
            }
            controller?.tbl25 = formatter.string(from: Quan!)
            
            var Active:Int? = _feedItems[indexPath].value(forKey: "Active")as? Int
            if Active == nil {
                Active = 0
            }
            controller?.active = formatter.string(from: Active!)
            
            controller?.date = _feedItems[indexPath].value(forKey: "Date") as? String
            controller?.name = _feedItems[indexPath].value(forKey: "LastName") as? String
            controller?.address = _feedItems[indexPath].value(forKey: "Address") as? String
            controller?.city = _feedItems[indexPath].value(forKey: "City") as? String
            controller?.state = _feedItems[indexPath].value(forKey: "State") as? String
            controller?.tbl11 = _feedItems[indexPath].value(forKey: "Contractor") as? String
            controller?.tbl12 = _feedItems[indexPath].value(forKey: "Phone") as? String
            controller?.tbl13 = _feedItems[indexPath].value(forKey: "First") as? String
            controller?.tbl14 = _feedItems[indexPath].value(forKey: "Spouse") as? String
            controller?.tbl15 = _feedItems[indexPath].value(forKey: "Email") as? String
            controller?.tbl21 = _feedItems[indexPath].value(forKey: "Start") as? String

            let dateUpdated = _feedItems[indexPath].value(forKey: "updatedAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller?.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            controller?.tbl26 = _feedItems[indexPath].value(forKey: "Rate") as? String
            controller?.complete = _feedItems[indexPath].value(forKey: "Completion") as? String
            controller?.photo = _feedItems[indexPath].value(forKey: "Photo") as? String
            controller?.comments = _feedItems[indexPath].value(forKey: "Comments") as? String
            
            controller?.l11 = "Contractor"; controller?.l12 = "Phone"
            controller?.l13 = "First"; controller?.l14 = "Spouse"
            controller?.l15 = "Email"; controller?.l21 = "Start date"
            controller?.l22 = "Salesman"; controller?.l23 = "Job"
            controller?.l24 = "Product"; controller?.l25 = "Quan"
            controller?.l16 = "Last Updated"; controller?.l26 = "Rate"
            controller?.l1datetext = "Sale Date:"
            controller?.lnewsTitle = Config.NewsCust
        }
        
        if segue.identifier == "custuserSeque" {
            let controller = segue.destination as? LeadUserController
            controller!.formController = "Customer"
            controller!.objectId = objectIdLabel
            controller!.postBy = titleLabel
            controller!.leadDate = dateLabel
        }
        
        if segue.identifier == "newcustSegue" {
            let controller = segue.destination as? EditData
            controller!.formController = "Customer"
            controller!.status = "New"
        }
        
    }
    
}
//-----------------------end------------------------------

