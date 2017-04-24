//
//  NewEditData.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/9/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class NewEditData: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    var formController : String?
    var formStatus : String?
    
    var objectId : String?
    var active : String?
    var frm11 : String?
    var frm12 : String?
    var frm13 : String?
    var frm14 : Int?
    
    var salesNo : UITextField!
    var salesman : UITextField!
    var textframe: UITextField!
    var price: UITextField!
    
    var image : UIImage!
    
    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            button.setTitle(String(format: "%@", "TheLight Software - \(self.formStatus!) \(self.formController!)"), for: .normal)
        } else {
            button.setTitle(String(format: "%@ %@", self.formStatus!, self.formController!), for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let activeImage: CustomImageView = { //tableheader
        let imageView = CustomImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateData))
        navigationItem.rightBarButtonItems = [saveButton]

        if formStatus == "New" {
            self.frm11 = "Active"
        }
        
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.Table.labelColor
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
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = .white
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    // MARK: - Refresh
    
    func refreshData(_ sender:AnyObject) {
        self.tableView!.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (formController == "Product") {
            return 5
        } else if (formController == "Salesman") {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (formController == "Product"), (indexPath.row == 4) {
            return 200
        } else if (formController == "Salesman"), (indexPath.row == 3) {
            return 200
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier: String = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        cell.selectionStyle = .none
        
        textframe = UITextField(frame:CGRect(x: 130, y: 7, width: 175, height: 30))
        activeImage.frame = CGRect(x: 130, y: 10, width: 18, height: 22)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.textLabel!.font = Font.Stat.celltitlePad
            self.salesman?.font = Font.Stat.celltitlePad
            self.salesNo?.font = Font.Stat.celltitlePad
            self.price?.font = Font.Stat.celltitlePad
        } else {
            cell.textLabel!.font = Font.celltitle20l
            self.salesman?.font = Font.celltitle20l
            self.salesNo?.font = Font.celltitle20l
            self.price?.font = Font.celltitle20l
        }
        
        if (indexPath.row == 0) {
            
            let theSwitch = UISwitch(frame:CGRect.zero)
            theSwitch.addTarget(self, action: #selector(NewEditData.changeSwitch), for: .valueChanged)
            theSwitch.onTintColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
            theSwitch.tintColor = .lightGray
            
            if self.frm11 == "Active" {
                theSwitch.isOn = true
                self.active = (self.frm11)!
                self.activeImage.image = #imageLiteral(resourceName: "iosStar")
                cell.textLabel!.text = "Active"
            } else {
                theSwitch.isOn = false
                self.active = ""
                self.activeImage.image = #imageLiteral(resourceName: "iosStarNA")
                cell.textLabel!.text = "Inactive"
            }
            
            cell.addSubview(theSwitch)
            cell.accessoryView = theSwitch
            cell.contentView.addSubview(activeImage)
            
        } else if (indexPath.row == 1) {
            
            self.salesman = textframe
            self.salesman!.adjustsFontSizeToFitWidth = true
            
            if self.frm13 == nil {
                
                self.salesman!.text = ""
                
            } else {
                
                self.salesman!.text = self.frm13
            }
            
            if (formController == "Salesman") {
                self.salesman.placeholder = "Salesman"
                cell.textLabel!.text = "Salesman"
            }
                
            else if (formController == "Product") {
                self.salesman.placeholder = "Product"
                cell.textLabel!.text = "Product"
            }
                
            else if (formController == "Advertising") {
                self.salesman.placeholder = "Advertiser"
                cell.textLabel!.text = "Advertiser"
            }
                
            else if (formController == "Jobs") {
                self.salesman.placeholder = "Description"
                cell.textLabel!.text = "Description"
            }
            
            cell.contentView.addSubview(self.salesman!)
            
        } else if (indexPath.row == 2) {
            
            self.salesNo = textframe
            
            if self.frm12 == nil {
                self.salesNo?.text = ""
            } else {
                self.salesNo?.text = self.frm12
            }
            
            if (formController == "Salesman") {
                self.salesNo.placeholder = "SalesNo"
                cell.textLabel!.text = "SalesNo"
            }
                
            else if (formController == "Product") {
                self.salesNo.placeholder = "ProductNo"
                cell.textLabel!.text = "ProductNo"
            }
                
            else if (formController == "Advertising") {
                self.salesNo?.placeholder = "AdNo"
                cell.textLabel!.text = "AdNo"
            }
                
            else if (formController == "Jobs") {
                self.salesNo.placeholder = "JobNo"
                cell.textLabel!.text = "JobNo"
            }
            
            cell.contentView.addSubview(self.salesNo)
            
        } else if (indexPath.row == 3) {
            self.price = textframe
            self.price!.adjustsFontSizeToFitWidth = true
            
            if (formController == "Salesman") {
                cell.textLabel!.text = ""
                cell.imageView!.image = self.image
            }
                
            else if (formController == "Product") {
                self.price.placeholder = "Price"
                cell.textLabel!.text = "Price"

                if self.frm14 == nil {
                    self.price!.text = "None"
                } else {
                    var Price:Int? = self.frm14! as Int
                    if Price == nil {
                        Price = 0
                    }
                    self.price!.text = "\(Price!)"
                }
                
                cell.contentView.addSubview(self.price)
            }
        } else if (indexPath.row == 4) {
            
            if (formController == "Product") {
                //if self.image == nil {
                    //indexPath.row == 4
                    //cell.textLabel!.text = "Photo"
                    //cell.imageView!.image = self.image
                //} else {
                    cell.textLabel!.text = "Photo"
                    cell.imageView!.image = self.image
                //}
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
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
    
    
    // MARK: - Switch
    
    func changeSwitch(_ sender: UISwitch) {
        
        if (sender.isOn) {
            self.frm11 = "Active"
        } else {
            self.frm11 = ""
        }
        self.tableView!.reloadData()
        
    }
    
    // MARK: - Update Data
    
    func updateData() {
        
        guard let textSales = self.salesman.text else { return }
        
        if textSales == "" {
            
            self.simpleAlert(title: "Oops!", message: "No text entered.")
            
        } else {
            
            if (self.formController == "Salesman") {
                
                if (self.formStatus == "Edit") { //Edit Salesman
                    
                    let query = PFQuery(className:"Salesman")
                    query.whereKey("objectId", equalTo:self.objectId!)
                    query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                        if error == nil {
                            updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"SalesNo")
                            updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Salesman")
                            updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                            updateblog!.saveEventually()
                            self.tableView!.reloadData()
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                    
                } else { //Save Salesman
                    
                    let saveblog:PFObject = PFObject(className:"Salesman")
                    saveblog.setObject("-1" , forKey:"SalesNo")
                    saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Salesman")
                    saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                    //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                    saveblog.saveInBackground { (success: Bool, error: Error?) in
                        if success == true {
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                }
                
            } else  if (formController == "Jobs") {
                
                if (self.formStatus == "Edit") { //Edit Job
                    
                    let query = PFQuery(className:"Job")
                    query.whereKey("objectId", equalTo:self.objectId!)
                    query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                        if error == nil {
                            updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"JobNo")
                            updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Description")
                            updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                            updateblog!.saveEventually()
                            self.tableView!.reloadData()
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                    
                } else { //Save Job
                    
                    let saveblog:PFObject = PFObject(className:"Job")
                    
                    saveblog.setObject("-1" , forKey:"JobNo")
                    saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Description")
                    saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                    //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                    saveblog.saveInBackground { (success: Bool, error: Error?) in
                        if success == true {
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                }
                
            } else  if (self.formController == "Product") {
                
                let numberFormatter = NumberFormatter()
                let myPrice : NSNumber = numberFormatter.number(from: self.price.text!)!
                
                if (self.formStatus == "Edit") { //Edit Products
                    
                    let query = PFQuery(className:"Product")
                    query.whereKey("objectId", equalTo:self.objectId!)
                    query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                        if error == nil {
                            updateblog!.setObject(myPrice , forKey:"Price")
                            updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"ProductNo")
                            updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Products")
                            updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                            updateblog!.saveEventually()
                            self.tableView!.reloadData()
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                    
                } else { //Save Products
                    
                    let saveblog:PFObject = PFObject(className:"Product")
                    saveblog.setObject(myPrice , forKey:"Price")
                    saveblog.setObject("-1" , forKey:"ProductNo")
                    saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Products")
                    saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                    //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                    saveblog.saveInBackground { (success: Bool, error: Error?) in
                        if success == true {
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                }
                
            } else if (self.formController == "Advertising") {
                
                if (self.formStatus == "Edit") { //Edit Advertising
                    
                    let query = PFQuery(className:"Advertising")
                    query.whereKey("objectId", equalTo:self.objectId!)
                    query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) in
                        if error == nil {
                            updateblog!.setObject(self.salesNo.text ?? NSNull(), forKey:"AdNo")
                            updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Advertiser")
                            updateblog!.setObject(self.active ?? NSNull(), forKey:"Active")
                            updateblog!.saveEventually()
                            self.tableView!.reloadData()
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                    
                } else { //Save Advertising
                    
                    let saveblog:PFObject = PFObject(className:"Advertising")
                    saveblog.setObject("-1" , forKey:"AdNo")
                    saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"Advertiser")
                    saveblog.setObject(self.active ?? NSNull(), forKey:"Active")
                    //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                    saveblog.saveInBackground { (success: Bool, error: Error?) in
                        if success == true {
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        }
                    }
                }
                
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeId")
            self.show(vc!, sender: self)
            //self.present(vc!, animated: true)
        }
    }
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension NewEditData: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["name", "city", "phone", "date", "active"]
        //searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = .brown
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension NewEditData: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
         self.foundUsers.removeAll(keepCapacity: false)
         let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
         let array = (self._feedItems as NSArray).filteredArrayUsingPredicate(searchPredicate)
         self.foundUsers = array as! [String]
         self.resultsController.tableView.reloadData() */
    }
}
