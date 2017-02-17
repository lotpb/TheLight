//
//  NotificationDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/27/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import  UserNotifications

class NotificationDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 20)
    let ipadsubtitle = UIFont.systemFont(ofSize: 16)
    
    let celltitle = UIFont.systemFont(ofSize: 16)
    let cellsubtitle = UIFont.systemFont(ofSize: 12)
    
    @IBOutlet weak var tableView: UITableView?
    var filteredString : NSMutableArray = NSMutableArray()
    var objects = [AnyObject]()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            button.setTitle("TheLight - Notifications", for: .normal)
        } else {
            button.setTitle("Notifications", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .orange
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
        
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [trashButton]
        
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = .orange
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
        self.tableView!.rowHeight = 85
        self.tableView!.backgroundColor = Color.LGrayColor
    }
    
    // MARK: - refresh
    
    func refreshData(_ sender:AnyObject) {
        self.tableView!.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Buttons
    
    func deleteButton(_ sender:UIButton) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        //UIApplication.shared.cancelAllLocalNotifications()
        self.tableView!.reloadData()
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (UIApplication.shared.currentUserNotificationSettings?.categories!.count)!
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
        
        
        if (UIApplication.shared.currentUserNotificationSettings?.categories!.count == 0) {
            
            cell.textLabel!.text = "You have no pending Notifications :)"
            cell.detailTextLabel!.text = "You have no pending Notifications :)"
            
        } else {
            /*
            localNotifications = UIApplication.shared.scheduledLocalNotifications! as [AnyObject]
            localNotification = localNotifications.object(at: indexPath.row) as! UILocalNotification
            
            //cell.textLabel!.text = "You have no pending Notifications :)"
            //cell.detailTextLabel!.text = "You have no pending Notifications :)"
            
            cell.textLabel!.text = localNotification.fireDate?.description
            cell.detailTextLabel!.text = localNotification.alertBody
            cell.detailTextLabel!.numberOfLines = 2 */
        }
        
        return cell
    }
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .orange
        //tableView.tableHeaderView = vw
        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 50, height: 50))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = .center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "Count\n", (UIApplication.shared.scheduledLocalNotifications!.count))
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 25.0
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 75, width: 50, height: 2.5))
        separatorLineView1.backgroundColor = .white
        vw.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: 80, y: 15, width: 50, height: 50))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = .center
        myLabel2.layer.masksToBounds = true
        myLabel2.text = "Active"
        myLabel2.font = Font.headtitle
        myLabel2.layer.cornerRadius = 25.0
        myLabel2.isUserInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let separatorLineView2 = UIView(frame: CGRect(x: 80, y: 75, width: 50, height: 2.5))
        separatorLineView2.backgroundColor = .white
        vw.addSubview(separatorLineView2)
        
        let myLabel3:UILabel = UILabel(frame: CGRect(x: 150, y: 15, width: 50, height: 50))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = .black
        myLabel3.textAlignment = .center
        myLabel3.layer.masksToBounds = true
        myLabel3.text = "Events"
        myLabel3.font = Font.headtitle
        myLabel3.layer.cornerRadius = 25.0
        myLabel3.isUserInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        let separatorLineView3 = UIView(frame: CGRect(x: 150, y: 75, width: 50, height: 2.5))
        separatorLineView3.backgroundColor = .white
        vw.addSubview(separatorLineView3)
        
        return vw
    }
 */
    
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
    
}
