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
import Firebase
import SwiftKeychainWrapper


class MasterViewController: UITableViewController, UISplitViewControllerDelegate {

    fileprivate var collapseDetailViewController = true
    
    var menuItems: NSMutableArray = ["Snapshot","Statistics","Leads","Customers","Vendors","Employee","Advertising","Product","Job","Salesman","Geotify","Show Detail","Music","YouTube","Spot Beacon","Transmit Beacon","Contacts"]
    var currentItem = "Snapshot"
    
    var player : AVAudioPlayer! = nil
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
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("Main Menu", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let photoImage: CustomImageView = { //tableheader
        let imageView = CustomImageView(image: #imageLiteral(resourceName: "IMG_1133"))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView
        self.splitViewController?.maximumPrimaryColumnWidth = 400
        //fixed - remove bottom bar
        self.splitViewController!.delegate = self
        self.splitViewController!.preferredDisplayMode = .allVisible
        self.extendedLayoutIncludesOpaqueBars = true
        
        versionCheck()
        setupNavigationButtons()
        speech()
        setupTableView()
        updateYahoo()
        fetchUserIds()
        self.navigationItem.titleView = self.titleButton
        
        // MARK: - Sound
        
        if (defaults.bool(forKey: "soundKey"))  {
            playSound()
        }
        
        // yahoo bad weather warning
        if (defaults.bool(forKey: "weatherNotifyKey"))  {
            guard let severeYQL = textYQL else { return }
            if (severeYQL.contains("Rain") || severeYQL.contains("Snow") || severeYQL.contains("Thunderstorms") || severeYQL.contains("Showers")) {
                
                DispatchQueue.main.async {
                    self.simpleAlert(title: severeYQL, message: "Bad weather today!")
                }
            }
        }
        
        self.refreshControl?.backgroundColor = Color.Lead.navColor
        self.refreshControl?.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
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
    
    //added makes MainController opens on startup instead of DetailViewController
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    } 
    
    func setupNavigationButtons() {
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButton))
        let addBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButton))
        navigationItem.rightBarButtonItems = [addBtn, searchBtn]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
    }
    
    func setupTableView() {
        self.tableView!.backgroundColor = Color.LGrayColor //.black
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    func refreshData() {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            self.updateYahoo()
        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    
    // MARK: - Button
    
    func actionButton(_ sender: AnyObject) {
 
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let setting = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)

            UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
        })
        let buttonTwo = UIAlertAction(title: "Users", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "userSegue", sender: self)
        })
        let buttonThree = UIAlertAction(title: "Notification", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "notificationSegue", sender: self)
        })
        let buttonFour = UIAlertAction(title: "Membership Card", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "codegenSegue", sender: self)
        })
        let buttonSocial = UIAlertAction(title: "Social", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "socialSegue", sender: self)
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
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
        self.present(alertController, animated: true)
    }


    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if (section == 0) {
                return 2
            } else if (section == 1) {
                return 8
            } else if (section == 2) {
                return 7
            }
        } else {
            return foundUsers.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if tableView == self.tableView {
            cellIdentifier = "Cell"
        } else {
            cellIdentifier = "UserFoundCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.textLabel!.font = Font.celltitle22m
        } else {
            cell.textLabel!.font = Font.celltitle20l
        }
        
        if (tableView == self.tableView) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[0] as? String
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[1] as? String
                }
                
            } else if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[2] as? String
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[3] as? String
                } else if (indexPath.row == 2) {
                    cell.textLabel!.text = menuItems[4] as? String
                } else if (indexPath.row == 3) {
                    cell.textLabel!.text = menuItems[5] as? String
                } else if (indexPath.row == 4) {
                    cell.textLabel!.text = menuItems[6] as? String
                } else if (indexPath.row == 5) {
                    cell.textLabel!.text = menuItems[7] as? String
                } else if (indexPath.row == 6) {
                    cell.textLabel!.text = menuItems[8] as? String
                } else if (indexPath.row == 7) {
                    cell.textLabel!.text = menuItems[9] as? String
                }
                
            } else if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    cell.textLabel!.text = menuItems[10] as? String
                } else if (indexPath.row == 1) {
                    cell.textLabel!.text = menuItems[11] as? String
                } else if (indexPath.row == 2) {
                    cell.textLabel!.text = menuItems[12] as? String
                } else if (indexPath.row == 3) {
                    cell.textLabel!.text = menuItems[13] as? String
                } else if (indexPath.row == 4) {
                    cell.textLabel!.text = menuItems[14] as? String
                } else if (indexPath.row == 5) {
                    cell.textLabel!.text = menuItems[15] as? String
                } else if (indexPath.row == 6) {
                    cell.textLabel!.text = menuItems[16] as? String
                }
            }
            
        } else {
            
            cell.textLabel!.text = self.foundUsers[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            if UI_USER_INTERFACE_IDIOM() == .phone {
                return 145.0
            } else {
                return 0
            }
        } else if (section == 1) {
            return 10
        } else if (section == 2) {
            return 10
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            if UI_USER_INTERFACE_IDIOM() == .phone {
                
                let vw = UIView()
                vw.backgroundColor = .black
                //tableView.tableHeaderView = vw
                
                /*
                photoImage.frame = CGRect(x: 0, y: 0, width: tableView..frame.size.width, height: 145)
                vw.addSubview(photoImage)
                
                let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                visualEffectView.frame = photoImage.bounds
                photoImage.addSubview(visualEffectView) */
                
                let myLabel1:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 74, height: 74))
                myLabel1.numberOfLines = 0
                myLabel1.backgroundColor = .white
                myLabel1.textColor = Color.goldColor
                myLabel1.textAlignment = .center
                myLabel1.text = String(format: "%@%d", "COUNT\n", menuItems.count )
                myLabel1.font = Font.celltitle14m
                myLabel1.layer.cornerRadius = 37.0
                myLabel1.layer.borderColor = Color.Header.headtextColor.cgColor
                myLabel1.layer.borderWidth = 1
                myLabel1.layer.masksToBounds = true
                myLabel1.isUserInteractionEnabled = true
                vw.addSubview(myLabel1)
                
                let myLabel15:UILabel = UILabel(frame: CGRect(x: 10, y: 85, width: 74, height: 20))
                myLabel15.numberOfLines = 1
                myLabel15.textAlignment = .center
                myLabel15.textColor = .green
                if (defaults.bool(forKey: "parsedataKey")) {
                    myLabel15.text = "Back4app"
                } else {
                    myLabel15.text = "Firebase"
                }
                myLabel15.font = Font.celltitle14m
                vw.addSubview(myLabel15)
                
                let separatorLineView1 = UIView(frame: CGRect(x: 10, y: 105, width: 74, height: 3.5))
                separatorLineView1.backgroundColor = .green
                vw.addSubview(separatorLineView1)
                
                let myLabel2:UILabel = UILabel(frame: CGRect(x: 110, y: 10, width: 74, height: 74))
                myLabel2.numberOfLines = 0
                myLabel2.backgroundColor = .white
                myLabel2.textColor = Color.goldColor
                myLabel2.textAlignment = .center
                myLabel2.text = "NASDAQ \n \(tradeYQL?[0] ?? "na")"
                myLabel2.font = Font.celltitle14m
                myLabel2.layer.cornerRadius = 37.0
                myLabel2.layer.borderColor = Color.Header.headtextColor.cgColor
                myLabel2.layer.borderWidth = 1
                myLabel2.layer.masksToBounds = true
                myLabel2.isUserInteractionEnabled = true
                vw.addSubview(myLabel2)
                
                let myLabel25:UILabel = UILabel(frame: CGRect(x: 110, y: 85, width: 74, height: 20))
                myLabel25.numberOfLines = 1
                myLabel25.textAlignment = .center
                myLabel25.text = "\(changeYQL?[0] ?? "na")"
                myLabel25.font = Font.celltitle14m
                vw.addSubview(myLabel25)
                
                let separatorLineView2 = UIView(frame: CGRect(x: 110, y: 105, width: 74, height: 3.5))
                if (changeYQL?[0] as AnyObject).contains("-") {
                    separatorLineView2.backgroundColor = .red
                    myLabel25.textColor = .red
                } else {
                    separatorLineView2.backgroundColor = .green
                    myLabel25.textColor = .green
                }
                vw.addSubview(separatorLineView2)
                
                let myLabel3:UILabel = UILabel(frame: CGRect(x: 210, y: 10, width: 74, height: 74))
                myLabel3.numberOfLines = 0
                myLabel3.backgroundColor = .white
                myLabel3.textColor = Color.goldColor
                myLabel3.textAlignment = .center
                myLabel3.text = "S&P 500 \n \(tradeYQL?[1] ?? "na")"
                myLabel3.font = Font.celltitle14m
                myLabel3.layer.cornerRadius = 37.0
                myLabel3.layer.borderColor = Color.Header.headtextColor.cgColor
                myLabel3.layer.borderWidth = 1
                myLabel3.layer.masksToBounds = true
                myLabel3.isUserInteractionEnabled = true
                vw.addSubview(myLabel3)
                
                let myLabel35:UILabel = UILabel(frame: CGRect(x: 210, y: 85, width: 74, height: 20))
                myLabel35.numberOfLines = 1
                myLabel35.textAlignment = .center
                myLabel35.text = "\(changeYQL?[1] ?? "na")"
                myLabel35.font = Font.celltitle14m
                vw.addSubview(myLabel35)
                
                let separatorLineView3 = UIView(frame: CGRect(x: 210, y: 105, width: 74, height: 3.5))
                
                if (changeYQL![1] as AnyObject).contains("-") {
                    separatorLineView3.backgroundColor = .red
                    myLabel35.textColor = .red
                } else {
                    separatorLineView3.backgroundColor = .green
                    myLabel35.textColor = .green
                }
                vw.addSubview(separatorLineView3)
                
                let myLabel4:UILabel = UILabel(frame: CGRect(x: 10, y: 115, width: 280, height: 20))
                if (tempYQL != nil) && (textYQL != nil) {
                    myLabel4.text = String(format: "%@ %@ %@", "Weather:", "\(tempYQL!)°", "\(textYQL!)")
                    if (textYQL!.contains("Rain") ||
                        textYQL!.contains("Snow") ||
                        textYQL!.contains("Thunderstorms") ||
                        textYQL!.contains("Showers")) {
                        myLabel4.textColor = .red
                    } else {
                        myLabel4.textColor = .green
                    }
                } else {
                    myLabel4.text = "Weather not available"
                    myLabel4.textColor = .red
                }
                myLabel4.font = Font.celltitle16l
                vw.addSubview(myLabel4)
 
                return vw 
            }
        }
        return nil
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
    
    // MARK: - speech
    
    func speech() {
        
        let utterance = AVSpeechUtterance(string: "Greetings from TheLight Software")
        utterance.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        utterance.rate = 0.4
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    // MARK: - VersionCheck
    
    func versionCheck() {
        
        let query = PFQuery(className:"Version")
        query.cachePolicy = .cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            
            guard let versionId = object?.value(forKey: "VersionId") as! String? else {
                print("No VersionID")
                return
            }
            if (versionId != self.defaults.string(forKey: "versionKey")) {
                
                DispatchQueue.main.async {
                self.simpleAlert(title: "New Version!", message: "A new version of app is available to download")
                }
            }
        }
    }
    
    // MARK: - updateYahoo
    
    func updateYahoo() {
        
        //guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        //weather
        let results = YQL.query(statement: String(format: "%@%@", "select * from weather.forecast where woeid=", self.defaults.string(forKey: "weatherKey")!))
        
        let queryResults = results?.value(forKeyPath: "query.results.channel.item") as? NSDictionary
        if queryResults != nil {
            
            let weatherInfo = queryResults!["condition"] as? NSDictionary
            tempYQL = weatherInfo?.object(forKey: "temp") as? String ?? ""
            textYQL = weatherInfo?.object(forKey: "text") as? String ?? ""
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
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutErr {
            print(signOutErr)
        }
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    fileprivate func fetchUserIds() {
        
        // MARK: - Login
        let userId:String = defaults.object(forKey: "usernameKey") as! String!
        let userpassword:String = defaults.object(forKey: "passwordKey") as! String!
        let userSuccessful: Bool = KeychainWrapper.standard.set(userId, forKey: "usernameKey")
        let passSuccessful: Bool = KeychainWrapper.standard.set(userpassword, forKey: "passwordKey")
        
        // MARK: - Keychain
        if (userSuccessful == true), (passSuccessful == true) {
            print("Keychain successful")
        } else {
            print("Keychain failed")
        }
        //KeychainWrapper.accessGroup = "group.TheLightGroup"
        // MARK: - Parse
        if (defaults.bool(forKey: "parsedataKey")) {
            
            PFUser.logInWithUsername(inBackground: userId, password:userpassword) { (user, error) in
                if error != nil {
                    print("Error: \(String(describing: error)) \(String(describing: error!._userInfo))")
                    return
                }
            }
            
        } else {
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
            FIRDatabase.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
                userIdsDictionary.forEach({ (key, value) in
                    FIRDatabase.fetchUserWithUID(uid: key, completion: { (user) in
                            //self.fetchPostsWithUser(user: user)
                    })
                })
            }) { (err) in
                print("Failed to fetch following user ids ", err)
            }
        }
    
    }

    
    // MARK: - Segues
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        let currentItem = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        if (tableView == self.tableView) {
            
            if (currentItem.textLabel!.text! == "Snapshot") {
                self.performSegue(withIdentifier: "snapshotSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Statistics") {
                self.performSegue(withIdentifier: "statisticSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Leads") {
                self.performSegue(withIdentifier: "showleadSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Customers") {
                self.performSegue(withIdentifier: "showcustSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Vendors") {
                self.performSegue(withIdentifier: "showvendSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Employee") {
                self.performSegue(withIdentifier: "showemployeeSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Advertising") {
                self.performSegue(withIdentifier: "showadSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Product") {
                self.performSegue(withIdentifier: "showproductSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Job") {
                self.performSegue(withIdentifier: "showjobSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Salesman") {
                self.performSegue(withIdentifier: "showsalesmanSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Geotify") {
                self.performSegue(withIdentifier: "geotifySegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Show Detail") {
                self.performSegue(withIdentifier: "showDetail", sender: self)
            } else if (currentItem.textLabel!.text! == "Music") {
                self.performSegue(withIdentifier: "musicSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "YouTube") {
                self.performSegue(withIdentifier: "youtubeSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Spot Beacon") {
                self.performSegue(withIdentifier: "spotbeaconSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Transmit Beacon") {
                self.performSegue(withIdentifier: "transmitbeaconSegue", sender: self)
            } else if (currentItem.textLabel!.text! == "Contacts") {
                self.performSegue(withIdentifier: "contactSegue", sender: self)
            }
        } else {
  
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "snapshotSegue" {

        }
        if segue.identifier == "statisticSegue" {
            /*
            guard let navController = segue.destination as? UINavigationController,
                let viewController = navController.topViewController as? StatisticController else {
                    fatalError("Expected StatisticController")
            }
            //collapseDetailViewController = false
            viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true */
        }
        if segue.identifier == "geotifySegue" {
            
            guard let navController = segue.destination as? UINavigationController,
                let controller = navController.topViewController as? GeotificationsViewController
                else {
                    fatalError("Expected GeotificationsViewController")
            }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "musicSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! MusicController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "youtubeSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! YouTubeController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "spotbeaconSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! SpotBeaconController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "transmitbeaconSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! TransmitBeaconController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "contactSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! ContactController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }

    }
}
//-----------------------end------------------------------

// MARK: - UISearchBar Delegate
extension MasterViewController: UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.barTintColor = .black
        tableView!.tableFooterView = UIView(frame: .zero)
        self.present(searchController, animated: true)
    }
}

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        self.foundUsers.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.menuItems as NSArray).filtered(using: searchPredicate)
        self.foundUsers = array as! [String]
        self.resultsController.tableView.reloadData()
    }
}




