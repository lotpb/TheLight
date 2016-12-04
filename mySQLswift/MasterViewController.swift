//
//  MasterViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAnalytics


class MasterViewController: UITableViewController, UISplitViewControllerDelegate, UISearchResultsUpdating {

  //var detailViewController: DetailViewController? = nil
    
    var menuItems:NSMutableArray = ["Snapshot","Statistics","Leads","Customers","Vendors","Employee","Advertising","Product","Job","Salesman","Show Detail","Music","YouTube","Spot Beacon","Transmit Beacon","Contacts"]
    var currentItem = "Snapshot"
    
    var player : AVAudioPlayer! = nil
    var photoImage: UIImageView!
    var objects = [AnyObject]()
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers = [String]()
    
    let defaults = UserDefaults.standard
    
    var symYQL: NSArray!
    var tradeYQL: NSArray!
    var changeYQL: NSArray!

    var tempYQL: String!
    var textYQL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("Main Menu", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MasterViewController.searchButton))
        let addButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButton))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        
        self.tableView!.backgroundColor = .black
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        foundUsers = []
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        // MARK: - SplitView
        
        self.splitViewController?.delegate = self //added
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.automatic //added
        /*
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        } */
        
        // MARK: - Sound
        
        if (defaults.bool(forKey: "soundKey"))  {
            playSound()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = Color.Lead.navColor
        self.refreshControl!.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl?.addTarget(self, action: #selector(MasterViewController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl!)
        
        symYQL = nil
        tradeYQL = nil
        changeYQL = nil
        self.versionCheck()
        self.refreshData()
        
        // yahoo bad weather warning
        if (defaults.bool(forKey: "weatherKey"))  {
            if (textYQL!.contains("Rain") ||
                textYQL!.contains("Snow") ||
                textYQL!.contains("Thunderstorms") ||
                textYQL!.contains("Showers")) {
                self.simpleAlert(title: "Info", message: "Bad weather today!")
            }
        }

    }
    

    override func viewWillAppear(_ animated: Bool) {
      //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        self.refreshData()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refreshData() {
        self.updateYahoo()
        self.tableView!.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool { //added
        
        return true
    }

    
    // MARK: - Button
    
    func actionButton(_ sender: AnyObject) {
 
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let setting = UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            
            UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
            //UIApplication.shared.openURL(settingsUrl!)
        })
        let buttonTwo = UIAlertAction(title: "Users", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "userSegue", sender: self)
        })
        let buttonThree = UIAlertAction(title: "Notification", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "notificationSegue", sender: self)
        })
        let buttonFour = UIAlertAction(title: "Membership Card", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "codegenSegue", sender: self)
        })
        let buttonSocial = UIAlertAction(title: "Social", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "socialSegue", sender: self)
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            //print("Cancel Button Pressed")
        }
        
        alertController.addAction(setting)
        alertController.addAction(buttonTwo)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonFour)
        alertController.addAction(buttonSocial)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func statButton() {
        
        self.performSegue(withIdentifier: "statisticSegue", sender: self)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return menuItems.count
        }
        return foundUsers.count
        //return filteredString.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView{
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            cell.textLabel!.font = Font.celltitle
            
        } else {
            
            cell.textLabel!.font = Font.celltitle
        }
        
        if (tableView == self.tableView) {
            
            cell.textLabel!.text = menuItems[indexPath.row] as? String
            
        } else {
            
            cell.textLabel!.text = self.foundUsers[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            return 135.0
        } else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        tableView.tableHeaderView = vw
        
        photoImage = UIImageView(frame:CGRect(x: 0, y: 0, width: tableView.tableHeaderView!.frame.size.width, height: 135))
        photoImage.image = UIImage(named:"IMG_1133.jpg")
        photoImage.layer.masksToBounds = true
        photoImage.contentMode = .scaleAspectFill
        vw.addSubview(photoImage)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = photoImage.bounds
        photoImage.addSubview(visualEffectView)

        
        let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 15, width: 60, height: 60))
        myLabel1.numberOfLines = 0
        myLabel1.backgroundColor = .white
        myLabel1.textColor = .black
        myLabel1.textAlignment = NSTextAlignment.center
        myLabel1.layer.masksToBounds = true
        myLabel1.text = String(format: "%@%d", "COUNT\n", menuItems.count)
        myLabel1.font = Font.headtitle
        myLabel1.layer.cornerRadius = 30.0
        myLabel1.isUserInteractionEnabled = true
        vw.addSubview(myLabel1)
        
        let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 95, width: 60, height: 3.5))
        separatorLineView1.backgroundColor = .green
        vw.addSubview(separatorLineView1)
        
        let myLabel2:UILabel = UILabel(frame: CGRect(x: 85, y: 15, width: 60, height: 60))
        myLabel2.numberOfLines = 0
        myLabel2.backgroundColor = .white
        myLabel2.textColor = .black
        myLabel2.textAlignment = NSTextAlignment.center
        myLabel2.layer.masksToBounds = true
        myLabel2.text = "NASDAQ \n \(tradeYQL![0])"
        myLabel2.font = Font.headtitle
        myLabel2.layer.cornerRadius = 30.0
        myLabel2.isUserInteractionEnabled = true
        vw.addSubview(myLabel2)
        
        let myLabel25:UILabel = UILabel(frame: CGRect(x: 85, y: 75, width: 60, height: 20))
        myLabel25.numberOfLines = 1
        myLabel25.textAlignment = NSTextAlignment.center
        myLabel25.text = " \(changeYQL![0])"
        myLabel25.font = Font.headtitle
        vw.addSubview(myLabel25)
        
        
        let separatorLineView2 = UIView(frame: CGRect(x: 85, y: 95, width: 60, height: 3.5))
        if (changeYQL?[0] != nil) {
            separatorLineView2.backgroundColor = .red
            myLabel25.textColor = .red
        } else if (changeYQL![0] as AnyObject).contains("-") {
            separatorLineView2.backgroundColor = .red
            myLabel25.textColor = .red
        } else {
            separatorLineView2.backgroundColor = .green
            myLabel25.textColor = .green
        }
        vw.addSubview(separatorLineView2)
        
        
        let myLabel3:UILabel = UILabel(frame: CGRect(x: 160, y: 15, width: 60, height: 60))
        myLabel3.numberOfLines = 0
        myLabel3.backgroundColor = .white
        myLabel3.textColor = .black
        myLabel3.textAlignment = NSTextAlignment.center
        myLabel3.layer.masksToBounds = true
        myLabel3.text = "S&P 500 \n \(tradeYQL![1])"
        myLabel3.font = Font.headtitle
        myLabel3.layer.cornerRadius = 30.0
        myLabel3.isUserInteractionEnabled = true
        vw.addSubview(myLabel3)
        
        let myLabel35:UILabel = UILabel(frame: CGRect(x: 160, y: 75, width: 60, height: 20))
        myLabel35.numberOfLines = 1
        myLabel35.textAlignment = NSTextAlignment.center
        myLabel35.text = " \(changeYQL![1])"
        myLabel35.font = Font.Weathertitle
        vw.addSubview(myLabel35)
        
        let separatorLineView3 = UIView(frame: CGRect(x: 160, y: 95, width: 60, height: 3.5))
        if (changeYQL?[1] != nil) {
            separatorLineView3.backgroundColor = .red
            myLabel35.textColor = .red
        } else if (changeYQL![1] as AnyObject).contains("-") {
            separatorLineView3.backgroundColor = .red
            myLabel35.textColor = .red
        } else {
            separatorLineView3.backgroundColor = .green
            myLabel35.textColor = .green
        }
        vw.addSubview(separatorLineView3)
        
        let myLabel4:UILabel = UILabel(frame: CGRect(x: 10, y: 105, width: 280, height: 20))
        myLabel4.text = String(format: "%@ %@ %@", "Weather:", "\(tempYQL!)°", "\(textYQL!)")
        myLabel4.font = Font.Weathertitle
        if (textYQL!.contains("Rain") ||
            textYQL!.contains("Snow") ||
            textYQL!.contains("Thunderstorms") ||
            textYQL!.contains("Showers")) {
            myLabel4.textColor = .red
        } else {
            myLabel4.textColor = .green
        }
        vw.addSubview(myLabel4) 
        
        /* //Statistic Button
        let statButton:UIButton = UIButton(frame: CGRect(x: tableView.frame.width-100, y: 95, width: 90, height: 30))
        statButton.setTitle("Statistics", for: UIControlState())
        statButton.backgroundColor = Color.MGrayColor
        statButton.setTitleColor(UIColor.white, for: UIControlState())
        statButton.addTarget(self, action:#selector(MasterViewController.statButton), for: UIControlEvents.touchUpInside)
        statButton.layer.cornerRadius = 15.0
        statButton.layer.borderColor = UIColor.black.cgColor
        statButton.layer.borderWidth = 1.0
        vw.addSubview(statButton) */
 
        return vw
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
     // MARK: - playSound
    
    func playSound() {
        
        let audioPath = Bundle.main.path(forResource: "MobyDick", ofType: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }
        catch {
            self.simpleAlert(title: "Alert", message: "Something bad happened. Try catching specific errors to narrow things down")
        }
        player.play()
        
    }
    
    
    // MARK: - upDate
    
    func versionCheck() {
        
        let query = PFQuery(className:"Version")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            
            let versionId = object?.value(forKey: "VersionId") as! String?
            if (versionId != self.defaults.string(forKey: "versionKey")) {
                
                DispatchQueue.main.async {
                self.simpleAlert(title: "New Version!", message: "A new version of app is available to download")
                }
            }
        }
    }
    
    
    // MARK: - updateYahoo
    
    func updateYahoo() {
        
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        //weather
      //let results = YQL.query(statement: "select * from weather.forecast where woeid=2446726")
        let results = YQL.query(statement: String(format: "%@%@", "select * from weather.forecast where woeid=", self.defaults.string(forKey: "weatherKey")!))
        
        let queryResults = results?.value(forKeyPath: "query.results.channel.item") as! NSDictionary?
        if queryResults != nil {
            
            let weatherInfo = queryResults!["condition"] as? NSDictionary
            tempYQL = weatherInfo?.object(forKey: "temp") as? String
            textYQL = weatherInfo?.object(forKey: "text") as? String
        }
        //stocks
        let stockresults = YQL.query(statement: "select * from yahoo.finance.quote where symbol in (\"^IXIC\",\"SPY\")")
        let querystockResults = stockresults?.value(forKeyPath: "query.results") as? NSDictionary?
        if querystockResults != nil {
            
            symYQL = querystockResults!?.value(forKeyPath: "quote.symbol") as? NSArray
            tradeYQL = querystockResults!?.value(forKeyPath: "quote.LastTradePriceOnly") as? NSArray
            changeYQL = querystockResults!?.value(forKeyPath: "quote.Change") as? NSArray
        } 
    }
    
    // MARK: - Logout
    
    func handleSignOut() {
        PFUser.logOut()
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        self.performSegue(withIdentifier: "showLogin", sender: self)
        
    }
    
    
    // MARK: - Search
    
    func searchButton(_ sender: AnyObject) {
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsBookmarkButton = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = true
        //tableView!.tableHeaderView = searchController.searchBar
        tableView!.tableFooterView = UIView(frame: .zero)
        UISearchBar.appearance().barTintColor = .black
        self.present(searchController, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.foundUsers.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.menuItems as NSArray).filtered(using: searchPredicate)
        self.foundUsers = array as! [String]
        self.resultsController.tableView.reloadData()
    }

    
    // MARK: - Segues
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            currentItem = menuItems[(selectedIndexPath as NSIndexPath).row] as! String
        }
        
        if tableView == resultsController.tableView {
            //userDetails = foundUsers[indexPath.row]
            //self.performSegueWithIdentifier("PushDetailsVC", sender: self)
        } else {
            
            if (currentItem == "Snapshot") {
                self.performSegue(withIdentifier: "snapshotSegue", sender: self)
            } else if (currentItem == "Statistics") {
                self.performSegue(withIdentifier: "statisticSegue", sender: self)
            } else if (currentItem == "Leads") {
                self.performSegue(withIdentifier: "showleadSegue", sender: self)
            } else if (currentItem == "Customers") {
                self.performSegue(withIdentifier: "showcustSegue", sender: self)
            } else if (currentItem == "Vendors") {
                self.performSegue(withIdentifier: "showvendSegue", sender: self)
            } else if (currentItem == "Employee") {
                self.performSegue(withIdentifier: "showemployeeSegue", sender: self)
            } else if (currentItem == "Advertising") {
                self.performSegue(withIdentifier: "showadSegue", sender: self)
            } else if (currentItem == "Product") {
                self.performSegue(withIdentifier: "showproductSegue", sender: self)
            } else if (currentItem == "Job") {
                self.performSegue(withIdentifier: "showjobSegue", sender: self)
            } else if (currentItem == "Salesman") {
                self.performSegue(withIdentifier: "showsalesmanSegue", sender: self)
            } else if (currentItem == "Show Detail") {
                self.performSegue(withIdentifier: "showDetail", sender: self)
            } else if (currentItem == "Music") {
                self.performSegue(withIdentifier: "musicSegue", sender: self)
            } else if (currentItem == "YouTube") {
                self.performSegue(withIdentifier: "youtubeSegue", sender: self)
            } else if (currentItem == "Spot Beacon") {
                self.performSegue(withIdentifier: "spotbeaconSegue", sender: self)
            } else if (currentItem == "Transmit Beacon") {
                self.performSegue(withIdentifier: "transmitbeaconSegue", sender: self)
            } else if (currentItem == "Contacts") {
                self.performSegue(withIdentifier: "contactSegue", sender: self)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}

