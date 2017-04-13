//
//  Employee.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/24/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class Employee: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let searchScope = ["name","city","phone","active"]
    
    @IBOutlet weak var tableView: UITableView?

    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()

    var pasteBoard = UIPasteboard.general
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers = [String]()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Employee", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Employ.navColor
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
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(Employee.searchButton))
        navigationItem.rightBarButtonItems = [addButton,searchButton]

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

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.Employ.navColor
        }
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
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
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
        
        self.performSegue(withIdentifier: "newemploySegue", sender: self)
        
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
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableCell
        cell.selectionStyle = .none
        
        cell.employsubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.employtitleLabel!.font = Font.celltitle22m
            cell.employsubtitleLabel!.font = Font.celltitle16r

        } else {
            cell.employtitleLabel!.font = Font.celltitle20l
            cell.employsubtitleLabel!.font = Font.celltitle16r
        }
        
        if (tableView == self.tableView) {
            
            cell.employtitleLabel!.text = String(format: "%@ %@ %@", ((_feedItems[indexPath.row] as AnyObject).value(forKey: "First") as? String)!,
                ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!,
                ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
            cell.employsubtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Title") as? String
            
        } else {

            cell.employtitleLabel!.text = String(format: "%@ %@ %@", ((filteredString[indexPath.row] as AnyObject).value(forKey: "First") as? String)!, ((filteredString[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!, ((filteredString[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
            cell.employsubtitleLabel!.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "Title") as? String
        }
        
        cell.employreplyButton.tintColor = .lightGray
        cell.employreplyButton.setImage(#imageLiteral(resourceName: "Commentfilled").withRenderingMode(.alwaysTemplate), for: .normal)
        
        cell.employlikeButton.tintColor = .lightGray
        cell.employlikeButton.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        
        cell.employreplyLabel.text! = ""
        
        if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == nil) || ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Comments") as? String == "") {
            cell.employreplyButton!.tintColor = .lightGray
        } else {
            cell.employreplyButton!.tintColor = Color.Employ.buttonColor
        }
        
        if ((_feedItems[indexPath.row] as AnyObject).value(forKey: "Active") as? Int == 1 ) {
            cell.employlikeButton!.tintColor = Color.Employ.buttonColor
            cell.employlikeLabel.text! = "Active"
            cell.employlikeLabel.adjustsFontSizeToFitWidth = true
        } else {
            cell.employlikeButton!.tintColor = .lightGray
            cell.employlikeLabel.text! = ""
        }
        
        let imageLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        imageLabel.backgroundColor = Color.Employ.labelColor
        imageLabel.text = "Employ"
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
        myLabel1.textAlignment = .center
        myLabel1.text = String(format: "%@%d", "Employ\n", _feedItems.count)
        myLabel1.font = Font.celltitle14m
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.layer.borderColor = Color.Header.headtextColor.cgColor
        myLabel1.layer.borderWidth = 1
        myLabel1.layer.masksToBounds = true
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = Color.Employ.buttonColor
        vw.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: 80, y: 15, width: 50, height: 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = .center
        myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        myLabel2.font = Font.celltitle14m
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.layer.borderColor = Color.Header.headtextColor.cgColor
        myLabel2.layer.borderWidth = 1
        myLabel2.layer.masksToBounds = true
        myLabel2.isUserInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: CGRect(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = Color.Employ.buttonColor
        vw.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: CGRect(x: 150, y: 15, width: 50, height: 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = .black
        myLabel3.textAlignment = .center
        myLabel3.text = String(format: "%@%d", "Events\n", 3)
        myLabel3.font = Font.celltitle14m
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.layer.borderColor = Color.Header.headtextColor.cgColor
        myLabel3.layer.borderWidth = 1
        myLabel3.layer.masksToBounds = true
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
            
            let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
            
            let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
                
                let query = PFQuery(className:"Employee")
                query.whereKey("objectId", equalTo:((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!)
                query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
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
    
    func parseData() {
        
        let query = PFQuery(className:"Employee")
        query.limit = 100
        query.order(byAscending: "createdAt")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error7")
            }
        }
        
        let query1 = PFQuery(className:"Employee")
        query1.whereKey("Active", equalTo:1)
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        //query1.orderByDescending("createdAt")
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error8")
            }
        }
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == self.tableView) {
            self.performSegue(withIdentifier: "employdetailSegue", sender: self)
        } else {
            //if tableView == resultsController.tableView {
            //userDetails = filteredString[indexPath.row] as! [String : AnyObject]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "employdetailSegue" {
            
            let formatter = NumberFormatter()
            
            let controller = (segue.destination as! UINavigationController).topViewController as! LeadDetail
            
            controller.formController = "Employee"
            let indexPath = self.tableView!.indexPathForSelectedRow!.row
            controller.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
            
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            var LeadNo:Int? = (_feedItems[indexPath] as AnyObject).value(forKey: "EmployeeNo") as? Int
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
            
            controller.date = (_feedItems[indexPath] as AnyObject).value(forKey: "Email") as? String
            controller.name = String(format: "%@ %@ %@", ((_feedItems[indexPath] as AnyObject).value(forKey: "First") as? String)!, ((_feedItems[indexPath] as AnyObject).value(forKey: "Last") as? String)!, ((_feedItems[indexPath] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
            controller.address = (_feedItems[indexPath] as AnyObject).value(forKey: "Street") as? String
            controller.city = (_feedItems[indexPath] as AnyObject).value(forKey: "City") as? String
            controller.state = (_feedItems[indexPath] as AnyObject).value(forKey: "State") as? String
            controller.zip = (_feedItems[indexPath] as AnyObject).value(forKey: "Zip") as? String
            controller.amount = (_feedItems[indexPath] as AnyObject).value(forKey: "Title") as? String
            controller.tbl11 = (_feedItems[indexPath] as AnyObject).value(forKey: "HomePhone") as? String
            controller.tbl12 = (_feedItems[indexPath] as AnyObject).value(forKey: "WorkPhone") as? String
            controller.tbl13 = (_feedItems[indexPath] as AnyObject).value(forKey: "CellPhone") as? String
            controller.tbl14 = (_feedItems[indexPath] as AnyObject).value(forKey: "SS") as? String
            controller.tbl15 = (_feedItems[indexPath] as AnyObject).value(forKey: "Middle") as? NSString
            controller.tbl21 = (_feedItems[indexPath] as AnyObject).value(forKey: "Email") as? NSString
            controller.tbl22 = (_feedItems[indexPath] as AnyObject).value(forKey: "Department") as? String
            controller.tbl23 = (_feedItems[indexPath] as AnyObject).value(forKey: "Title") as? String
            controller.tbl24 = (_feedItems[indexPath] as AnyObject).value(forKey: "Manager") as? String
            controller.tbl25 = (_feedItems[indexPath] as AnyObject).value(forKey: "Country") as? String
        
            let dateUpdated = (_feedItems[indexPath] as AnyObject).value(forKey: "updatedAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd yy"
            controller.tbl16 = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
            controller.tbl26 = (_feedItems[indexPath] as AnyObject).value(forKey: "First") as? NSString
            controller.tbl27 = (_feedItems[indexPath] as AnyObject).value(forKey: "Company") as? String
            controller.custNo = (_feedItems[indexPath] as AnyObject).value(forKey: "Last") as? String
            controller.comments = (_feedItems[indexPath] as AnyObject).value(forKey: "Comments") as? String
            controller.l11 = "Home"; controller.l12 = "Work"
            controller.l13 = "Mobile"; controller.l14 = "Social"
            controller.l15 = "Middle"; controller.l21 = "Email"
            controller.l22 = "Department"; controller.l23 = "Title"
            controller.l24 = "Manager"; controller.l25 = "Country"
            controller.l16 = "Last Updated"; controller.l26 = "First"
            controller.l1datetext = "Email:"
            controller.lnewsTitle = "Employee News: Health benifits cancelled immediately, ineffect starting today."
            
        }
        
        if segue.identifier == "newemploySegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! EditData
            controller.formController = "Employee"
            controller.status = "New"
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension Employee: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = Color.Employ.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension Employee: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
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
        }
    }
}
