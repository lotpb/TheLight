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
    var filteredString = NSMutableArray()
    var objects = [AnyObject]()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
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
        setupNavigationButtons()
        setupTableView()
        self.navigationItem.titleView = self.titleButton
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = .orange
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationButtons() {
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [trashButton]
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
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
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
