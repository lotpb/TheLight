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
    
    let celltitle1 = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    let cellsubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)

    @IBOutlet weak var tableView: UITableView!
    
    var selectedImage : UIImage!
    var eventStore: EKEventStore!
    var reminders: [EKReminder]!

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
    var selected15 : String!
    var selected16 : String!
    var selected21 : String!
    var selected22 : String!
    var selected23 : String!
    var selected24 : String!
    var selected25 : String!
    var selected26 : String!
    var selected27 : String!
    
    var resultDateDiff : String!
    var imageDetailurl : String?
    
    var maintitle : UILabel!
    var datetitle : UILabel!

    var _feedItems : NSMutableArray = NSMutableArray() //news
    var _feedItems2 : NSMutableArray = NSMutableArray() //job
    var _feedItems3 : NSMutableArray = NSMutableArray() //user
    var _feedItems4 : NSMutableArray = NSMutableArray() //salesman
    var _feedItems5 : NSMutableArray = NSMutableArray() //employee
    var _feedItems6 : NSMutableArray = NSMutableArray() //blog
    var refreshControl: UIRefreshControl!
    
    var imageObject :PFObject!
    var imageFile :PFFile!
    
    //below has nothing
    var detailItem: AnyObject? { //dont delete for splitview
        didSet {
 
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("mySnapshot", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(SnapshotController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
        parseData()
        setupTableView()
        setupNavBarButtons()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.DGrayColor
        }
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        self.tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    func setupNavBarButtons() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(SnapshotController.searchButton))
        let buttons:NSArray = [searchButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
    }
    
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject)
    {
        parseData()
        self.refreshControl?.endRefreshing()
    }
    

    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let result:CGFloat = 140
        if ((indexPath as NSIndexPath).section == 0) {
        
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            case 2:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 1) {
            let result:CGFloat = 100
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 2) {
            let result:CGFloat = 100
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 3) {
            
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            case 2:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 4) {
            
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 5) {
            
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 6) {
    
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
            return 44
            default:
            return result
            }
        } else if ((indexPath as NSIndexPath).section == 7) {
            let result:CGFloat = 100
            switch ((indexPath as NSIndexPath).row % 4)
            {
            case 0:
                return 44
            default:
                return result
            }
        } else if ((indexPath as NSIndexPath).section == 8) {
            let result:CGFloat = 100
            switch ((indexPath as NSIndexPath).row % 4)
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
        
        if (section == 0) {
            return 3
        } else if (section == 3) {
            return 3
        }
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return CGFloat.leastNormalMagnitude
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableCell
        
        cell.collectionView.delegate = nil
        cell.collectionView.dataSource = nil
        cell.collectionView.backgroundColor = .white
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.textLabel!.font = Font.Snapshot.celltitle
            cell.snaptitleLabel.font = cellsubtitle
            cell.snapdetailLabel.font = celltitle1
        } else {
            cell.textLabel!.font = Font.Snapshot.celltitle
            cell.snaptitleLabel.font = cellsubtitle
            cell.snapdetailLabel.font = celltitle1
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.textLabel?.text = ""
        
        cell.snaptitleLabel?.numberOfLines = 1
        cell.snaptitleLabel?.text = ""
        cell.snaptitleLabel?.textColor = .lightGray
        
        cell.snapdetailLabel?.numberOfLines = 3
        cell.snapdetailLabel?.text = ""
        cell.snapdetailLabel?.textColor = .black
        
        let date2 = Date()
        let calendar = Calendar.current
        
        if ((indexPath as NSIndexPath).section == 0) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top News ", _feedItems.count)
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 0
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 2) {
                
                cell.textLabel!.text = "myNews"
                
                return cell
            }
            
        } else if ((indexPath as NSIndexPath).section == 1) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = "Top News Story"
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                cell.snapdetailLabel?.text = _feedItems.firstObject?.value(forKey: "newsTitle") as? String
                
                let date1 = _feedItems.firstObject?.value(forKey: "createdAt") as? Date
                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount = diffDateComponents.day
                    let newsString : String? = _feedItems.firstObject?.value(forKey: "newsDetail") as? String
                    if newsString != nil {
                        cell.snaptitleLabel?.text = "\(newsString!), \(daysCount!) days ago"
                    }
                }
                
                return cell
            }
            
        }  else if ((indexPath as NSIndexPath).section == 2) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = "Top Blog Story"
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                cell.snapdetailLabel?.text = _feedItems6.firstObject?.value(forKey: "Subject") as? String
                
                let date1 = _feedItems6.firstObject?.value(forKey: "createdAt") as? Date
                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount = diffDateComponents.day
                    let newsString : String? = _feedItems6.firstObject?.value(forKey: "PostBy") as? String
                    if newsString != nil {
                        cell.snaptitleLabel?.text = "\(newsString!), \(daysCount!) days ago"
                    }
                }
                
                return cell
            }
            
        } else if ((indexPath as NSIndexPath).section == 3) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Jobs ", _feedItems2.count)
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 1
                
                return cell
            }
            
        } else if ((indexPath as NSIndexPath).section == 4) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Users ", _feedItems3.count)
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 2
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 2) {
                
                cell.textLabel!.text = "myUser"
                
                return cell
            }
            
        } else if ((indexPath as NSIndexPath).section == 5) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Salesman ", _feedItems4.count)
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 3
                
                return cell
            }
            
        } else if ((indexPath as NSIndexPath).section == 6) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = String(format: "%@%d", "Top Employee ", _feedItems5.count)
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
                
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.tag = 4
                
                return cell
            }
            
        } else if ((indexPath as NSIndexPath).section == 7) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = "Top Notification"
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                
                let localNotification = UILocalNotification()
                if (UIApplication.shared.scheduledLocalNotifications!.count == 0) {
                    cell.snapdetailLabel?.text = "You have no pending notifications :)"
                } else {
                    cell.snaptitleLabel?.text = localNotification.fireDate?.description
                    cell.snapdetailLabel?.text = localNotification.alertBody
                }
                
                return cell
            }
            
        }  else if ((indexPath as NSIndexPath).section == 8) {
            
            if ((indexPath as NSIndexPath).row == 0) {
                
                cell.textLabel!.text = "Top Calender Event"
                cell.selectionStyle = UITableViewCellSelectionStyle.gray
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
            } else if ((indexPath as NSIndexPath).row == 1) {
                
                cell.collectionView.backgroundColor = .clear
                
                if (reminders.count == 0) {
                    cell.snapdetailLabel?.text = "You have no pending events :)"
                    
                } else {
                    
                    let reminder:EKReminder! = self.reminders![0]
                    cell.snapdetailLabel?.text = reminder!.title
                    
                    let formatter:DateFormatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let dueDate = reminder.dueDateComponents?.date{
                        cell.snaptitleLabel?.text = formatter.string(from: dueDate)
                    }
                }
                return cell
            }
        }
        return cell
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

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath)->UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CollectionViewCell
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 0, y: 110, width: cell.bounds.size.width, height: 20))
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.clipsToBounds = true
        myLabel1.font = Font.headtitle
        //myLabel1.adjustsFontSizeToFitWidth = true

        cell.playButton2.frame = CGRect(x: cell.user2ImageView!.frame.size.width/2-15, y: cell.user2ImageView!.frame.size.height/2-15, width: 30, height: 30)
        //cell.activityIndicatorView2.frame = CGRect(x: cell.user2ImageView!.frame.size.width/2-15, y: cell.user2ImageView!.frame.size.height/2-15, width: 50, height: 50)
        
        if (collectionView.tag == 0) {
            
            imageObject = _feedItems.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                cell.user2ImageView!.backgroundColor = .black
                cell.user2ImageView?.image = UIImage(data: imageData!)
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = _feedItems[(indexPath as NSIndexPath).row].value(forKey: "newsTitle") as? String
            cell.addSubview(myLabel1)
            
            imageDetailurl = self.imageFile.url!
            let result1 = imageDetailurl?.contains("movie.mp4")
            cell.playButton2.isHidden = result1 == false
            cell.playButton2.setTitle(imageDetailurl, for: UIControlState.normal)
            cell.addSubview(cell.playButton2)
            
            return cell
        } else if (collectionView.tag == 1) {
            
            imageObject = _feedItems2.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                cell.user2ImageView!.backgroundColor = .black
                cell.user2ImageView?.image = UIImage(data: imageData!)
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = _feedItems2[(indexPath as NSIndexPath).row].value(forKey: "imageGroup") as? String
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 2) {
            
            imageObject = _feedItems3.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                cell.user2ImageView!.backgroundColor = .black
                cell.user2ImageView?.image = UIImage(data: imageData!)
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = _feedItems3[(indexPath as NSIndexPath).row].value(forKey: "username") as? String
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 3) {
            
            imageObject = _feedItems4.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                cell.user2ImageView!.backgroundColor = .black
                cell.user2ImageView?.image = UIImage(data: imageData!)
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = _feedItems4[(indexPath as NSIndexPath).row].value(forKey: "Salesman") as? String
            cell.addSubview(myLabel1)
            
            return cell
        } else if (collectionView.tag == 4) {
            
            imageObject = _feedItems5.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            
            cell.loadingSpinner?.isHidden = false
            cell.loadingSpinner?.startAnimating()
            
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                cell.user2ImageView!.backgroundColor = .black
                cell.user2ImageView?.image = UIImage(data: imageData!)
                cell.loadingSpinner?.stopAnimating()
                cell.loadingSpinner?.isHidden = true
            }
            
            myLabel1.text = String(format: "%@ %@ %@ ", (_feedItems5[(indexPath as NSIndexPath).row].value(forKey: "First") as? String)!, (_feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Last") as? String)!, (_feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Company") as? String)!)
            cell.addSubview(myLabel1)
            
            return cell
        }
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 0) {
            return CGSize(width: 150, height: 130)
        } else if (collectionView.tag == 1) {
            return CGSize(width: 150, height: 130)
        } else if (collectionView.tag == 2) {
            return CGSize(width: 120, height: 130)
        }
        return CGSize(width: 90, height: 130)
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
        
        let query = PFQuery(className:"Newsios")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
            } else {
                print("Error")
            }
        }
        
        let query2 = PFQuery(className:"jobPhoto")
        query2.cachePolicy = PFCachePolicy.cacheThenNetwork
        query2.order(byDescending: "createdAt")
        query2.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems2 = temp.mutableCopy() as! NSMutableArray
            } else {
                print("Error")
            }
        }
        
        let query3 = PFUser.query()
        query3!.cachePolicy = PFCachePolicy.cacheThenNetwork
        query3!.order(byDescending: "createdAt")
        query3!.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems3 = temp.mutableCopy() as! NSMutableArray
            } else {
                print("Error")
            }
        }
        
        let query4 = PFQuery(className:"Salesman")
        query4.cachePolicy = PFCachePolicy.cacheThenNetwork
        query4.order(byAscending: "Salesman")
        query4.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems4 = temp.mutableCopy() as! NSMutableArray
            } else {
                print("Error")
            }
        }
        
        let query5 = PFQuery(className:"Employee")
        query5.cachePolicy = PFCachePolicy.cacheThenNetwork
        query5.order(byAscending: "createdAt")
        query5.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems5 = temp.mutableCopy() as! NSMutableArray
            } else {
                print("Error")
            }
        }
        
        let query6 = PFQuery(className:"Blog")
        query6.whereKey("ReplyId", equalTo:NSNull())
        query6.cachePolicy = PFCachePolicy.cacheThenNetwork
        query6.order(byDescending: "createdAt")
        query6.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems6 = temp.mutableCopy() as! NSMutableArray
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
            
            imageObject = _feedItems.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                let imageDetailurl = self.imageFile.url
                let result1 = imageDetailurl!.contains("movie.mp4")
                if (result1 == true) {
                    
                    let videoLauncher = VideoLauncher()
                    videoLauncher.videoURL = self.imageFile.url
                    videoLauncher.showVideoPlayer()
                    
                } else {
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = self._feedItems[(indexPath as NSIndexPath).row].value(forKey: "objectId") as? String
                self.selectedTitle = self._feedItems[(indexPath as NSIndexPath).row].value(forKey: "newsTitle") as? String
                self.selectedEmail = self._feedItems[(indexPath as NSIndexPath).row].value(forKey: "newsDetail") as? String
                self.selectedPhone = self._feedItems[(indexPath as NSIndexPath).row].value(forKey: "storyText") as? String
                self.imageDetailurl = self.imageFile.url
                self.selectedDate = (self._feedItems[(indexPath as NSIndexPath).row].value(forKey: "createdAt") as? Date)!
                
                self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
                }
            }
        } else if (collectionView.tag == 1) {
            
            imageObject = _feedItems2.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedTitle = self._feedItems2[(indexPath as NSIndexPath).row].value(forKey: "imageGroup") as? String
            self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
            }
            
        } else if (collectionView.tag == 2) {
            
            imageObject = _feedItems3.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = self._feedItems3[(indexPath as NSIndexPath).row].value(forKey: "objectId") as? String
                self.selectedName = self._feedItems3[(indexPath as NSIndexPath).row].value(forKey: "username") as? String
                self.selectedEmail = self._feedItems3[(indexPath as NSIndexPath).row].value(forKey: "email") as? String
                self.selectedPhone = self._feedItems3[(indexPath as NSIndexPath).row].value(forKey: "phone") as? String
                
                let updated:Date = (self._feedItems3[((indexPath as NSIndexPath).row)].value(forKey: "createdAt") as? Date)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let createString = dateFormatter.string(from: updated)
                self.selectedCreate = createString
                
                self.performSegue(withIdentifier: "userdetailSegue", sender:self)
            }
        } else if (collectionView.tag == 3) {
            
            imageObject = _feedItems4.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = self._feedItems4[(indexPath as NSIndexPath).row].value(forKey: "objectId") as? String
                self.selectedEmail = self._feedItems4[(indexPath as NSIndexPath).row].value(forKey: "SalesNo") as? String
                self.selectedPhone = self._feedItems4[(indexPath as NSIndexPath).row].value(forKey: "Active") as? String
                self.selectedTitle = self._feedItems4[(indexPath as NSIndexPath).row].value(forKey: "Salesman") as? String
                
                self.performSegue(withIdentifier: "snapuploadSegue", sender:self)
            }
        } else if (collectionView.tag == 4) {
            
            imageObject = _feedItems4.object(at: (indexPath as NSIndexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                
                //self.selectedImage = UIImage(data: imageData!)
                self.selectedObjectId = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "objectId") as? String
                self.selectedPhone = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "EmployeeNo") as? String
                self.selectedCreate = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Email") as? String
                
                self.selectedName = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "SalesNo") as? String
                
                self.selectedTitle = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Last") as? String
                self.selectedEmail = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Street") as? String
                self.imageDetailurl = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "City") as? String
                self.selectedState = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "State") as? String
                self.selectedZip = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Zip") as? String
                
                self.selectedAmount = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Title") as? String
                self.selected11 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "HomePhone") as? String
                self.selected12 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "WorkPhone") as? String
                self.selected13 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "CellPhone") as? String
                self.selected14 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "SS") as? String
                self.selected15 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Middle") as? String
                
                self.selected21 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Email") as? String
                self.selected22 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Department") as? String
                self.selected23 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Title") as? String
                self.selected24 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Manager") as? String
                self.selected25 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Country") as? String
                
                self.selected16 = String(self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "updatedAt") as? Date)
                self.selected26 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "First") as? String
                self.selected27 = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Company") as? String
                self.selectedComments = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Comments") as? String
                self.selectedActive = self._feedItems5[(indexPath as NSIndexPath).row].value(forKey: "Active") as? String
                
                self.performSegue(withIdentifier: "snapemployeeSegue", sender:self)
            }
        }
    }
    
     // MARK: - Search
    
    func searchButton(_ sender: AnyObject) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "snapuploadSegue" {
            
            let VC = segue.destination as? NewsDetailController
            VC!.objectId = self.selectedObjectId
            VC!.newsTitle = self.selectedTitle
            VC!.newsDetail = self.selectedEmail
            VC!.newsDate = self.selectedDate
            VC!.newsStory = self.selectedPhone
            VC!.image = self.selectedImage
            VC!.videoURL = self.imageDetailurl
            
        } else if segue.identifier == "userdetailSegue" {
            
            let VC = segue.destination as? UserDetailController
            VC!.objectId = self.selectedObjectId
            VC!.username = self.selectedName
            VC!.create = self.selectedCreate
            VC!.email = self.selectedEmail
            VC!.phone = self.selectedPhone
            VC!.userimage = self.selectedImage
            
        } else if segue.identifier == "snapemployeeSegue" {
            
            let VC = segue.destination as? LeadDetail
            VC!.formController = "Employee"
            VC!.objectId = self.selectedObjectId as String
            VC!.leadNo = self.selectedPhone as String
            VC!.date = self.selectedCreate as String
            VC!.name = self.selectedName as String
            VC!.custNo = self.selectedTitle as String
            VC!.address = self.selectedEmail as String
            VC!.city = self.imageDetailurl! as String
            VC!.state = self.selectedState as String
            VC!.zip = self.selectedZip as String
            VC!.amount = self.selectedAmount as String
            VC!.tbl11 = self.selected11
            VC!.tbl12 = self.selected12
            VC!.tbl13 = self.selected13
            VC!.tbl14 = self.selected14
            VC!.tbl15 = self.selected15
            VC!.tbl21 = self.selected21
            VC!.tbl22 = self.selected22
            VC!.tbl23 = self.selected23
            VC!.tbl24 = self.selected24
            VC!.tbl25 = self.selected25
            VC!.tbl16 = self.selected16
            VC!.tbl26 = self.selected26
            VC!.tbl27 = self.selected27
            VC!.comments = self.selectedComments
            VC!.active = self.selectedActive
            
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
