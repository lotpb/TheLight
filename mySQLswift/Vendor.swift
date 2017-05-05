//
//  Vendor.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Vendor: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let searchScope = ["name","city","phone","department"]
    
    @IBOutlet weak var tableView: UITableView?
    
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()
 
    var pasteBoard = UIPasteboard.general
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Vendors", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Vend.navColor
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
        
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButton))
        navigationItem.rightBarButtonItems = [addBtn,searchBtn]

        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        // MARK: - TableHeader
        self.tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        self.automaticallyAdjustsScrollViewInsets = false //fix
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject) {
        parseData()
        self.refreshControl.endRefreshing()
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
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        }else{
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableCell
        cell.selectionStyle = .none
        
        cell.vendsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.vendtitleLabel!.font = Font.celltitle22m
            cell.vendsubtitleLabel!.font = Font.celltitle16r
            cell.vendlikeLabel.font = Font.celltitle20l

        } else {
            cell.vendtitleLabel!.font = Font.celltitle20l
            cell.vendsubtitleLabel!.font = Font.celltitle16r
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
        cell.vendreplyButton.setImage(#imageLiteral(resourceName: "Commentfilled").withRenderingMode(.alwaysTemplate), for: .normal)
        
        cell.vendlikeButton.tintColor = .lightGray
        cell.vendlikeButton.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        
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
        
        let imageLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        imageLabel.backgroundColor = Color.Vend.labelColor
        imageLabel.text = "Vendor"
        imageLabel.textColor = .white
        imageLabel.textAlignment = .center
        imageLabel.font = Font.celltitle14m
        imageLabel.layer.cornerRadius = 25.0
        imageLabel.layer.masksToBounds = true
        imageLabel.isUserInteractionEnabled = true
        cell.addSubview(imageLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return 90.0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
        //let vw = UIView()
        header.myLabel1.text = String(format: "%@%d", "Vendor\n", _feedItems.count)
        header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        header.myLabel3.text = String(format: "%@%d", "Events\n", 3)
        header.separatorView1.backgroundColor = Color.Vend.buttonColor
        header.separatorView2.backgroundColor = Color.Vend.buttonColor
        header.separatorView3.backgroundColor = Color.Vend.buttonColor
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
        query.cachePolicy = .cacheThenNetwork
        query.findObjectsInBackground { (objects, error)  in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
                
            } else {
                print("Error5")
            }
        }
        
        let query1 = PFQuery(className:"Vendors")
        query1.whereKey("Active", equalTo:1)
        query1.cachePolicy = .cacheThenNetwork
        //query1.order(byDescending: "createdAt")
        query1.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error6")
            }
        }
    }
    
    func deleteData(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            let query = PFQuery(className:"Vendors")
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

    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == self.tableView) {
            self.performSegue(withIdentifier: "vendordetailSegue", sender: self)
        } else {

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
            let controller = (segue.destination as! UINavigationController).topViewController as! EditData
            controller.formController = "Vendor"
            controller.status = "New"
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension Vendor: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = Color.Vend.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension Vendor: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
