//
//  SalesmanController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/8/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class SalesmanController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView?
    //@IBOutlet weak var collectionView: UICollectionView!
    //let cellId = "cellId"
    //let titles = ["Home", "Trending", "Subscriptions", "Account"]
    let searchScope = ["salesman","salesNo","active"]
    var isFormStat = false
    var selectedImage: UIImage?
    
    var _feedItems = NSMutableArray()
    var _feedheadItems = NSMutableArray()
    var filteredString = NSMutableArray()
    
    var pasteBoard = UIPasteboard.general
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    var userProfileImageView: CustomImageView = {
        var imageView = CustomImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Salesman", for: .normal)
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
        setupNavigationButtons()
        loadData()
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = Color.Table.navColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(SalesmanController.searchButton))
        navigationItem.rightBarButtonItems = [addButton,searchButton]
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 65
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = Color.LGrayColor
        // MARK: - TableHeader
        self.tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        self.automaticallyAdjustsScrollViewInsets = false //fix
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }

    // MARK: - Refresh
    
    func refreshData(_ sender:AnyObject) {
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    
    func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "salesDetailSegue", sender: self)
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
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableCell
        cell.selectionStyle = .none

        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.salestitleLabel!.font = Font.celltitle22m
        } else {
            cell.salestitleLabel!.font = Font.celltitle20l
        }
        
        /*
         let myLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
         myLabel.backgroundColor = Color.Table.labelColor
         myLabel.textColor = .white
         myLabel.textAlignment = .center
         myLabel.layer.masksToBounds = true
         myLabel.text = "Sale"
         myLabel.font = Font.headtitle
         myLabel.layer.cornerRadius = 20.0
         myLabel.isUserInteractionEnabled = true
         myLabel.tag = indexPath.row
         cell.addSubview(myLabel) */
        
        if (tableView == self.tableView) {
 
            cell.salestitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
            
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: (self.userProfileImageView), duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.userProfileImageView.image = UIImage(data: imageData!) ?? UIImage(named: "profile-rabbit-toy")
                }, completion: nil)
                
            }
            self.userProfileImageView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
            cell.addSubview(userProfileImageView)
        } else {
            cell.salestitleLabel!.text = (filteredString[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
        }
        
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
        
        guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
        
        header.header.backgroundColor = Color.Table.navColor
        header.myLabel1.text = String(format: "%@%d", "Sale's\n", _feedItems.count)
        header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
        header.myLabel3.text = String(format: "%@%d", "Active\n", 0)
        header.separatorView1.backgroundColor = Color.Table.labelColor
        header.separatorView2.backgroundColor = Color.Table.labelColor
        header.separatorView3.backgroundColor = Color.Table.labelColor
        self.tableView!.tableHeaderView = nil //header.header
        return header
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
        
        return action == #selector(copy(_:))
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
    
    // MARK: - Parse
    
    func loadData() {
        
        let query = PFQuery(className:"Salesman")
        //query.limit = 1000
        query.order(byAscending: "Salesman")
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
        
        let query1 = PFQuery(className:"Salesman")
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
            
            let query = PFQuery(className:"Salesman")
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
        
        self.selectedImage = nil
        if (tableView == self.tableView) {
            isFormStat = false
            let imageObject = _feedItems.object(at: indexPath.row) as? PFObject
            if let imageFile = imageObject!.object(forKey: "imageFile") as? PFFile {
                imageFile.getDataInBackground { imageData, error in
                    self.selectedImage = UIImage(data: imageData!)
                    self.performSegue(withIdentifier: "salesDetailSegue", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "salesDetailSegue", sender: self)
            }
        } else {
            //if tableView == resultsController.tableView {
            //userDetails = foundUsers[indexPath.row]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "salesDetailSegue" {
            
            let VC = (segue.destination as! UINavigationController).topViewController as! NewEditData
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
            
            VC.formController = "Salesman"
            if (isFormStat == true) {
                VC.formStatus = "New"
            } else {
                VC.formStatus = "Edit"
                let myIndexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
                VC.objectId = (_feedItems[myIndexPath] as AnyObject).value(forKey: "objectId") as? String
                VC.frm11 = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Active") as? String
                VC.frm12 = (_feedItems[myIndexPath] as AnyObject).value(forKey: "SalesNo") as? String
                VC.frm13 = (_feedItems[myIndexPath] as AnyObject).value(forKey: "Salesman") as? String
                VC.image = self.selectedImage
            }
        }
    }
    
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension SalesmanController: UISearchBarDelegate {
    
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

extension SalesmanController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
