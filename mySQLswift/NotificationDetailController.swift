//
//  NotificationDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/27/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit

class NotificationDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ipadtitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
    let ipadsubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    
    let celltitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    let cellsubtitle = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
    
    @IBOutlet weak var tableView: UITableView?
    var filteredString : NSMutableArray = NSMutableArray()
    var objects = [AnyObject]()
    var refreshControl: UIRefreshControl!
    //let searchController = UISearchController(searchResultsController: nil)
    var localNotifications = NSArray()
    var localNotification = UILocalNotification()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("myNotification list", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.rowHeight = 85
        //self.tableView!.estimatedRowHeight = 110
        //self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        //self.tableView!.tableFooterView = UIView(frame: .zero)
        
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(NotificationDetailController.deleteButton))
        let buttons:NSArray = [trashButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .orange
        refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(NotificationDetailController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .orange
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject)
    {
        self.tableView!.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Buttons
    
    func deleteButton(_ sender:UIButton) {

        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.cancelAllLocalNotifications()
        self.tableView!.reloadData()
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (UIApplication.shared.scheduledLocalNotifications!.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier: String = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell

        cell.textLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.textLabel!.font = ipadtitle
            cell.detailTextLabel!.font = ipadsubtitle

        } else {
            cell.textLabel!.font = celltitle
            cell.detailTextLabel!.font = celltitle
        }
        
        
        if (UIApplication.shared.scheduledLocalNotifications!.count == 0) {
            
            cell.textLabel!.text = "You have no pending Notifications :)"
            cell.detailTextLabel!.text = "You have no pending Notifications :)"
            
        } else {
            
            localNotifications = UIApplication.shared.scheduledLocalNotifications!
            localNotification = localNotifications.object(at: (indexPath as NSIndexPath).row) as! UILocalNotification
            
            //cell.textLabel!.text = "You have no pending Notifications :)"
            //cell.detailTextLabel!.text = "You have no pending Notifications :)"
            
            cell.textLabel!.text = localNotification.fireDate?.description
            cell.detailTextLabel!.text = localNotification.alertBody
            cell.detailTextLabel!.numberOfLines = 2
        }
        
        return cell
    }
    /*
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .orangeColor()
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRectMake(10, 15, 50, 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = UIColor.whiteColor()
        myLabel1.textColor = UIColor.blackColor()
        myLabel1.textAlignment = NSTextAlignment.Center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Count\n", (UIApplication.sharedApplication().scheduledLocalNotifications!.count))
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.userInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRectMake(10, 75, 50, 2.5))
        separatorLineView1.backgroundColor = UIColor.whiteColor()
        vw.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRectMake(80, 15, 50, 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = UIColor.whiteColor()
        myLabel2.textColor = UIColor.blackColor()
        myLabel2.textAlignment = NSTextAlignment.Center
        myLabel2.layer.masksToBounds = true
        myLabel2.text = "Active"
        myLabel2.font = Font.headtitle
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.userInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: CGRectMake(80, 75, 50, 2.5))
        separatorLineView2.backgroundColor = UIColor.whiteColor()
        vw.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: CGRectMake(150, 15, 50, 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = UIColor.whiteColor()
        myLabel3.textColor = UIColor.blackColor()
        myLabel3.textAlignment = NSTextAlignment.Center
        myLabel3.layer.masksToBounds = true
        myLabel3.text = "Events"
        myLabel3.font = Font.headtitle
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.userInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        let separatorLineView3 = UIView(frame: CGRectMake(150, 75, 50, 2.5))
        separatorLineView3.backgroundColor = UIColor.whiteColor()
        vw.addSubview(separatorLineView3)
        
        return vw
    } */
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    

    
}
