//
//  SnapshotController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/21/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import EventKit
import MobileCoreServices
import AVFoundation

class SnapshotController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tableView: UITableView!
    
    var _feedItems = NSMutableArray() //news
    var _feedItems2 = NSMutableArray() //job
    var _feedItems3 = NSMutableArray() //user
    var _feedItems4 = NSMutableArray() //salesman
    var _feedItems5 = NSMutableArray() //employee
    var _feedItems6 = NSMutableArray() //blog
    var filteredString = NSMutableArray()
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    var selectedImage : UIImage!

    var selectedObjectId : String!
    var selectedTitle : String!
    var selectedName : String!
    var selectedCreate : String!
    var selectedEmail : String!
    var selectedPhone : String!
    var selectedDate : Date!
    
    var selectedState : String!
    var selectedZip : String!
    var selectedAmount : String!
    var selectedComments : String!
    var selectedActive : String!

    var selected11 : String!
    var selected12 : String!
    var selected13 : String!
    var selected14 : String!
    var selected15 : NSString!
    var selected16 : String!
    var selected21 : NSString!
    var selected22 : String!
    var selected23 : String!
    var selected24 : String!
    var selected25 : String!
    var selected26 : NSString!
    var selected27 : String!
    
    var resultDateDiff : String!
    var imageDetailurl : String?
    
    var maintitle : UILabel!
    var datetitle : UILabel!
    var myLabel1 : UILabel!
    
    var imageObject :PFObject!
    var imageFile :PFFile!
    
    var calendars: [EKCalendar]?
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight Software - Snapshot", for: .normal)
        } else {
            button.setTitle("Snapshot", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
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
        
        // MARK: - SplitView

        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar'
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        parseData()
        setupTableView()
        setupNavBarButtons()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
        loadCalendars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.Snap.tablebackColor
        self.tableView!.separatorColor = Color.Snap.lineColor //.clear
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    func setupNavBarButtons() {
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButton))
        navigationItem.rightBarButtonItems = [searchBtn]
    }
    
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject) {
        parseData()
        self.refreshControl.endRefreshing()
    }
    

    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let result:CGFloat = 140
        if (indexPath.section == 0) {
            
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            case 1:
                if UI_USER_INTERFACE_IDIOM() == .pad {
                    return 190
                } else {
                    return 140
                }
            case 2:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 1) {
            let result:CGFloat = 100
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 2) {
            let result:CGFloat = 100
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 3) {
            
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            case 2:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 4) {
            
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 5) {
            
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 6) {
    
            switch (indexPath.row % 4)
            {
            case 0:
            return 44
            default:
            return result
            }
        } else if (indexPath.section == 7) {
            let result:CGFloat = 110
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if (indexPath.section == 8) {
            let result:CGFloat = 110
            switch (indexPath.row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if (section == 0) {
                return 3
            } else if (section == 3) {
                return 3
            }
            return 2
        }
        return foundUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return CGFloat.leastNormalMagnitude
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableCell
        
        cell.collectionView.delegate =  nil
        cell.collectionView.dataSource = nil
        cell.collectionView.backgroundColor = Color.Snap.collectbackColor
        
        cell.backgroundColor = Color.Snap.collectbackColor
        cell.accessoryType = .none
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.textLabel!.font = Font.Snapshot.celltitlePad
            cell.snaptitleLabel.font = Font.Snapshot.cellsubtitlePad
            cell.snapdetailLabel.font = Font.Snapshot.cellsubtitlePad
            
        } else {
            cell.textLabel!.font = Font.celltitle20l
            cell.snaptitleLabel.font = Font.celltitle16r
            cell.snapdetailLabel.font = Font.celltitle16r
        }
        
        cell.textLabel!.textColor = Color.Snap.textColor
        cell.snaptitleLabel?.textColor = Color.Snap.textColor1
        cell.snapdetailLabel?.textColor = Color.Snap.textColor
        
        cell.textLabel?.text = ""
        cell.snaptitleLabel?.text = ""
        cell.snapdetailLabel?.text = ""
        
        cell.snaptitleLabel?.numberOfLines = 1
        cell.snapdetailLabel?.numberOfLines = 3
        
        let date2 = Date()
        let calendar = Calendar.current
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                
                cell.accessoryType = .disclosureIndicator
                cell.textLabel!.text = String(format: "%@%d", "Top News ", _feedItems.count)
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.tag = 0
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.font = Font.Snapshot.celllabelPad
                cell.textLabel!.text = "See the full gallery"
                cell.collectionView.reloadData()
                return cell
            }
            
        } else if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Latest News"
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                
                let date1 = (_feedItems.firstObject as AnyObject).value(forKey: "createdAt") as? Date
                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount = diffDateComponents.day
                    let newsString : String? = (_feedItems.firstObject as AnyObject).value(forKey: "newsDetail") as? String
                    if newsString != nil {
                        cell.snaptitleLabel?.text = "\(newsString!), \(daysCount!) days ago"
                    } else {
                        cell.snaptitleLabel?.text = "none"
                    }
                }
                cell.snapdetailLabel?.text = (_feedItems.firstObject as AnyObject).value(forKey: "newsTitle") as? String
                cell.collectionView.reloadData()
                return cell
            }
            
        }  else if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Latest Blog"
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                
                let date11 = (_feedItems6.firstObject as AnyObject).value(forKey: "createdAt") as? Date
                if date11 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date11!, to: date2)
                    let daysCount1 = diffDateComponents.day
                    let newsString : String? = (_feedItems6.firstObject as AnyObject).value(forKey: "PostBy") as? String
                    if newsString != nil {
                        cell.snaptitleLabel?.text = "\(newsString!), \(daysCount1!) days ago"
                    } else {
                        cell.snaptitleLabel?.text = "none"
                    }
                }
                cell.snapdetailLabel?.text = (_feedItems6.firstObject as AnyObject).value(forKey: "Subject") as? String
                cell.collectionView.reloadData()
                return cell
            }
            
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Jobs ", _feedItems2.count)
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 1
                cell.collectionView.reloadData()
                return cell
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.font = Font.Snapshot.celllabelPad
                cell.textLabel!.text = "See the full gallery"
                cell.collectionView.reloadData()
                return cell
            }
            
        } else if (indexPath.section == 4) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Users ", _feedItems3.count)
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 2
                cell.collectionView.reloadData()
                return cell
                
            }
            
        } else if (indexPath.section == 5) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Salesman ", _feedItems4.count)
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 3
                cell.collectionView.reloadData()
                return cell
            }
            
        } else if (indexPath.section == 6) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Employee ", _feedItems5.count)
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 4
                cell.collectionView.reloadData()
                return cell
            }
            
        } else if (indexPath.section == 7) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Top Notification"
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
            } else if (indexPath.row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                cell.snapdetailLabel?.text = "You have no pending notifications :)"
                //cell.snaptitleLabel?.text = localNotification.fireDate?.description
                //cell.snapdetailLabel?.text = localNotification.alertBody
                cell.collectionView.reloadData()
                return cell
            }
            
        }  else if (indexPath.section == 8) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Top Calender Event"
                cell.selectionStyle = .gray
                cell.accessoryType = .disclosureIndicator
                cell.collectionView.reloadData()
                return cell
            } else if (indexPath.row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                
                if (calendars?.count == 0) {
                    cell.snapdetailLabel?.text = "You have no pending events :)"
                    
                } else {
                    
                    if let calendars = self.calendars {
                        let calendarName = calendars[0].title
                        cell.snapdetailLabel?.text  = calendarName
                    } else {
                        cell.snapdetailLabel?.text  = "Unknown Calendar Name"
                    }
                    /*
                     let reminder:EKReminder! = self.reminders![0]
                     cell.snapdetailLabel?.text = reminder!.title
                     
                     let formatter:DateFormatter = DateFormatter()
                     formatter.dateFormat = "yyyy-MM-dd"
                     if let dueDate = reminder.dueDateComponents?.date {
                     cell.snaptitleLabel?.text = formatter.string(from: dueDate)
                     } */
                }
                cell.collectionView.reloadData()
                return cell
            }
        }
        //cell.collectionView.reloadData()
        return cell
    }
    
    func loadCalendars() {
        self.calendars = EKEventStore().calendars(for: EKEntityType.event).sorted() { (cal1, cal2) -> Bool in
            return cal1.title < cal2.title
        }
    }
    
    // MARK: UICollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        if (collectionView.tag == 0) {
            return _feedItems.count 
        } else if (collectionView.tag == 1) {
            return _feedItems2.count 
        } else if (collectionView.tag == 2) {
            return _feedItems3.count 
        } else if (collectionView.tag == 3) {
            return _feedItems4.count 
        } else if (collectionView.tag == 4) {
            return _feedItems5.count 
        }
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath)->UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CollectionViewCell
        
        cell.activityIndicatorView1.frame = CGRect(x: cell.user2ImageView!.frame.size.width/2-15, y: cell.user2ImageView!.frame.size.height/2-15, width: 50, height: 50)
        
        cell.backgroundColor = Color.Snap.collectbackColor
        cell.user2ImageView!.backgroundColor = .black
        
        //cell.playButton2.center = (cell.user2ImageView?.center)!
        cell.playButton2.frame = CGRect(x: cell.user2ImageView!.frame.size.width/2-15, y: cell.user2ImageView!.frame.size.height/2-15, width: 30, height: 30)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) && (collectionView.tag == 0) {
            myLabel1 = UILabel(frame: CGRect(x: 0, y: 160, width: cell.bounds.size.width, height: 20))
        } else {
            myLabel1 = UILabel(frame: CGRect(x: 0, y: 110, width: cell.bounds.size.width, height: 20))
        }
        myLabel1.font = Font.Snapshot.cellLabel
        myLabel1.backgroundColor = Color.Snap.collectbackColor
        myLabel1.textColor = Color.Snap.textColor
        myLabel1.textAlignment = .center
        myLabel1.clipsToBounds = true
      //myLabel1.adjustsFontSizeToFitWidth = true

        if (collectionView.tag == 0) {
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()

            imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.user2ImageView!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.user2ImageView?.image = UIImage(data: imageData!)
                }, completion: nil)

                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
            cell.addSubview(myLabel1)
            
            imageDetailurl = self.imageFile.url!
            let result1 = imageDetailurl?.contains("movie.mp4")
            cell.playButton2.isHidden = result1 == false
            cell.playButton2.setTitle(imageDetailurl, for: .normal)
            cell.addSubview(cell.playButton2)
            
            return cell
        } else if (collectionView.tag == 1) {
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            
            imageObject = _feedItems2.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.user2ImageView!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.user2ImageView?.image = UIImage(data: imageData!)
                }, completion: nil)
                
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = (_feedItems2[indexPath.row] as AnyObject).value(forKey: "imageGroup") as? String
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 2) {
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            imageObject = _feedItems3.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in

                UIView.transition(with: cell.user2ImageView!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.user2ImageView?.image = UIImage(data: imageData!)
                }, completion: nil)
                
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = (_feedItems3[indexPath.row] as AnyObject).value(forKey: "username") as? String
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 3) {
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            imageObject = _feedItems4.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.user2ImageView!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.user2ImageView?.image = UIImage(data: imageData!)
                }, completion: nil)
                
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = (_feedItems4[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 4) {
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            imageObject = _feedItems5.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                UIView.transition(with: cell.user2ImageView!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.user2ImageView?.image = UIImage(data: imageData!)
                }, completion: nil)
                
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = String(format: "%@ %@ %@ ", ((_feedItems5[indexPath.row] as AnyObject).value(forKey: "First") as? String)!, ((_feedItems5[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!, ((_feedItems5[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!)
            cell.addSubview(myLabel1)
            
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 0) {
            if UI_USER_INTERFACE_IDIOM() == .pad {
                return CGSize(width: 250, height: 180) //w150 h130
            } else {
                return CGSize(width: 190, height: 130)
            }
        } else if (collectionView.tag == 1) {
            return CGSize(width: 155, height: 130)
        } else if (collectionView.tag == 2) {
            return CGSize(width: 125, height: 130)
        }
        return CGSize(width: 95, height: 130)
    }
    
    
//---- below Creates Instagram thin Line spacing between cells---
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout , minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout , minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 1.0
    }
//-----------------------------------------------------------
    
    // MARK: - Parse
    
    func parseData() {
        
        //guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        
        let query = PFQuery(className:"Newsios")
        query.cachePolicy = .cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query2 = PFQuery(className:"jobPhoto")
        query2.cachePolicy = .cacheThenNetwork
        query2.order(byDescending: "createdAt")
        query2.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems2 = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query3 = PFUser.query()
        query3!.cachePolicy = .cacheThenNetwork
        query3!.order(byDescending: "createdAt")
        query3!.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems3 = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query4 = PFQuery(className:"Salesman")
        query4.cachePolicy = .cacheThenNetwork
        query4.order(byAscending: "Salesman")
        query4.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems4 = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query5 = PFQuery(className:"Employee")
        query5.cachePolicy = .cacheThenNetwork
        query5.order(byAscending: "createdAt")
        query5.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems5 = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query6 = PFQuery(className:"Blog")
        query6.whereKey("ReplyId", equalTo:NSNull())
        query6.cachePolicy = .cacheThenNetwork
        query6.order(byDescending: "createdAt")
        query6.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems6 = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
 
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Segues
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (collectionView.tag == 0) {
            
            imageObject = _feedItems.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                let imageDetailurl = self.imageFile.url
                let result1 = imageDetailurl!.contains("movie.mp4")
                if (result1 == true) {
                    
                    self.performSegue(withIdentifier: "snapvideoSegue", sender: self)
                    /*
                    let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
                    vc.videoURL = self.imageFile.url! */
                    
                    NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
                    
                    /*
                     let videoLauncher = VideoLauncher()
                     videoLauncher.videoURL = self.imageFile.url
                     videoLauncher.showVideoPlayer() */
                    
                } else {
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                self.selectedTitle = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
                self.selectedEmail = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsDetail") as? String
                self.selectedPhone = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "storyText") as? String
                self.imageDetailurl = self.imageFile.url
                self.selectedDate = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
                
                self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
                }
            }
        } else if (collectionView.tag == 1) {
            
            imageObject = _feedItems2.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedTitle = (self._feedItems2[indexPath.row] as AnyObject).value(forKey: "imageGroup") as? String
            self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
            }
            
        } else if (collectionView.tag == 2) {
            
            imageObject = _feedItems3.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = (self._feedItems3[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                self.selectedName = (self._feedItems3[indexPath.row] as AnyObject).value(forKey: "username") as? String
                self.selectedEmail = (self._feedItems3[indexPath.row] as AnyObject).value(forKey: "email") as? String
                self.selectedPhone = (self._feedItems3[indexPath.row] as AnyObject).value(forKey: "phone") as? String
                
                let updated:Date = (self._feedItems3[indexPath.row] as AnyObject).value(forKey: "createdAt") as! Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let createString = dateFormatter.string(from: updated)
                self.selectedCreate = createString
                
                self.performSegue(withIdentifier: "userdetailSegue", sender:self)
            }
        } else if (collectionView.tag == 3) {
            
            imageObject = _feedItems4.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = (self._feedItems4[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                self.selectedEmail = (self._feedItems4[indexPath.row] as AnyObject).value(forKey: "SalesNo") as? String
                self.selectedPhone = (self._feedItems4[indexPath.row] as AnyObject).value(forKey: "Active") as? String
                self.selectedTitle = (self._feedItems4[indexPath.row] as AnyObject).value(forKey: "Salesman") as? String
                
                self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
            }
        } else if (collectionView.tag == 4) {
            
            imageObject = _feedItems5.object(at: indexPath.row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { imageData, error in
                
                self.selectedObjectId = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                self.selectedPhone = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "EmployeeNo") as? String
                self.selectedCreate = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Email") as? String
                
                self.selectedName = String(format: "%@ %@ %@", ((self._feedItems5[indexPath.row] as AnyObject).value(forKey: "First") as? String)!, ((self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Last") as? String)!, ((self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Company") as? String)!).removeWhiteSpace()
                
                self.selectedTitle = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Last") as? String
                self.selectedEmail = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Street") as? String
                self.imageDetailurl = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "City") as? String
                self.selectedState = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "State") as? String
                self.selectedZip = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Zip") as? String
                
                self.selectedAmount = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Title") as? String
                self.selected11 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "HomePhone") as? String
                self.selected12 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "WorkPhone") as? String
                self.selected13 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "CellPhone") as? String
                self.selected14 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "SS") as? String
                self.selected15 = ((self._feedItems5[indexPath.row]) as AnyObject).value(forKey: "Middle") as? NSString
                
                self.selected21 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Email") as? NSString
                self.selected22 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Department") as? String
                self.selected23 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Title") as? String
                self.selected24 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Manager") as? String
                self.selected25 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Country") as? String
                
                self.selected16 = String(describing:(self._feedItems5[indexPath.row] as AnyObject).value(forKey: "updatedAt") as? Date)
                self.selected26 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "First") as? NSString
                self.selected27 = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Company") as? String
                self.selectedComments = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Comments") as? String
                self.selectedActive = (self._feedItems5[indexPath.row] as AnyObject).value(forKey: "Active") as? String
                
                self.performSegue(withIdentifier: "snapemployeeSegue", sender:self)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "snapvideoSegue" {
            
            let vc = segue.destination as? PlayVC
            vc?.videoURL = self.imageFile.url ?? ""
            
        } else if segue.identifier == "snapuploadSegue" {
            
            let VC = segue.destination as? NewsDetailController
            VC!.objectId = self.selectedObjectId ?? ""
            VC!.newsTitle = self.selectedTitle ?? ""
            VC!.newsDetail = self.selectedEmail ?? ""
            VC!.newsDate = self.selectedDate ?? Date()
            VC!.newsStory = self.selectedPhone ?? ""
            VC!.image = self.selectedImage ?? nil
            VC!.videoURL = self.imageDetailurl ?? ""
            VC!.SnapshotBool = true //hide leftBarButtonItems
            
        } else if segue.identifier == "userdetailSegue" {
            
            let VC = segue.destination as? UserDetailController
            VC!.status = "Edit"
            VC!.objectId = self.selectedObjectId ?? ""
            VC!.username = self.selectedName ?? ""
            VC!.create = self.selectedCreate ?? ""
            VC!.email = self.selectedEmail ?? ""
            VC!.phone = self.selectedPhone ?? ""
            VC!.userimage = self.selectedImage ?? nil
            
        } else if segue.identifier == "snapemployeeSegue" {
            
            let VC = segue.destination as? LeadDetail
            VC!.formController = "Employee"
            VC!.objectId = self.selectedObjectId ?? ""
            VC!.leadNo = self.selectedPhone ?? ""
            VC!.date = self.selectedCreate ?? ""
            VC!.name = self.selectedName ?? ""
            VC!.custNo = self.selectedTitle ?? ""
            VC!.address = self.selectedEmail ?? ""
            VC!.city = self.imageDetailurl ?? ""
            VC!.state = self.selectedState ?? ""
            VC!.zip = self.selectedZip ?? ""
            VC!.amount = self.selectedAmount ?? ""
            VC!.tbl11 = self.selected11 ?? ""
            VC!.tbl12 = self.selected12 ?? ""
            VC!.tbl13 = self.selected13 ?? ""
            VC!.tbl14 = self.selected14 ?? ""
            VC!.tbl15 = self.selected15 ?? ""
            VC!.tbl21 = self.selected21 ?? ""
            VC!.tbl22 = self.selected22 ?? ""
            VC!.tbl23 = self.selected23 ?? ""
            VC!.tbl24 = self.selected24 ?? ""
            VC!.tbl25 = self.selected25 ?? ""
            VC!.tbl16 = self.selected16 ?? ""
            VC!.tbl26 = self.selected26 ?? ""
            VC!.tbl27 = self.selected27 ?? ""
            VC!.comments = self.selectedComments ?? ""
            VC!.active = self.selectedActive ?? ""
            
            VC!.l11 = "Home"; VC!.l12 = "Work"
            VC!.l13 = "Mobile"; VC!.l14 = "Social"
            VC!.l15 = "Middle "; VC!.l21 = "Email"
            VC!.l22 = "Department"; VC!.l23 = "Title"
            VC!.l24 = "Manager"; VC!.l25 = "Country"
            VC!.l16 = "Last Updated"; VC!.l26 = "First"
            VC!.l1datetext = "Email:"
            VC!.lnewsTitle = Config.NewsEmploy
        }
        
    }
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension SnapshotController: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        //searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.barTintColor = .black //Color.Lead.navColor
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension SnapshotController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

