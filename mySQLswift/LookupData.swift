//
//  LookupData.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/10/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

protocol LookupDataDelegate: class {
    func cityFromController(_ passedData: NSString)
    func stateFromController(_ passedData: NSString)
    func zipFromController(_ passedData: NSString)
    func salesFromController(_ passedData: NSString)
    func salesNameFromController(_ passedData: NSString)
    func jobFromController(_ passedData: NSString)
    func jobNameFromController(_ passedData: NSString)
    func productFromController(_ passedData: NSString)
    func productNameFromController(_ passedData: NSString)
}

class LookupData: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    weak var delegate:LookupDataDelegate?
    
    @IBOutlet weak var tableView: UITableView?
 
    var zipArray : NSMutableArray = NSMutableArray()
    var salesArray : NSMutableArray = NSMutableArray()
    var jobArray : NSMutableArray = NSMutableArray()
    var adproductArray : NSMutableArray = NSMutableArray()
    var filteredString : NSMutableArray = NSMutableArray()
    
    var lookupItem : String?
    
    var refreshControl: UIRefreshControl!
    
    var isFilltered = false
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle(String(format: "%@ %@", "Lookup", (self.lookupItem)!), for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 44
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsBookmarkButton = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        //tableView!.tableHeaderView = searchController.searchBar
        tableView!.tableFooterView = UIView(frame: .zero)
        UISearchBar.appearance().barTintColor = Color.DGrayColor
        self.present(searchController, animated: true, completion: nil)
       
        //users = []
        //foundUsers = []
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self 
        
        parseData()
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(LookupData.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = Color.DGrayColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Refresh
    
    func refreshData(sender:AnyObject) {
        parseData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            
            if (lookupItem == "City") {
                return zipArray.count
            } else if (lookupItem == "Salesman") {
                return salesArray.count
            } else if (lookupItem == "Job") {
                return jobArray.count
            } else if (lookupItem == "Product") || (lookupItem == "Advertiser") {
                return adproductArray.count
            }
        } else {
            //return foundUsers.count
            return filteredString.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.textLabel!.font = Font.celltitle
            
        } else {
            
            cell.textLabel!.font = Font.celltitle
        }
        
        if (tableView == self.tableView) {
            
            if (lookupItem == "City") {
                cell.textLabel!.text = (zipArray[(indexPath as NSIndexPath).row].value(forKey: "City") as? String)!
            } else if (lookupItem == "Salesman") {
                cell.textLabel!.text = (salesArray[(indexPath as NSIndexPath).row].value(forKey: "Salesman") as? String)!
            } else if (lookupItem == "Job") {
                cell.textLabel!.text = (jobArray[(indexPath as NSIndexPath).row].value(forKey: "Description") as? String)!
            } else if (lookupItem == "Product") {
                cell.textLabel!.text = (adproductArray[(indexPath as NSIndexPath).row].value(forKey: "Products") as? String)!
            } else if (lookupItem == "Advertiser") {
                cell.textLabel!.text = (adproductArray[(indexPath as NSIndexPath).row].value(forKey: "Advertiser") as? String)!
            }
            
        } else {
            
            if (lookupItem == "City") {
                //cell.textLabel!.text = foundUsers[indexPath.row]
                cell.textLabel!.text = (filteredString[(indexPath as NSIndexPath).row].value(forKey: "City") as? String)!
            } else if (lookupItem == "Salesman") {
                cell.textLabel!.text = (filteredString[(indexPath as NSIndexPath).row].value(forKey: "Salesman") as? String)!
            } else if (lookupItem == "Job") {
                cell.textLabel!.text = (filteredString[(indexPath as NSIndexPath).row].value(forKey: "Description") as? String)!
            } else if (lookupItem == "Product") {
                cell.textLabel!.text = (filteredString[(indexPath as NSIndexPath).row].value(forKey: "Products") as? String)!
            } else if (lookupItem == "Advertiser") {
                cell.textLabel!.text = (filteredString[(indexPath as NSIndexPath).row].value(forKey: "Advertiser") as? String)!
            }
            
        }
        
        //cell.textLabel!.text = cityName

        return cell
    }
    
    // MARK: - Search
    
    func filterContentForSearchText(_ searchText: String) {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredString = zipArray.filter({ (str.objectForKey("City")) -> Bool in
            let countryText: NSString = country
            
            return (countryText.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        self.resultsController.tableView.reloadData() */

    }
    
    // MARK: - Parse
    
    func parseData() {
        
        let query = PFQuery(className:"Zip")
        query.limit = 1000
        query.order(byAscending: "City")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self.zipArray = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Salesman")
        query1.limit = 1000
        query1.order(byAscending: "Salesman")
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self.salesArray = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query2 = PFQuery(className:"Job")
        query2.limit = 1000
        query2.order(byAscending: "Description")
        query2.cachePolicy = PFCachePolicy.cacheThenNetwork
        query2.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self.jobArray = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        if (lookupItem == "Product") {
            
            let query3 = PFQuery(className:"Product")
            query3.limit = 1000
            query3.order(byDescending: "Products")
            query3.cachePolicy = PFCachePolicy.cacheThenNetwork
            query3.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self.adproductArray = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
            
        } else {
            let query4 = PFQuery(className:"Advertising")
            query4.limit = 1000
            query4.order(byDescending: "Advertiser")
            query4.cachePolicy = PFCachePolicy.cacheThenNetwork
            query4.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self.adproductArray = temp.mutableCopy() as! NSMutableArray
                    self.tableView!.reloadData()
                } else {
                    print("Error")
                }
            }
        }
        
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (!isFilltered) {
            if (lookupItem == "City") {
                zipArray.object(at: (indexPath as NSIndexPath).row)
            } else if (lookupItem == "Salesman") {
                salesArray.object(at: (indexPath as NSIndexPath).row)
            } else if (lookupItem == "Job") {
                jobArray.object(at: (indexPath as NSIndexPath).row)
            } else if (lookupItem == "Product") {
                adproductArray.object(at: (indexPath as NSIndexPath).row)
            } else if (lookupItem == "Advertiser") {
                adproductArray.object(at: (indexPath as NSIndexPath).row)
            }
        } else {
            filteredString.object(at: (indexPath as NSIndexPath).row)
        }
        passDataBack()
    }
    
    func passDataBack() {
        
        let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
        if (!isFilltered) {
            if (lookupItem == "City") {
                self.delegate? .cityFromController((zipArray.object(at: indexPath).value(forKey: "City") as? String)!)
                self.delegate? .stateFromController((zipArray[indexPath].value(forKey: "State") as? String)!)
                self.delegate? .zipFromController((zipArray[indexPath].value(forKey: "zipCode") as? String)!)
                
            } else if (lookupItem == "Salesman") {
                self.delegate? .salesFromController((salesArray.object(at: indexPath).value(forKey: "SalesNo") as? String)!)
                self.delegate? .salesNameFromController((salesArray[indexPath].value(forKey: "Salesman") as? String)!)
                
            } else if (lookupItem == "Job") {
                self.delegate? .jobFromController((jobArray[indexPath].value(forKey: "JobNo") as? String)!)
                self.delegate? .jobNameFromController((jobArray.object(at: indexPath).value(forKey: "Description") as? String)!)
                
            } else if (lookupItem == "Product") {
                self.delegate? .productFromController((adproductArray[indexPath].value(forKey: "ProductNo") as? String)!)
                self.delegate? .productNameFromController((adproductArray[indexPath].value(forKey: "Products") as? String)!)
            } else {
                self.delegate? .productFromController((adproductArray[indexPath].value(forKey: "AdNo") as? String)!)
                self.delegate? .productNameFromController((adproductArray[indexPath].value(forKey: "Advertiser") as? String)!)
            }
            
        } else {
            
            if (lookupItem == "City") {
                self.delegate? .cityFromController((filteredString.object(at: indexPath).value(forKey: "City") as? String)!)
                self.delegate? .stateFromController((filteredString[indexPath].value(forKey: "State") as? String)!)
                self.delegate? .zipFromController((filteredString[indexPath].value(forKey: "zipCode") as? String)!)
                
            } else if (lookupItem == "Salesman") {
                self.delegate? .salesFromController((filteredString.object(at: indexPath).value(forKey: "SalesNo") as? String)!)
                self.delegate? .salesNameFromController((filteredString[indexPath].value(forKey: "Salesman") as? String)!)
                
            } else if (lookupItem == "Job") {
                self.delegate? .jobFromController((filteredString[indexPath].value(forKey: "JobNo") as? String)!)
                self.delegate? .jobNameFromController((filteredString.object(at: indexPath).value(forKey: "Description") as? String)!)
                
            } else if (lookupItem == "Product") {
                self.delegate? .productFromController((filteredString[indexPath].value(forKey: "ProductNo") as? String)!)
                self.delegate? .productNameFromController((filteredString[indexPath].value(forKey: "Products") as? String)!)
            } else {
                self.delegate? .productFromController((filteredString[indexPath].value(forKey: "AdNo") as? String)!)
                self.delegate? .productNameFromController((filteredString[indexPath].value(forKey: "Advertiser") as? String)!)
            }
            
        }
        let _ = navigationController?.popViewController(animated: true)
    }
    
    
}
//-----------------------end------------------------------



