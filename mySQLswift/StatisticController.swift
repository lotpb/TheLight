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
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    var foundUsers:[String] = []
    
    var _feedCustItems = NSMutableArray()
    var _feedLeadItems = NSMutableArray()
    
    var segmentedControl : UISegmentedControl!
    //var mytimer: Timer = Timer()
    let defaults = UserDefaults.standard
    
    var dayYQL: NSArray!
    var textYQL: NSArray!
    
    var symYQL: NSArray!
    var tradeYQL: NSArray!
    var changeYQL: NSArray!

    var label1 : UILabel!
    var label2 : UILabel!
    var myLabel3 : UILabel!
    
    var tempYQL: String!
    var weathYQL: String!
    var riseYQL: String!
    var setYQL: String!
    var humYQL: String!
    var cityYQL: String!
    var updateYQL: String!
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight Software - Statistics", for: .normal)
        } else {
            button.setTitle("Statistics", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.Stat.navColor
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
        
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButton))
        navigationItem.rightBarButtonItems = [searchBtn]
        
        setupTableView()
        self.navigationItem.titleView = self.titleButton
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        self.refreshData()
        setupNewsNavigationItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 44
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = Color.LGrayColor
    }
    
    
    // MARK: - Refresh
    
    func refreshData() {
        self.YahooFinanceLoad()
        self.tableView!.reloadData()
        self.refreshControl.endRefreshing()
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as UITableViewCell! else { fatalError("Unexpected Index Path") }

        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.textLabel!.font = Font.Stat.celltitlePad
            cell.detailTextLabel!.font = Font.Stat.celltitlePad
            label1 = UILabel(frame: CGRect(x: tableView.frame.width-170, y: 5, width: 82, height: 25))
            label2 = UILabel(frame: CGRect(x: tableView.frame.width-80, y: 5, width: 65, height: 25))
            label1.font = Font.Stat.celltitlePad
            label2.font = Font.Stat.celltitlePad
        } else {
            cell.textLabel!.font = Font.celltitle16r
            cell.detailTextLabel!.font = Font.celltitle16r
            label1 = UILabel(frame: CGRect(x: tableView.frame.width-155, y: 5, width: 77, height: 25))
            label2 = UILabel(frame: CGRect(x: tableView.frame.width-70, y: 5, width: 60, height: 25))
            label1.font = Font.celltitle16r
            label2.font = Font.celltitle18m
        }
        
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.textLabel!.textColor = .black
        cell.detailTextLabel!.textColor = .black
        label1.textColor = .black
        label1.textAlignment = .right
        label2.textColor = .white
        label2.textAlignment = .right

        if (indexPath.section == 0) {
            
            cell.detailTextLabel!.text = ""
            
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
                if (tempYQL != nil) {
                    cell.detailTextLabel!.text = "\(tempYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Todays Temperature"
                return cell
                
            } else if (indexPath.row == 1) {
                if (weathYQL != nil) {
                    cell.detailTextLabel!.text = "\(weathYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Todays Weather"
                return cell
                
            } else if (indexPath.row == 2) {
                if (riseYQL != nil) {
                    cell.detailTextLabel!.text = "\(riseYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Sunrise"
                return cell
                
            } else if (indexPath.row == 3) {
                if (setYQL != nil) {
                    cell.detailTextLabel!.text = "\(setYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Sunset"
                return cell
            } else if (indexPath.row == 4) {
                if (humYQL != nil) {
                    cell.detailTextLabel!.text = "\(humYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Humidity"
                return cell
            } else if (indexPath.row == 5) {
                if (cityYQL != nil) {
                    cell.detailTextLabel!.text = "\(cityYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "City"
                return cell
            } else if (indexPath.row == 6) {
                if (updateYQL != nil) {
                    cell.detailTextLabel!.text = "\(updateYQL!)"
                } else {
                    cell.detailTextLabel!.text = "Not Available"
                }
                cell.textLabel!.text = "Last Update"
                return cell
            }
            
        } else if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[0])"
                    cell.detailTextLabel!.text = "\(textYQL[0])"
                } else {
                    cell.textLabel!.text = "Day1"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
                
            } else if (indexPath.row == 1) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[1])"
                    cell.detailTextLabel!.text = "\(textYQL[1])"
                } else {
                    cell.textLabel!.text = "Day2"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
                
            } else if (indexPath.row == 2) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[2])"
                    cell.detailTextLabel!.text = "\(textYQL[2])"
                } else {
                    cell.textLabel!.text = "Day3"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
                
            } else if (indexPath.row == 3) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[3])"
                    cell.detailTextLabel!.text = "\(textYQL[3])"
                } else {
                    cell.textLabel!.text = "Day4"
                    cell.detailTextLabel!.text = "Not Available"
                }
                return cell
            } else if (indexPath.row == 4) {
                if (dayYQL != nil) && (textYQL != nil) {
                    cell.textLabel!.text = "\(dayYQL[4])"
                    cell.detailTextLabel!.text = "\(textYQL[4])"
                } else {
                    cell.textLabel!.text = "Day5"
                    cell.detailTextLabel!.text = "Not Available"
                }
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
            return 135
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
            if UI_USER_INTERFACE_IDIOM() == .pad {
                vw.backgroundColor = .black
            } else {
                vw.backgroundColor = Color.Stat.navColor
            }
            //tableView.tableHeaderView = vw
            
            segmentedControl = UISegmentedControl (items: ["WEEKLY", "MONTHLY", "YEARLY"])
            segmentedControl.frame = CGRect(x: tableView.frame.width/2-125, y: 15, width: 250, height: 30)
            segmentedControl.backgroundColor = .red
            segmentedControl.tintColor = .white
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
            vw.addSubview(segmentedControl)
            
            /*
            let myLabel1 = UILabel(frame: CGRect(x: tableView.frame.width/2-45, y: 3, width: 90, height: 45))
            myLabel1.textColor = .white
            myLabel1.textAlignment = .center
            myLabel1.text = "Statistics"
            myLabel1.font = UIFont (name: "Avenir-Book", size: 21)
            vw.addSubview(myLabel1) */
            
            let myLabel2 = UILabel(frame: CGRect(x: tableView.frame.width/2-25, y: 45, width: 50, height: 45))
            myLabel2.textColor = .green
            myLabel2.textAlignment = .center
            myLabel2.text = "SALES"
            myLabel2.font = UIFont (name: "Avenir-Black", size: 16)
            vw.addSubview(myLabel2)
            
            let separatorLineView1 = UIView(frame: CGRect(x: tableView.frame.width/2-30, y: 80, width: 60, height: 1.9))
            separatorLineView1.backgroundColor = .white
            vw.addSubview(separatorLineView1)
            
            myLabel3 = UILabel(frame: CGRect(x: tableView.frame.width/2-70, y: 85, width: 140, height: 45))
            myLabel3.textColor = .white
            myLabel3.textAlignment = .center
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
        tableView.tableFooterView = UIView(frame: .zero)
        UISearchBar.appearance().barTintColor = Color.Stat.navColor
        self.present(searchController, animated: true)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
 
    }
    
    
    // MARK: - YahooFinance
    
    func YahooFinanceLoad() {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        //weather
        //let results = YQL.query(statement: "select * from weather.forecast where woeid=2446726")
        let results = YQL.query(statement: String(format: "%@%@", "select * from weather.forecast where woeid=", self.defaults.string(forKey: "weatherKey")!))
        
        let queryResults = results?.value(forKeyPath: "query.results.channel") as? NSDictionary
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
        let stockresults = YQL.query(statement: "select * from yahoo.finance.quote where symbol in (\"^IXIC\",\"SPY\",\"FB\",\"VCSY\",\"GPRO\",\"VXX\",\"UPLMQ\",\"SWKS\",\"AAPL\",\"^XOI\")")
        let querystockResults = stockresults?.value(forKeyPath: "query.results") as! NSDictionary?
        if querystockResults != nil {
            
            symYQL = querystockResults!.value(forKeyPath: "quote.symbol") as? NSArray
            tradeYQL = querystockResults!.value(forKeyPath: "quote.LastTradePriceOnly") as? NSArray
            changeYQL = querystockResults!.value(forKeyPath: "quote.Change") as? NSArray
        }
    }
    
    
}
