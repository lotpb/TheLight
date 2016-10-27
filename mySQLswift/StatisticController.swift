//
//  StatisticController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/10/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class StatisticController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var scrollWall: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers = [String]()

    var label1 : UILabel!
    var label2 : UILabel!
    var myLabel3 : UILabel!
    var segmentedControl : UISegmentedControl!
    var mytimer: Timer = Timer()
    
    var symYQL: NSArray!
    var tradeYQL: NSArray!
    var changeYQL: NSArray!
    
    var tempYQL: String?
    var weathYQL: String?
    var riseYQL: String?
    var setYQL: String?
    var humYQL: String?
    var cityYQL: String?
    var updateYQL: String?
    
    var dayYQL: NSArray!
    var textYQL: NSArray!
    
    var _feedCustItems : NSMutableArray = NSMutableArray()
    var _feedLeadItems : NSMutableArray = NSMutableArray()
    //var _statHeaderItems : NSMutableArray = NSMutableArray()
    
    //var _feedItems : NSMutableArray = NSMutableArray()
    //var _feedheadItems : NSMutableArray = NSMutableArray()
    //var filteredString : NSMutableArray = NSMutableArray()
    
    //var _feedLeadsToday : NSMutableArray = NSMutableArray()
    //var _feedAppToday : NSMutableArray = NSMutableArray()
    //var _feedAppTomorrow : NSMutableArray = NSMutableArray()
    //var _feedLeadActive : NSMutableArray = NSMutableArray()
    //var _feedLeadYear : NSMutableArray = NSMutableArray()
    
    //var _feedCustToday : NSMutableArray = NSMutableArray()
    //var _feedCustYesterday : NSMutableArray = NSMutableArray()
    //var _feedCustActive : NSMutableArray = NSMutableArray()
    //var _feedWinSold : NSMutableArray = NSMutableArray()
    //var _feedCustYear : NSMutableArray = NSMutableArray()
    //var _feedTESTItems : NSMutableArray = NSMutableArray()
    
    //var dict = NSDictionary()
    //var w1results = NSDictionary()
    //var resultsYQL = NSDictionary()
    //var amount = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("myStats", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 44
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        //self.automaticallyAdjustsScrollViewInsets = false
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(StatisticController.searchButton))
        navigationItem.rightBarButtonItems = [searchButton]
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = Color.Stat.navColor
        self.refreshControl.tintColor = .white
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(StatisticController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
        
        //self.refreshData()
        
        /*
         foundUsers = []
         resultsController = UITableViewController(style: .Plain)
         resultsController.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
         resultsController.tableView.dataSource = self
         resultsController.tableView.delegate = self */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = Color.Stat.navColor
        
        self.refreshData()
        
        //self.mytimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.hidesBarsOnSwipe = false
        //self.mytimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Refresh
    
    func refreshData() {
        self.YahooFinanceLoad()
        self.tableView!.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Button
    
    func newData() {
        self.performSegue(withIdentifier: "newleadSegue", sender: self)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 10
        } else if (section == 1) {
            return 7
        } else if (section == 2) {
            return 5
        } else if (section == 3) {
            return 8
        } else if (section == 4) {
            return 8
        } else {
            if (section == 3) {
                return _feedLeadItems.count
            } else if (section == 4) {
                return _feedCustItems.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier: String = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as UITableViewCell
        
        label1 = UILabel(frame: CGRect(x: tableView.frame.size.width-155, y: 5, width: 77, height: 25))
        label1.textColor = .black
        label1.textAlignment = NSTextAlignment.right
        
        label2 = UILabel(frame: CGRect(x: tableView.frame.size.width-70, y: 5, width: 60, height: 25))
        label2.textColor = .white
        label2.textAlignment = NSTextAlignment.right
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.textLabel!.font = Font.Edittitle
            cell.detailTextLabel!.font = Font.celllabel1
            label1.font = Font.celllabel1
            label2.font = Font.celllike
        } else {
            cell.textLabel!.font = Font.celllabel1
            cell.detailTextLabel!.font = Font.celllabel1
            label1.font = Font.celllabel1
            label2.font = Font.celllike
        }
        
        cell.textLabel!.textColor = .black
        cell.detailTextLabel!.textColor = .black
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessoryType = UITableViewCellAccessoryType.none

        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                if ((changeYQL[0] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[0])"
                label2.text = changeYQL[0] as? String
                label1.text = tradeYQL[0] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                if ((changeYQL[1] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[1])"
                label2.text = changeYQL[1] as? String
                label1.text = tradeYQL[1] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                if ((changeYQL[2] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[2])"
                label2.text = changeYQL[2] as? String
                label1.text = tradeYQL[2] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                if ((changeYQL[3] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[3])"
                label2.text = changeYQL[3] as? String
                label1.text = tradeYQL[3] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 4) {
                
                if ((changeYQL[4] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[4])"
                label2.text = changeYQL[4] as? String
                label1.text = tradeYQL[4] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 5) {
                
                if ((changeYQL[5] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[5])"
                label2.text = changeYQL[5] as? String
                label1.text = tradeYQL[5] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 6) {
                
                if ((changeYQL[6] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[6])"
                label2.text = changeYQL[6] as? String
                label1.text = tradeYQL[6] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 7) {
                
                if ((changeYQL[7] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[7])"
                label2.text = changeYQL[7] as? String
                label1.text = tradeYQL[7] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 8) {
                
                if ((changeYQL[8] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[8])"
                label2.text = changeYQL[8] as? String
                label1.text = tradeYQL[8] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
                
            } else if (indexPath.row == 9) {
                
                if ((changeYQL[9] as AnyObject).contains("-")) {
                    label2.backgroundColor = .red
                } else {
                    label2.backgroundColor = Color.DGreenColor
                }
                cell.textLabel!.text = "\(symYQL[9])"
                label2.text = changeYQL[9] as? String
                label1.text = tradeYQL[9] as? String
                
                cell.contentView.addSubview(label1)
                cell.contentView.addSubview(label2)
                
                return cell
            }
        } else if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Todays Temperature"
                cell.detailTextLabel!.text = "\(tempYQL!)" //w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "Todays Weather"
                cell.detailTextLabel!.text = "\(weathYQL!)" //w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "Sunrise"
                cell.detailTextLabel!.text = "\(riseYQL!)" //w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "Sunset"
                cell.detailTextLabel!.text = "\(setYQL!)" //w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "Humidity"
                cell.detailTextLabel!.text = "\(humYQL!)" //w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 5) {
                
                cell.textLabel!.text = "City"
                cell.detailTextLabel!.text = "\(cityYQL!)" //w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 6) {
                
                cell.textLabel!.text = "Last Update"
                cell.detailTextLabel!.text = "\(updateYQL!)"
                
                return cell
            }
            
        } else if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "\(dayYQL[0])"
                cell.detailTextLabel!.text = "\(textYQL[0])"
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "\(dayYQL[1])"
                cell.detailTextLabel!.text = "\(textYQL[1])"
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "\(dayYQL[2])"
                cell.detailTextLabel!.text = "\(textYQL[2])"
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "\(dayYQL[3])"
                cell.detailTextLabel!.text = "\(textYQL[3])"
                
                return cell
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "\(dayYQL[4])"
                cell.detailTextLabel!.text = "\(textYQL[4])"
                
                return cell
            }
            
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Leads Today"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "Appointment's Today"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "Appointment's Tomorrow"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "Leads Active"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "Leads Year"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 5) {
                
                cell.textLabel!.text = "Leads Avg"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 6) {
                
                cell.textLabel!.text = "Leads High"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 7) {
                
                cell.textLabel!.text = "Leads Low"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            }
            
        } else if (indexPath.section == 4) {
            
            if (indexPath.row == 0) {
                
                cell.textLabel!.text = "Customers Today"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel!.text = "Customers Yesterday"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel!.text = "Windows Sold"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
                
            } else if (indexPath.row == 3) {
                
                cell.textLabel!.text = "Customers Active"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 4) {
                
                cell.textLabel!.text = "Customers Year"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 5) {
                
                cell.textLabel!.text = "Customers Avg"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 6) {
                
                cell.textLabel!.text = "Customers High"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            } else if (indexPath.row == 7) {
                
                cell.textLabel!.text = "Customers Low"
                //cell.detailTextLabel!.text = w1results valueForKeyPath:"query.results.channel.item.condition"] objectForKey:"temp"
                
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return 175
        } else if (section == 1) {
            return 5
        } else if (section == 2) {
            return 5
        } else if (section == 3) {
            return 5
        } else if (section == 4) {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 0) {
            let vw = UIView()
            //vw.frame = CGRectMake(0 , 0, tableView.frame.width, 175)
            vw.backgroundColor = Color.Stat.navColor
            //tableView.tableHeaderView = vw
            /*
             photoImage = UIImageView(frame:CGRectMake(0, 0, vw.frame.size.width, 175))
             photoImage!.image = UIImage(named:"IMG_1133New.jpg")
             photoImage!.clipsToBounds = true
             photoImage!.contentMode = .ScaleAspectFill
             vw.addSubview(photoImage!)
             
             let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
             visualEffectView.frame = photoImage.bounds
             photoImage.addSubview(visualEffectView) */
            
            segmentedControl = UISegmentedControl (items: ["WEEKLY", "MONTHLY", "YEARLY"])
            segmentedControl.frame = CGRect(x: tableView.frame.size.width/2-125, y: 45, width: 250, height: 30)
            segmentedControl.backgroundColor = .red
            segmentedControl.tintColor = .white
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.addTarget(self, action: #selector(StatisticController.segmentedControlAction), for: .valueChanged)
            vw.addSubview(segmentedControl)
            
            let myLabel1 = UILabel(frame: CGRect(x: tableView.frame.size.width/2-45, y: 3, width: 90, height: 45))
            myLabel1.textColor = .white
            myLabel1.textAlignment = NSTextAlignment.center
            myLabel1.text = "Statistics"
            myLabel1.font = UIFont (name: "Avenir-Book", size: 21)
            vw.addSubview(myLabel1)
            
            let myLabel2 = UILabel(frame: CGRect(x: tableView.frame.size.width/2-25, y: 75, width: 50, height: 45))
            myLabel2.textColor = .green
            myLabel2.textAlignment = NSTextAlignment.center
            myLabel2.text = "SALES"
            myLabel2.font = UIFont (name: "Avenir-Black", size: 16)
            vw.addSubview(myLabel2)
            
            let separatorLineView1 = UIView(frame: CGRect(x: tableView.frame.size.width/2-30, y: 110, width: 60, height: 1.9))
            separatorLineView1.backgroundColor = .white
            vw.addSubview(separatorLineView1)
            
            myLabel3 = UILabel(frame: CGRect(x: tableView.frame.size.width/2-70, y: 115, width: 140, height: 45))
            myLabel3.textColor = .white
            myLabel3.textAlignment = NSTextAlignment.center
            myLabel3.text = "$200,000"
            myLabel3.font = UIFont (name: "Avenir-Black", size: 30)
            vw.addSubview(myLabel3)
            
            return vw
        }
        return nil
    }
    
    // MARK: - SegmentedControl
    
    func segmentedControlAction(_ sender: UISegmentedControl) {
        
        if(segmentedControl.selectedSegmentIndex == 0)
        {
            myLabel3.text = "$100,000"
        }
        else if(segmentedControl.selectedSegmentIndex == 1)
        {
            myLabel3.text = "$200,000"
        }
        else if(segmentedControl.selectedSegmentIndex == 2)
        {
            myLabel3.text = "$300,000"
        }
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
        //searchController.searchBar.scopeButtonTitles = ["name", "city", "phone", "date", "active"]
        //tableView!.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        UISearchBar.appearance().barTintColor = Color.Stat.navColor
        
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
         self.foundUsers.removeAll(keepCapacity: false)
         let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
         let array = (self._feedItems as NSArray).filteredArrayUsingPredicate(searchPredicate)
         self.foundUsers = array as! [String]
         self.resultsController.tableView.reloadData() */
    }
    
    
    // MARK: - YahooFinance
    
    func YahooFinanceLoad() {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        //weather
        let results = YQL.query(statement: "select * from weather.forecast where woeid=2446726")
        let queryResults = results?.value(forKeyPath: "query.results.channel") as! NSDictionary?
        if queryResults != nil {
            
            let arr = queryResults!.value(forKeyPath: "item.condition") as? NSDictionary
            tempYQL = arr!.value(forKey: "temp") as? String
            weathYQL = arr!.value(forKey: "text") as? String
            let arr1 = queryResults!.value(forKeyPath: "astronomy") as? NSDictionary
            riseYQL = arr1!.value(forKey: "sunrise") as? String
            setYQL = arr1!.value(forKey: "sunset") as? String
            let arr2 = queryResults!.value(forKeyPath: "atmosphere") as? NSDictionary
            humYQL = arr2!.value(forKey: "humidity") as? String
            let arr3 = queryResults!.value(forKeyPath: "location") as? NSDictionary
            cityYQL = arr3!.value(forKey: "city") as? String
            updateYQL = queryResults!.value(forKey: "lastBuildDate") as? String
            
            //5 day Forcast
            dayYQL = queryResults!.value(forKeyPath: "item.forecast.day") as? NSArray
            textYQL = queryResults!.value(forKeyPath: "item.forecast.text") as? NSArray
        }
        //stocks
        let stockresults = YQL.query(statement: "select * from yahoo.finance.quote where symbol in (\"^IXIC\",\"SPY\",\"UUP\",\"VCSY\",\"GPRO\",\"VXX\",\"UPLMQ\",\"UGAZ\",\"XLE\",\"^XOI\")")
        let querystockResults = stockresults?.value(forKeyPath: "query.results") as! NSDictionary?
        if querystockResults != nil {
            
            symYQL = querystockResults!.value(forKeyPath: "quote.symbol") as? NSArray
            tradeYQL = querystockResults!.value(forKeyPath: "quote.LastTradePriceOnly") as? NSArray
            changeYQL = querystockResults!.value(forKeyPath: "quote.Change") as? NSArray
        }
    }
    
    
}
