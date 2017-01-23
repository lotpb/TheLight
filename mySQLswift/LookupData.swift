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
    func cityFromController(_ passedData: String)
    func stateFromController(_ passedData: String)
    func zipFromController(_ passedData: String)
    func salesFromController(_ passedData: String)
    func salesNameFromController(_ passedData: String)
    func jobFromController(_ passedData: String)
    func jobNameFromController(_ passedData: String)
    func productFromController(_ passedData: String)
    func productNameFromController(_ passedData: String)
}

class LookupData: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate:LookupDataDelegate?
    
    @IBOutlet weak var tableView: UITableView?
 
    var zipArray : NSMutableArray = NSMutableArray()
    var salesArray : NSMutableArray = NSMutableArray()
    var jobArray : NSMutableArray = NSMutableArray()
    var adproductArray : NSMutableArray = NSMutableArray()
    var filteredString : NSMutableArray = NSMutableArray()
    
    var lookupItem : String?
    var isFilltered = false
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle(String(format: "%@ %@", "Lookup", (self.lookupItem)!), for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(LookupData.refreshData), for: .valueChanged)
        return refreshControl
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.barTintColor = Color.DGrayColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true, completion: nil)
        
        parseData()
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Color.DGrayColor
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
        self.tableView!.estimatedRowHeight = 44
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = Color.LGrayColor
        self.automaticallyAdjustsScrollViewInsets = false
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    // MARK: - Refresh
    
    func refreshData(sender:AnyObject) {
        parseData()
        self.refreshControl.endRefreshing()
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
            
            cell.textLabel!.font = Font.celltitle20l
            
        } else {
            
            cell.textLabel!.font = Font.celltitle20l
        }
        
        if (tableView == self.tableView) {
            
            if (lookupItem == "City") {
                cell.textLabel!.text = ((zipArray[indexPath.row] as AnyObject).value(forKey: "City") as? String)!
            } else if (lookupItem == "Salesman") {
                cell.textLabel!.text = ((salesArray[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String)!
            } else if (lookupItem == "Job") {
                cell.textLabel!.text = ((jobArray[indexPath.row] as AnyObject).value(forKey: "Description") as? String)!
            } else if (lookupItem == "Product") {
                cell.textLabel!.text = ((adproductArray[indexPath.row] as AnyObject).value(forKey: "Products") as? String)!
            } else if (lookupItem == "Advertiser") {
                cell.textLabel!.text = ((adproductArray[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String)!
            }
            
        } else {
            
            if (lookupItem == "City") {
                //cell.textLabel!.text = foundUsers[indexPath.row]
                cell.textLabel!.text = ((filteredString[indexPath.row] as AnyObject).value(forKey: "City") as? String)!
            } else if (lookupItem == "Salesman") {
                cell.textLabel!.text = ((filteredString[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String)!
            } else if (lookupItem == "Job") {
                cell.textLabel!.text = ((filteredString[indexPath.row] as AnyObject).value(forKey: "Description") as? String)!
            } else if (lookupItem == "Product") {
                cell.textLabel!.text = ((filteredString[indexPath.row] as AnyObject).value(forKey: "Products") as? String)!
            } else if (lookupItem == "Advertiser") {
                cell.textLabel!.text = ((filteredString[indexPath.row] as AnyObject).value(forKey: "Advertiser") as? String)!
            }
            
        }
        
        //cell.textLabel!.text = cityName

        return cell
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
                zipArray.object(at: indexPath.row)
            } else if (lookupItem == "Salesman") {
                salesArray.object(at: indexPath.row)
            } else if (lookupItem == "Job") {
                jobArray.object(at: indexPath.row)
            } else if (lookupItem == "Product") {
                adproductArray.object(at: indexPath.row)
            } else if (lookupItem == "Advertiser") {
                adproductArray.object(at: indexPath.row)
            }
        } else {
            filteredString.object(at: indexPath.row)
        }
        passDataBack()
    }
    
    func passDataBack() {
        
        let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
        if (!isFilltered) {
            if (lookupItem == "City") {
                self.delegate? .cityFromController(((zipArray.object(at: indexPath) as AnyObject).value(forKey: "City") as? String)!)
                self.delegate? .stateFromController(((zipArray[indexPath] as AnyObject).value(forKey: "State") as? String)!)
                self.delegate? .zipFromController(((zipArray[indexPath] as AnyObject).value(forKey: "zipCode") as? String)!)
                
            } else if (lookupItem == "Salesman") {
                self.delegate? .salesFromController(((salesArray.object(at: indexPath) as AnyObject).value(forKey: "SalesNo") as? String)!)
                self.delegate? .salesNameFromController(((salesArray[indexPath] as AnyObject).value(forKey: "Salesman") as? String)!)
                
            } else if (lookupItem == "Job") {
                self.delegate? .jobFromController(((jobArray[indexPath] as AnyObject).value(forKey: "JobNo") as? String)!)
                self.delegate? .jobNameFromController(((jobArray.object(at: indexPath) as AnyObject).value(forKey: "Description") as? String)!)
                
            } else if (lookupItem == "Product") {
                self.delegate? .productFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "ProductNo") as? String)!)
                self.delegate? .productNameFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "Products") as? String)!)
            } else {
                self.delegate? .productFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "AdNo") as? String)!)
                self.delegate? .productNameFromController(((adproductArray[indexPath] as AnyObject).value(forKey: "Advertiser") as? String)!)
            }
            
        } else {
            
            if (lookupItem == "City") {
                self.delegate? .cityFromController((((filteredString.object(at: indexPath) as! NSObject).value(forKey: "City") as? String)! as NSString) as String)
                self.delegate? .stateFromController((((filteredString[indexPath] as! NSObject).value(forKey: "State") as? String)! as NSString) as String)
                self.delegate? .zipFromController(((filteredString[indexPath] as! NSObject).value(forKey: "zipCode") as? String)!)
                
            } else if (lookupItem == "Salesman") {
                self.delegate? .salesFromController(((filteredString.object(at: indexPath) as AnyObject).value(forKey: "SalesNo") as? String)!)
                self.delegate? .salesNameFromController(((filteredString[indexPath] as AnyObject).value(forKey: "Salesman") as? String)!)
                
            } else if (lookupItem == "Job") {
                self.delegate? .jobFromController(((filteredString[indexPath] as AnyObject).value(forKey: "JobNo") as? String)!)
                self.delegate? .jobNameFromController(((filteredString.object(at: indexPath) as AnyObject).value(forKey: "Description") as? String)!)
                
            } else if (lookupItem == "Product") {
                self.delegate? .productFromController(((filteredString[indexPath] as AnyObject).value(forKey: "ProductNo") as? String)!)
                self.delegate? .productNameFromController(((filteredString[indexPath] as AnyObject).value(forKey: "Products") as? String)!)
            } else {
                self.delegate? .productFromController(((filteredString[indexPath] as AnyObject).value(forKey: "AdNo") as? String)!)
                self.delegate? .productNameFromController(((filteredString[indexPath] as AnyObject).value(forKey: "Advertiser") as? String)!)
            }
            
        }
        let _ = navigationController?.popViewController(animated: true)
    }
}
//-----------------------end------------------------------

extension LookupData: UISearchResultsUpdating {
    
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
}




