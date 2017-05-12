//
//  Lead.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Lead: UIViewController, UISplitViewControllerDelegate {
    
    let searchScope = ["name","city","phone","date","active"]
    
    @IBOutlet weak var tableView: UITableView?
    
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()
  
    var pasteBoard = UIPasteboard.general
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    var objectIdLabel = String()
    var titleLabel = String()
    var dateLabel = String()

    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Leads", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Lead.navColor
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        setupNavigationButtons()
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        //TabBar Hidden
        //self.tabBarController?.tabBar.isHidden = false
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        //self.tabBarController?.tabBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationButtons() {
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButton))
        navigationItem.rightBarButtonItems = [addBtn,searchBtn]
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.tableFooterView = UIView(frame: .zero)
        // MARK: - TableHeader
        self.tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        self.automaticallyAdjustsScrollViewInsets = false //fix
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    // MARK: - NavigationController/ TabBar Hidden
    /*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tabBarController?.hideTabBarAnimated(hide: true)
                UIApplication.shared.isStatusBarHidden = true
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tabBarController?.hideTabBarAnimated(hide: false)
                UIApplication.shared.isStatusBarHidden = false
            }, completion: nil)
        }
    } */
    
    // MARK: - Refresh
    
    func refreshData(_ sender:AnyObject) {
        parseData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    
    func newData() {
        
        self.performSegue(withIdentifier: "newleadSegue", sender: self)
    }
    
    // MARK: - TableView
    // MARK: Content Menu
    
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
        
        let query = PFQuery(className:"Leads")
        query.limit = 1000
        query.order(byDescending: "createdAt")
        query.cachePolicy = .cacheThenNetwork
        query.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error1")
            }
        }
        
        let query1 = PFQuery(className:"Leads")
        query1.whereKey("Active", equalTo:1)
        query1.cachePolicy = .cacheThenNetwork
        query1.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error2")
            }
        }
    }
    
    func deleteData(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            let query = PFQuery(className:"Leads")
            query.whereKey("objectId", equalTo: name)
            query.findObjectsInBackground(block: { objects, error in
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
    }
    
    // MARK: - imgLoadSegue
    
    func imgLoadSegue(_ sender:UITapGestureRecognizer) {
        objectIdLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "objectId") as? String)!
        dateLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "Date") as? String)!
        titleLabel = ((_feedItems.object(at: (sender.view!.tag)) as AnyObject).value(forKey: "LastName") as? String)!
        self.performSegue(withIdentifier: "leaduserSegue", sender: self)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "leaddetailSegue" {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadDetail

            controller.formController = "Leads"
            let indexPath = self.tableView!.indexPathForSelectedRow!.row
            controller.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String

            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            var LeadNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "LeadNo") as? Int
            if LeadNo == nil {
                LeadNo = 0
            }
            controller.leadNo = formatter.string(from: LeadNo! as NSNumber)

            var Zip:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Zip")as? Int
            if Zip == nil {
                Zip = 0
            }
            controller.zip = formatter.string(from: Zip! as NSNumber)
            
            var Amount:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Amount")as? Int
            if Amount == nil {
                Amount = 0
            }
            controller.amount = formatter.string(from: Amount! as NSNumber)
            
            var SalesNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "SalesNo")as? Int
            if SalesNo == nil {
                SalesNo = 0
            }
            controller.tbl22 = formatter.string(from: SalesNo! as NSNumber)
            
            var JobNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "JobNo")as? Int
            if JobNo == nil {
                JobNo = 0
            }
            controller.tbl23 = formatter.string(from: JobNo! as NSNumber)
            
            var AdNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "AdNo")as? Int
            if AdNo == nil {
                AdNo = 0
            }
            controller.tbl24 = formatter.string(from: AdNo! as NSNumber)
            
            var Active:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "Active")as? Int
            if Active == nil {
                Active = 0
            }
            controller.tbl25 = formatter.string(from: Active! as NSNumber)
            controller.tbl21 = (_feedItems[indexPath] as AnyObject).value(forKey: "AptDate") as? NSString
            
            let dateUpdated = (_feedItems[indexPath] as AnyObject).value(forKey: "updatedAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM d, yy"
            controller.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            controller.date = (_feedItems[indexPath] as AnyObject).value(forKey: "Date") as? String
            controller.name = (_feedItems[indexPath] as AnyObject).value(forKey: "LastName") as? String
            controller.address = (_feedItems[indexPath] as AnyObject).value(forKey: "Address") as? String
            controller.city = (_feedItems[indexPath] as AnyObject).value(forKey: "City") as? String
            controller.state = (_feedItems[indexPath] as AnyObject).value(forKey: "State") as? String
            controller.tbl11 = (_feedItems[indexPath] as AnyObject).value(forKey: "CallBack") as? String
            controller.tbl12 = (_feedItems[indexPath] as AnyObject).value(forKey: "Phone") as? String
            controller.tbl13 = (_feedItems[indexPath] as AnyObject).value(forKey: "First") as? String
            controller.tbl14 = (_feedItems[indexPath] as AnyObject).value(forKey: "Spouse") as? String
            controller.tbl15 = (_feedItems[indexPath] as AnyObject).value(forKey: "Email") as? NSString
            controller.tbl26 = (_feedItems[indexPath] as AnyObject).value(forKey: "Photo") as? NSString
            controller.comments = (_feedItems[indexPath] as AnyObject).value(forKey: "Coments") as? String
            controller.active = formatter.string(from: Active! as NSNumber)
            controller.l11 = "Call Back"; controller.l12 = "Phone"
            controller.l13 = "First"; controller.l14 = "Spouse"
            controller.l15 = "Email"; controller.l21 = "Apt Date"
            controller.l22 = "Salesman"; controller.l23 = "Job"
            controller.l24 = "Advertiser"; controller.l25 = "Active"
            controller.l16 = "Last Updated"; controller.l26 = "Photo"
            controller.l1datetext = "Lead Date:"
            controller.lnewsTitle = Config.NewsLead
        }
        
        if segue.identifier == "leaduserSegue" {
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadUserController
            
            controller.formController = "Leads"
            controller.objectId = objectIdLabel
            controller.postBy = titleLabel
            controller.leadDate = dateLabel
            
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
        if segue.identifier == "newleadSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! EditData
            controller.formController = "Leads"
            controller.status = "New"
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
}
//-----------------------end------------------------------
extension Lead: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return _feedItems.count
        } else {
            return foundUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableCell
        cell.selectionStyle = .none
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: tableView.frame.width - 105, y: 0, width: 95, height: 32))
        myLabel1.backgroundColor = Color.Lead.labelColor1
        myLabel1.textColor = .white
        myLabel1.textAlignment = .center
        myLabel1.font = Font.celltitle14m
        myLabel1.layer.masksToBounds = true
        cell.addSubview(myLabel1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: tableView.frame.width - 105, y: 33, width: 95, height: 33))
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = .center
        myLabel2.font = Font.celltitle14m
        myLabel2.layer.masksToBounds = true
        cell.addSubview(myLabel2)
        
        cell.leadsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            cell.leadtitleLabel!.font = Font.celltitle22m
            cell.leadsubtitleLabel!.font = Font.celltitle16r
            cell.leadreplyLabel.font = Font.celltitle16r
            cell.leadlikeLabel.font = Font.celltitle18m
            myLabel1.font = Font.celltitle16r
            myLabel2.font = Font.celltitle18m
            
        } else {
            
            cell.leadtitleLabel!.font = Font.celltitle20l
            cell.leadsubtitleLabel!.font = Font.celltitle16r
            cell.leadreplyLabel.font = Font.celltitle16r
            cell.leadlikeLabel.font = Font.celltitle18m
            myLabel1.font = Font.celltitle16r
            myLabel2.font = Font.celltitle18m
        }
        
        if (tableView == self.tableView) {
            
            cell.leadtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "LastName") as? String ?? ""
            cell.leadsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "City") as? String ?? ""
            myLabel1.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Date") as? String ?? ""
            myLabel2.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "CallBack") as? String ?? ""
            
        } else {
            
            cell.leadtitleLabel!.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "LastName") as? String
            cell.leadsubtitleLabel!.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "City") as? String
            myLabel1.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "Date") as? String
            myLabel2.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "CallBack") as? String
        }
        
        cell.leadreplyButton.tintColor = .lightGray
        cell.leadreplyButton.setImage(#imageLiteral(resourceName: "Commentfilled").withRenderingMode(.alwaysTemplate), for: .normal)
        
        cell.leadlikeButton.tintColor = .lightGray
        cell.leadlikeButton.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        
        cell.leadreplyLabel.text! = ""
        
        if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Coments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Coments") as? String == "") {
            cell.leadreplyButton!.tintColor = .lightGray
        } else {
            cell.leadreplyButton!.tintColor = Color.Lead.buttonColor
        }
        
        if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
            cell.leadlikeButton!.tintColor = Color.Lead.buttonColor
            cell.leadlikeLabel.text! = "Active"
            cell.leadlikeLabel.adjustsFontSizeToFitWidth = true
        } else {
            cell.leadlikeButton!.tintColor = .lightGray
            cell.leadlikeLabel.text! = ""
        }
        
        let imageLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        imageLabel.backgroundColor = Color.Cust.labelColor
        imageLabel.text = "Lead"
        imageLabel.textColor = .white
        imageLabel.textAlignment = .center
        imageLabel.font = Font.celltitle14m
        imageLabel.layer.cornerRadius = 25.0
        imageLabel.layer.masksToBounds = true
        imageLabel.isUserInteractionEnabled = true
        imageLabel.tag = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgLoadSegue))
        imageLabel.addGestureRecognizer(tap)
        cell.addSubview(imageLabel)
        
        return cell
    }
}

extension Lead: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.tableView) {
            self.performSegue(withIdentifier: "leaddetailSegue", sender: self)
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return 90.0
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }

        header.myLabel1.text = String(format: "%@%d", "Leads\n", _feedItems.count)
        header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
        header.separatorView1.backgroundColor = Color.Lead.buttonColor
        header.separatorView2.backgroundColor = Color.Lead.buttonColor
        header.separatorView3.backgroundColor = Color.Lead.buttonColor
        self.tableView!.tableHeaderView = nil //header.header
        
        return header
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
            
            self.deleteData(name: deleteStr)
            _feedItems.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
// MARK: - UISearchBar Delegate
extension Lead: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = Color.Lead.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension Lead: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
         let firstNameQuery = PFQuery(className:"Leads")
         firstNameQuery.whereKey("First", contains: searchController.searchBar.text)
         
         let lastNameQuery = PFQuery(className:"Leads")
         lastNameQuery.whereKey("LastName", matchesRegex: "(?i)\(String(describing: searchController.searchBar.text))")
         
         let query = PFQuery.orQuery(withSubqueries: [firstNameQuery, lastNameQuery])
         query.findObjectsInBackground { (results:[PFObject]?, error:Error?) in
         
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
         } */
    }
}

