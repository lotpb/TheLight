//
//  FavoriteController.swift
//  TheLight
//
//  Created by Peter Balsamo on 12/29/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit

class Favorite: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?
    
    var pasteBoard = UIPasteboard.general
    var refreshControl: UIRefreshControl!
    var objects = [AnyObject]()
    
    var detailViewController: DetailViewController? = nil
    
    let siteNames = ["CNN", "Drudge", "cnet", "United", "Cult of Mac", "Twits"]
    let siteAddresses = ["http://www.cnn.com",
                         "http://www.Drudgereport.com",
                         "http://www.cnet.com",
                         "http://lotpb.github.io/UnitedWebPage/index.html",
                         "http://www.cultofmac.com/category/news/",
                         "http://stocktwits.com/The_Stock_Whisperer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: view.frame.height))
        titleLabel.text = "Favorites"
        titleLabel.textColor = .white
        //titleLabel.font = Font.navlabel
        titleLabel.textAlignment = NSTextAlignment.center
        navigationItem.titleView = titleLabel
 
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            detailViewController = controllers[controllers.count-1] as? DetailViewController
        }
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.textLabel!.font = Font.celltitlePad
        } else {
            cell.textLabel!.font = Font.celltitle
        }
        
        cell.isSelected = true
        cell.textLabel!.text = siteNames[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
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
        
        if (action == #selector(NSObject.copy)) {
            return true
        }
        return false
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       /*
        if (tableView == self.tableView) {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        } else {
            
        } */
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView?.indexPathForSelectedRow {
                let urlString = siteAddresses[indexPath.row]
                
                let controller = (segue.destination as! UINavigationController).topViewController as! Web
                
                controller.detailItem = urlString as AnyObject?
                controller.navigationItem.leftBarButtonItem =
                    splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    

}