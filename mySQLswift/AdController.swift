//
//  AdController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/8/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class AdController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let searchScope = ["advertiser","adNo","active"]
    
    @IBOutlet weak var tableView: UITableView?
   
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()

    var isFormStat = false
    var pasteBoard = UIPasteboard.general
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect.init(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Advertisers", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Table.navColor
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
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        setupNavigationButtons()
        loadData()
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = Color.Table.navColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
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
        self.tableView!.estimatedRowHeight = 65
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        // MARK: - TableHeader
        self.tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        self.automaticallyAdjustsScrollViewInsets = false //fix
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    // MARK: - Refresh
    
    func refreshData(_ sender: AnyObject) {
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    
    func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "adDetailSegue", sender: self)
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
        } else{
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableCell
        cell.selectionStyle = .none
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.adtitleLabel!.font = Font.celltitle22m
        } else {
            cell.adtitleLabel!.font = Font.celltitle20l
        }
        
        if (tableView == self.tableView) {
            
            cell.adtitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String
        } else {
            cell.adtitleLabel!.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String

        }
        
        let myLabel:UILabel = UILabel.init(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        myLabel.backgroundColor = Color.Table.labelColor
        myLabel.text = "Ad"
        myLabel.font = Font.celltitle14m
        myLabel.textColor = .white
        myLabel.textAlignment = .center
        myLabel.layer.cornerRadius = 20.0
        myLabel.layer.masksToBounds = true
        myLabel.isUserInteractionEnabled = true
        myLabel.tag = indexPath.row
        cell.addSubview(myLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return 90.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(section == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
            
            cell.header.backgroundColor = Color.Table.navColor
            cell.myLabel1.text = String(format: "%@%d", "Ad's\n", _feedItems.count)
            cell.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
            cell.myLabel3.text = String(format: "%@%d", "Active\n", 0)
            cell.separatorView1.backgroundColor = Color.Table.labelColor
            cell.separatorView2.backgroundColor = Color.Table.labelColor
            cell.separatorView3.backgroundColor = Color.Table.labelColor
            self.tableView!.tableHeaderView = nil //cell.header
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
        } else {
            cell.backgroundColor = UIColor.white
        }
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
    
    func loadData() {
        
        let query = PFQuery(className:"Advertising")
        //query.limit = 1000
        query.order(byAscending: "Advertiser")
        query.cachePolicy = .cacheThenNetwork
        query.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Advertising")
        query1.whereKey("Active", equalTo:"Active")
        query1.cachePolicy = .cacheThenNetwork
        query1.order(byDescending: "createdAt")
        query1.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    func deleteData(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            let query = PFQuery(className:"Advertising")
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
            isFormStat = false
            self.performSegue(withIdentifier: "adDetailSegue", sender: self)
        } else {
            //if tableView == resultsController.tableView {
            //userDetails = foundUsers[indexPath.row]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "adDetailSegue" {

            let VC = (segue.destination as! UINavigationController).topViewController as! NewEditData
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true

            VC.formController = "Advertisers"
            if (isFormStat == true) {
                VC.formStatus = "New"
            } else {
                VC.formStatus = "Edit"
                let myIndexPath = self.tableView!.indexPathForSelectedRow!.row
                VC.objectId = (_feedItems[myIndexPath] as AnyObject).value(forKey: "objectId") as? String
                VC.frm11 = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Active") as? String
                VC.frm12 = (_feedItems[myIndexPath] as AnyObject).value(forKey: "AdNo") as? String
                VC.frm13 = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Advertiser") as? String
            }
        }
    }
    
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension AdController: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = Color.Table.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension AdController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
