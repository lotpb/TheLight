 //
//  UserViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/17/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import Firebase
import MapKit
import CoreLocation

class UserViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainView: UIView!
    
    var defaults = UserDefaults.standard
    
    var formController: String?
    var isFormStat = false
    var selectedImage: UIImage?
    let cellId = "Cell"

    //parse
    var _feedItems = NSMutableArray()
    var filteredString = NSMutableArray()
    var user: PFUser?
    
    //firebase
    var userlist = [UserModel]()

    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight - Users", for: .normal)
        } else {
            button.setTitle("Users", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Cust.navColor
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
        loadData()
        self.navigationItem.titleView = self.titleButton
        self.mapView!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
        setupMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        navigationItem.rightBarButtonItems = [addButton, searchButton]
    }
    
    func setupMap() {
        
        mapView!.delegate = self
        mapView!.layer.borderColor = UIColor.lightGray.cgColor
        mapView!.layer.borderWidth = 0.5
        
        PFGeoPoint.geoPointForCurrentLocation {(geoPoint: PFGeoPoint?, error: Error?) in
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.40, 0.40)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(geoPoint!.latitude, geoPoint!.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            self.mapView!.setRegion(region, animated: true)
            self.mapView!.showsUserLocation = true //added
            self.refreshMap()
        }
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = .clear
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        self.collectionView.register(UserViewCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.collectionView!.backgroundColor = .white
    }
    
    // MARK: - Refresh
    
    func refreshData(_ sender:AnyObject) {
        loadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .lightGray
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.width-10, height: 20))
        myLabel1.numberOfLines = 1
        myLabel1.backgroundColor = .clear
        myLabel1.textColor = .white
        myLabel1.text = String(format: "%@%d", "Users ", _feedItems.count)
        myLabel1.font = Font.celltitle18m
        vw.addSubview(myLabel1)
        
        return vw
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
        
        return action == #selector(copy(_:))
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
    
    // MARK: - CollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            return self._feedItems.count
        } else {
            return self.userlist.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserViewCell
        
        if (defaults.bool(forKey: "parsedataKey")) {
            cell.usertitleLabel.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "username") as? String
            
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            cell.loadingSpinner.isHidden = true
            cell.loadingSpinner.startAnimating()
            
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.customImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.customImageView.image = UIImage(data: imageData!)
                }, completion: nil)
                
                cell.loadingSpinner.stopAnimating()
                cell.loadingSpinner.isHidden = true
            }
        } else {
            //firebase
            cell.user = userlist[indexPath.item]
        }
        
        return cell
    }
    
    // MARK: - RefreshMap
    
    func refreshMap() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
        let geoPoint = PFGeoPoint(latitude: self.mapView!.centerCoordinate.latitude, longitude:self.mapView!.centerCoordinate.longitude)
        
        let query = PFUser.query()
        query?.whereKey("currentLocation", nearGeoPoint: geoPoint, withinMiles:50.0)
        query?.limit = 20
        query?.findObjectsInBackground { (objects:[PFObject]?, error:Error?) in
            for object in objects! {
                let annotation = MKPointAnnotation()
                annotation.title = object["username"] as? String
                let geoPoint = object["currentLocation"] as! PFGeoPoint
                annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)
                self.mapView!.addAnnotation(annotation)
            }
        }
        } else {
            //firebase
        }
    }
    
    // MARK: - Parse
    
    func loadData() {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
            let query = PFUser.query()
            query!.order(byDescending: "createdAt")
            query!.cachePolicy = .cacheThenNetwork
            query!.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    self.collectionView!.reloadData()
                    self.tableView.reloadData()
                } else {
                    print("Crap Error")
                }
            }
        } else {
            
            //firebase
            /*
            let ref = FIRDatabase.database().reference().child("users")
            ref.observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let post = UserModel(uid: <#String#>, dictionary: dictionary)
                self.userlist.append(post)
                print(post)
                
                self.userlist.sort(by: { (u1, u2) -> Bool in
                    return u1.username.compare(u2.username) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }) { (err) in
                print("Failed to fetch users for search:", err)
            } */
        }
        //self.timer?.invalidate()
        //self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    /*
    var timer: Timer?
    
    func handleReloadTable() {
        DispatchQueue.main.async {
            self.collectionView!.reloadData()
            self.tableView.reloadData()
        }
    } */
    
    // MARK: - Button
    
    func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "userdetailSegue", sender: self)
    }
    
    // MARK: - Segues
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.formController = "CollectionView"
        isFormStat = false
        
        if (defaults.bool(forKey: "parsedataKey")) {
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            imageFile!.getDataInBackground { imageData, error in
                self.selectedImage = UIImage(data: imageData!)
                self.performSegue(withIdentifier: "userdetailSegue", sender: self.collectionView)
            }
        } else {
            //firebase
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "userdetailSegue" {
            let VC = segue.destination as? UserDetailController
            
            if self.formController == "TableView" {
                if (isFormStat == true) {
                    VC!.status = "New"
                } else {
                    VC!.status = "Edit"
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        let indexPath = (self.tableView!.indexPathForSelectedRow! as NSIndexPath).row
                        let updated:Date = ((self._feedItems[indexPath] as AnyObject).value(forKey: "createdAt") as? Date)!
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd, yyyy"
                        let createString = dateFormatter.string(from: updated)
                        
                        VC!.objectId = (self._feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                        VC!.username = (self._feedItems[indexPath] as AnyObject).value(forKey: "username") as? String
                        VC!.create = createString
                        VC!.email = (self._feedItems[indexPath] as AnyObject).value(forKey: "email") as? String
                        VC!.phone = (self._feedItems[indexPath] as AnyObject).value(forKey: "phone") as? String
                    } else {
                        //firebase
                    }
                    VC!.userimage = self.selectedImage
                }
                
            } else if self.formController == "CollectionView" {
                if (isFormStat == true) {
                    VC!.status = "New"
                } else {
                    VC!.status = "Edit"
                    let indexPaths = self.collectionView!.indexPathsForSelectedItems!
                    let indexPath = indexPaths[0] as IndexPath
                    
                    if (defaults.bool(forKey: "parsedataKey")) {
                        let updated:Date = ((self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "createdAt") as? Date)!
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd, yyyy"
                        let createString = dateFormatter.string(from: updated)
                        
                        VC!.objectId = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "objectId") as? String
                        VC!.username = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "username") as? String
                        VC!.create = createString
                        VC!.email = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "email") as? String
                        VC!.phone = (self._feedItems[(indexPath.row)] as AnyObject).value(forKey: "phone") as? String
                        VC!.userimage = self.selectedImage
                    } else {
                        //firebase
                    }
                }
            }
        }
    }
}
 extension UserViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (defaults.bool(forKey: "parsedataKey")) {
            return self._feedItems.count
        } else {
            return self.userlist.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell
        
        cell.selectionStyle = .none
        cell.usersubtitleLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.usertitleLabel!.font = Font.celltitle20r
            cell.usersubtitleLabel!.font = Font.celltitle16r
        } else {
            cell.usertitleLabel!.font = Font.celltitle16r
            cell.usersubtitleLabel!.font = Font.celltitle12r
        }
        
        if (defaults.bool(forKey: "parsedataKey")) {
            
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.userImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.userImageView.image = UIImage(data: imageData!)
                }, completion: nil)
            }
            
            let dateUpdated = (_feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as! Date
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "EEE, MMM d, h:mm a"
            
            cell.usertitleLabel!.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "username") as? String
            cell.usersubtitleLabel!.text = String(format: "%@", dateFormat.string(from: dateUpdated)) as String
            
        } else {
            //firebase
        }
        
        return cell
    }
 }
 
 extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.formController = "TableView"
        isFormStat = false
        if (defaults.bool(forKey: "parsedataKey")) {
            let imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            let imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                self.selectedImage = UIImage(data: imageData!)
                self.performSegue(withIdentifier: "userdetailSegue", sender: self.tableView)
            }
        } else {
            //firebase
        }
    }
 }
