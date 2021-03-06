//
//  GetAddress.swift
//  Geotify
//
//  Created by Peter Balsamo on 2/22/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit
import MapKit

class GetAddress: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  
  @IBOutlet weak var tableView: UITableView?
  
  var thoroughfare: String?
  var subThoroughfare: String?
  var locality: String?
  var sublocality: String?
  var postalCode: String?
  var administrativeArea: String?
  var subAdministrativeArea: String?
  var country: String?
  var ISOcountryCode: String?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView!.delegate = self
    self.tableView!.dataSource = self
    self.tableView!.rowHeight = 65
    self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
    self.automaticallyAdjustsScrollViewInsets = false
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.tintColor = UIColor.white
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Table View
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 9
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                             for: indexPath)
    
    cell.selectionStyle = .none
    cell.detailTextLabel!.textColor = UIColor.lightGray
    
    if UI_USER_INTERFACE_IDIOM() == .pad {
        
        cell.textLabel!.font = Font.celltitle22m
        cell.detailTextLabel!.font = Font.celltitle16r
        
    } else {
        
        cell.textLabel!.font = Font.celltitle20l
        cell.detailTextLabel!.font =  Font.celltitle16r
    }
    
    if ((indexPath as NSIndexPath).row == 0) {
      cell.textLabel!.text = subThoroughfare
      cell.detailTextLabel!.text = "subThoroughfare"
    }
    
    if ((indexPath as NSIndexPath).row == 1) {
      cell.textLabel!.text = thoroughfare
      cell.detailTextLabel!.text = "thoroughfare"
    }
    
    if ((indexPath as NSIndexPath).row == 2) {
      cell.textLabel!.text = sublocality
      cell.detailTextLabel!.text = "sublocality"
    }
    
    if ((indexPath as NSIndexPath).row == 3) {
      cell.textLabel!.text = locality
      cell.detailTextLabel!.text = "locality"
    }

    if ((indexPath as NSIndexPath).row == 6) {
      cell.textLabel!.text = administrativeArea
      cell.detailTextLabel!.text = "administrativeArea"
    }
    
    if ((indexPath as NSIndexPath).row == 4) {
        cell.textLabel!.text = postalCode
        cell.detailTextLabel!.text = "postalCode"
    }
    
    if ((indexPath as NSIndexPath).row == 5) {
        cell.textLabel!.text = subAdministrativeArea
        cell.detailTextLabel!.text = "subAdministrativeArea"
    }
    
    if ((indexPath as NSIndexPath).row == 7) {
      cell.textLabel!.text = country
      cell.detailTextLabel!.text = "country"
    }
    
    if ((indexPath as NSIndexPath).row == 8) {
      cell.textLabel!.text = ISOcountryCode
      cell.detailTextLabel!.text = "countryCode"
    }

    return cell
  }
  
}
