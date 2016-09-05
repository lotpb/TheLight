//
//  LeadDetail.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/10/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import ContactsUI
import EventKit
import MessageUI

class LeadDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    
    let ipadname = UIFont.systemFont(ofSize: 30, weight: UIFontWeightLight)
    let ipaddate = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    let ipadaddress = UIFont.systemFont(ofSize: 26, weight: UIFontWeightLight)
    let ipadAmount = UIFont.systemFont(ofSize: 36, weight: UIFontWeightRegular)
    
    let textname = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
    let textdate = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    let textaddress = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
    let textAmount = UIFont.systemFont(ofSize: 30, weight: UIFontWeightRegular)
    
    let Vtextname = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    let Vtextdate = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
    let VtextAmount = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
    
    let celltitle = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
    let cellsubtitle = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
    
    let newstitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
    let newssubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
    let newsdetail = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
    
    let textbutton = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    
    var tableData : NSMutableArray = NSMutableArray()
    var tableData2 : NSMutableArray = NSMutableArray()
    var tableData3 : NSMutableArray = NSMutableArray()
    var tableData4 : NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var scrollWall: UIScrollView?
    @IBOutlet weak var mainView: UIView?
    @IBOutlet weak var tableView: UIView?
    @IBOutlet weak var mySwitch: UISwitch?
    @IBOutlet weak var activebutton: UIButton?
    @IBOutlet weak var mapbutton: UIButton?
    
    @IBOutlet weak var listTableView: UITableView?
    @IBOutlet weak var listTableView2: UITableView?
    @IBOutlet weak var newsTableView: UITableView?
    
    @IBOutlet private weak var labelNo: UILabel?
    @IBOutlet private weak var labelname: UILabel?
    @IBOutlet private weak var labelamount: UILabel?
    @IBOutlet private weak var labeldate: UILabel?
    @IBOutlet private weak var labeladdress: UILabel?
    @IBOutlet private weak var labelcity: UILabel?
    @IBOutlet private weak var following: UILabel?
    @IBOutlet private weak var labeldatetext: UILabel?
    
    var formController : String?
    var status : String?
    
    var objectId : String?
    var custNo : String?
    var leadNo : String?
    var date : String?
    var name : String?
    var address : String?
    var city : String?
    var state : String?
    var zip : String?
    var amount : String?
    var tbl11 : String?
    var tbl12 : String?
    var tbl13 : String?
    var tbl14 : String?
    var tbl15 : NSString?
    var tbl16 : String?
    var tbl21 : NSString?
    var tbl22 : String?
    var tbl23 : String!
    var tbl24 : String?
    var tbl25 : String?
    var tbl26 : NSString?
    var tbl27 : String? //employee company
    var photo : String?
    var comments : String?
    var active : String?
    
    var t11 : String?
    var t12 : String?
    var t13 : String?
    var t14 : String?
    var t15 : NSString?
    var t16 : String?
    var t21 : NSString?
    var t22 : String?
    var t23 : String!
    var t24 : String?
    var t25 : String?
    var t26 : NSString?
    
    var l1datetext : String?
    var lnewsTitle : String?
    
    var l11 : String?
    var l12 : String?
    var l13 : String?
    var l14 : String?
    var l15 : String?
    var l16 : String?
    
    var l21 : String?
    var l22 : String?
    var l23 : String?
    var l24 : String?
    var l25 : String?
    var l26 : String?
    
    var p1 : String?
    var p12 : String?
    var complete : String?
    var salesman : String?
    var jobdescription : String?
    var advertiser : String?
    
    var savedEventId : String?
    
    var getEmail : String?
    var emailTitle :String?
    var messageBody:String?
    
    var photoImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle(String(format: "%@ %@", self.formController!, "Form"), for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.listTableView!.rowHeight = 30
        self.listTableView2!.rowHeight = 30
        self.newsTableView!.estimatedRowHeight = 100
        self.newsTableView!.rowHeight = UITableViewAutomaticDimension
        self.newsTableView!.tableFooterView = UIView(frame: .zero)
        
        emailTitle = defaults.string(forKey: "emailtitleKey")
        messageBody = defaults.string(forKey: "emailmessageKey")
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            labelamount!.font = ipadAmount
            labelname!.font = ipadname
            labeldate!.font = ipaddate
            labeladdress!.font = ipadaddress
            labelcity!.font = ipadaddress
            mapbutton!.titleLabel?.font = textbutton
            
        } else {
            
            labeladdress!.font = textaddress
            labelcity!.font = textaddress
            mapbutton!.titleLabel?.font = textbutton
            
            if (self.formController == "Vendor" || self.formController == "Employee") {
                labelamount!.font = VtextAmount
                labeldate!.font = Vtextdate
            } else {
                labelamount!.font = textAmount
                labeldate!.font = textdate
            }
            
            if self.formController == "Vendor" {
                labelname!.font = Vtextname
            } else {
                labelname!.font = textname
            }
        }
        
        if (self.formController == "Leads") {
            if (self.tbl11 == "Sold") {
                self.mySwitch!.setOn(true, animated:true)
            } else {
                self.mySwitch!.setOn(false, animated:true)
            }
        }
        
        self.mySwitch!.onTintColor = Color.BlueColor
        self.mySwitch!.tintColor = .lightGray

        photoImage = UIImageView(frame:CGRect(x: self.view.frame.size.width/2+15, y: 60, width: self.view.frame.size.width/2-25, height: 110))
        photoImage!.image = UIImage(named:"IMG_1133.jpg")
        photoImage!.layer.contentsGravity = kCAGravityResize
        photoImage!.layer.masksToBounds = true
        photoImage!.layer.borderColor = UIColor.lightGray.cgColor
        photoImage!.layer.borderWidth = 1.0
        photoImage!.isUserInteractionEnabled = true
        self.mainView!.addSubview(photoImage!) 
        
        self.mapbutton!.backgroundColor = Color.BlueColor
        self.mapbutton!.setTitleColor(.white, for: UIControlState())
        self.mapbutton!.addTarget(self, action: #selector(LeadDetail.mapButton), for: UIControlEvents.touchUpInside)
        let btnLayer3: CALayer = self.mapbutton!.layer
        btnLayer3.masksToBounds = true
        btnLayer3.cornerRadius = 9.0
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(LeadDetail.editButton))
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(LeadDetail.actionButton))
        let buttons:NSArray = [editButton,actionButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        let topBorder = CALayer()
        let width = CGFloat(2.0)
        topBorder.borderColor = UIColor.lightGray.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0.5)
        topBorder.borderWidth = width
        tableView!.layer.addSublayer(topBorder)
        tableView!.layer.masksToBounds = true
        
        parseData()
        followButton()
        refreshData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        fieldData()
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = Color.DGrayColor
        self.labelname!.text = ""
        self.labelamount!.text = ""
        self.labeldate!.text = ""
        self.labeladdress!.text = ""
        self.labelcity!.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        self.listTableView!.reloadData()
        self.listTableView2!.reloadData()
        self.newsTableView!.reloadData()
    }
    
    // MARK: - Button
    
    func editButton() {
        status = "Edit"
        self.performSegue(withIdentifier: "editFormSegue", sender: self)
    }
    
    func mapButton() {
        self.performSegue(withIdentifier: "showmapSegue", sender: self)
    }
    
    func followButton() {
        
        if(self.active == "1") {
            self.following!.text = "Following"
            let replyimage : UIImage? = UIImage(named:"iosStar.png")
            self.activebutton!.setImage(replyimage, for: UIControlState())
        } else {
            self.following!.text = "Follow"
            let replyimage : UIImage? = UIImage(named:"iosStarNA.png")
            self.activebutton!.setImage(replyimage, for: UIControlState())
        }
    }
    
    func statButton() {
        self.performSegue(withIdentifier: "statisticSegue", sender: self)
    }
    
    
    // MARK: - Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.listTableView) {
            return tableData.count
        } else if (tableView == self.listTableView2) {
            return tableData2.count
        } else if (tableView == self.newsTableView) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.textLabel?.font = celltitle
            cell.detailTextLabel?.font = cellsubtitle
        } else {
            cell.textLabel?.font = celltitle
            cell.detailTextLabel?.font = cellsubtitle
        }
        
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        
        if (tableView == self.listTableView) {

            cell.textLabel?.text = tableData4.object(at: (indexPath as NSIndexPath).row) as? String
            
            cell.detailTextLabel?.text = tableData.object(at: (indexPath as NSIndexPath).row) as? String
            
            return cell
            
        } else if (tableView == self.listTableView2) {
            
            cell.textLabel?.text = tableData3.object(at: (indexPath as NSIndexPath).row) as? String

            cell.detailTextLabel?.text = tableData2.object(at: (indexPath as NSIndexPath).row) as? String
            
            return cell
            
        } else if (tableView == self.newsTableView) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell!
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                cell?.leadtitleDetail!.font = newstitle
                cell?.leadsubtitleDetail!.font = newssubtitle
                cell?.leadreadDetail!.font = newsdetail
                cell?.leadnewsDetail!.font = newsdetail
            } else {
                cell?.leadtitleDetail!.font = newstitle
                cell?.leadsubtitleDetail!.font = newssubtitle
                cell?.leadreadDetail.font = newsdetail
                cell?.leadnewsDetail!.font = newsdetail
            }
            
            let width = CGFloat(2.0)
            let topBorder = CALayer()
            topBorder.borderColor = UIColor.lightGray.cgColor
            topBorder.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0.5)
            topBorder.borderWidth = width
            cell?.layer.addSublayer(topBorder)
            cell?.layer.masksToBounds = true
            
            cell?.leadtitleDetail.text = "\(self.formController!) News: \(self.lnewsTitle!)"
            cell?.leadtitleDetail.numberOfLines = 0
            cell?.leadtitleDetail.textColor = .black
            
            //--------------------------------------------------------------
     
            if (self.formController == "Vendor" || self.formController == "Employee") {
                
                cell?.leadsubtitleDetail.text = "Comments"
                
            } else {
                
                let dateStr = self.date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let date1 = dateFormatter.date(from: dateStr!)
                let date2 = Date()
                let calendar = Calendar.current
                if date1 != nil {
                    let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
                    let daysCount = diffDateComponents.day
                    cell?.leadsubtitleDetail.text = "Comments, \(daysCount!) days ago"
                }
            }
            
            //--------------------------------------------------------------
            cell?.leadsubtitleDetail.textColor = .gray
            
            cell?.leadreadDetail.text = "Read more"
            cell?.leadreadDetail.textColor = Color.BlueColor
            
            cell?.leadnewsDetail.text = self.comments
            cell?.leadnewsDetail.numberOfLines = 0
            cell?.leadnewsDetail.textColor = .darkGray

            return cell!
            
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - LoadFieldData
    
    func fieldData() {

        self.labelname!.adjustsFontSizeToFitWidth = true
        
        if self.leadNo != nil {
            self.labelNo!.text = leadNo
        } else {
           self.labelNo!.text = "None" 
        }
        if self.date != nil {
            self.labeldate!.text = date
        }
        if self.l1datetext != nil {
            self.labeldatetext!.text = l1datetext
        }
        if self.name != nil {
            self.labelname!.text = name
        }
        if self.address != nil {
            self.labeladdress!.text = address
        }
        if self.city == nil {
            city = "City"
        }
        if self.state == nil {
            state = "State"
        }
        if self.zip == nil {
            zip = "Zip"
        }
        if self.city != nil {
            self.labelcity!.text = String(format: "%@ %@ %@", city!, state!, zip!)
        } else {
            city = "City"
        }
        if self.photo != nil {
            p1 = self.photo
        } else {
            p1 = "None"
        }
        if self.tbl11 != nil {
            t11 = tbl11
        } else {
            t11 = "None"
        }
        if self.tbl12 != nil {
            t12 = self.tbl12
        } else {
            t12 = "None"
        }
        if self.tbl13 != nil {
            t13 = self.tbl13
        } else {
            t13 = "None"
        }
        if self.tbl14 != nil {
            t14 = self.tbl14
        } else {
            t14 = "None"
        }
        if self.tbl15 != nil {
            t15 = self.tbl15
        } else {
            t15 = "None"
        }
        if self.tbl16 != nil {
            t16 = self.tbl16
        } else {
            t16 = "None"
        }
        if self.tbl21 != nil {
            t21 = self.tbl21
        } else {
            t21 = "None"
        }
        if self.tbl25 != nil {
            t25 = self.tbl25
        } else {
            t25 = "None"
        }
        if self.tbl26 != nil {
            t26 = self.tbl26
        } else {
            t26 = "None"
        }
    
        if (self.formController == "Leads" || self.formController == "Customer") {
            
            let formatter = NumberFormatter()
            var Amount:NSNumber? = formatter.number(from: amount! as String)
            formatter.numberStyle = .currency
            if Amount == nil {
                Amount = 0
            }
            labelamount!.text =  formatter.string(from: Amount!)
            
            if self.salesman != nil {
                t22 = self.salesman
            } else {
                t22 = "None"
            }
            
            if self.jobdescription != nil {
                t23 = self.jobdescription
            } else {
                t23 = "None"
            }
            
            if self.advertiser != nil {
                t24 = self.advertiser
            } else {
                t24 = "None"
            }
            
        } else {
            
            if self.amount != nil {
                labelamount!.text = self.amount
            } else {
                labelamount!.text = "None"
            }
            
            if self.tbl22 != nil {
                t22 = self.tbl22
            } else {
                t22 = "None"
            }
            
            if self.tbl23 != nil {
                t23 = self.tbl23
            } else {
                t23 = "None"
            }
            
            if self.tbl24 != nil {
                t24 = self.tbl24
            } else {
                t24 = "None"
            }
        }
        
        tableData = [t11!, t12!, t13!, t14!, t15!, t16!]
        
        tableData2 = [t21!, t22!, t23!, t24!, t25!, t26!]
        
        tableData4 = [l11!, l12!, l13!, l14!, l15!, l16!]
        
        tableData3 = [l21!, l22!, l23!, l24!, l25!, l26!]
    }
    
    // MARK: - Parse
    
    func parseData() {
        
        if (formController == "Leads" || formController == "Customer") {
            
            let query1 = PFQuery(className:"Salesman")
            query1.whereKey("SalesNo", equalTo:self.tbl22!)
            query1.cachePolicy = PFCachePolicy.cacheThenNetwork
            query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.salesman = object!.object(forKey: "Salesman") as? String
                }
            }
            
            let query = PFQuery(className:"Job")
            query.whereKey("JobNo", equalTo:self.tbl23!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.jobdescription = object!.object(forKey: "Description") as? String
                }
            }
        }
        
        if (self.formController == "Customer") {
            
            let query = PFQuery(className:"Product")
            query.whereKey("ProductNo", equalTo:self.tbl24!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.advertiser = object!.object(forKey: "Products") as? String
                }
            }
        }
        
        if (self.formController == "Leads") {
            
            let query = PFQuery(className:"Advertising")
            query.whereKey("AdNo", equalTo:self.tbl24!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.advertiser = object!.object(forKey: "Advertiser") as? String
                }
            }
        }
    }
    
    // MARK: - Actions
    
    func actionButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let addr = UIAlertAction(title: "Add Contact", style: .default, handler: { (action) -> Void in
            self.checkContactsAccess()
        })
        let cal = UIAlertAction(title: "Add Calender Event", style: .default, handler: { (action) -> Void in
            self.addEvent()
        })
        let web = UIAlertAction(title: "Web Page", style: .default, handler: { (action) -> Void in
            self.openurl()
        })
        let new = UIAlertAction(title: "Add Customer", style: .default, handler: { (action) -> Void in
            self.status = "New"
            self.performSegue(withIdentifier: "editFormSegue", sender: self)
        })
        let phone = UIAlertAction(title: "Call Phone", style: .default, handler: { (action) -> Void in
            self.callPhone()
        })
        let email = UIAlertAction(title: "Send Email", style: .default, handler: { (action) -> Void in
            self.sendEmail()
        })
        let bday = UIAlertAction(title: "Birthday", style: .default, handler: { (action) -> Void in
            self.getBirthday()
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            //print("Cancel Button Pressed")
        }
        
        alertController.addAction(phone)
        alertController.addAction(email)
        alertController.addAction(addr)
        if (formController == "Leads") {
            alertController.addAction(new)
        }
        if (formController == "Vendor") {
            alertController.addAction(web)
        }
        if !(formController == "Employee") {
            alertController.addAction(cal)
        }
        alertController.addAction(bday)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func callPhone() {
        
        let phoneNo : NSString?
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            
            if (formController == "Vendors") || (formController == "Employee") {
                phoneNo = t11!
            } else {
                phoneNo = t12!
            }
            
            if let phoneCallURL:URL = URL(string:"telprompt:\(phoneNo!)") {
                
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL)
                }
            } else {
                
                self.simpleAlert(title: "Alert", message: "Call facility is not available!!!")
            }
        } else {
            
            self.simpleAlert(title: "Alert", message: "Your device doesn't support this feature.")
        }
    }
    
    func openurl() {
        
        if (self.tbl26 != NSNull() && self.tbl26 != 0) {
            
            let Hooks = "http://\(self.tbl26!)"
            let Url = URL(string: Hooks)
            
            if UIApplication.shared.canOpenURL(Url!)
            {
                UIApplication.shared.openURL(Url!)
                
            } else {
                
                self.simpleAlert(title: "Invalid URL", message: "Your field doesn't have valid URL.")
            }
            
        } else {
            
            self.simpleAlert(title: "Invalid URL", message: "Your field doesn't have valid URL.")
            
        }
    }
    
    func sendEmail() {
        
        if (formController == "Leads") || (formController == "Customer") {
            if ((self.tbl15 != NSNull()) && (self.tbl15 != 0)) {
                self.getEmail(t15!)
                
            } else {
                
                self.simpleAlert(title: "Alert", message: "Your field doesn't have valid email.")
            }
        }
        if (formController == "Vendor") || (formController == "Employee") {
            if ((self.tbl21 != NSNull()) && (self.tbl21 != 0 )) {
                self.getEmail(t21!)
                
            } else {
                
                self.simpleAlert(title: "Alert", message: "Your field doesn't have valid email.")
            }
        }
    }
    
    func getEmail(_ emailfield: NSString) {
      
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setToRecipients([emailfield as String])
        email.setSubject((emailTitle)!)
        email.setMessageBody((messageBody)!, isHTML:true)
        email.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.present(email, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func addEvent() {
        
        let eventStore = EKEventStore()
        let itemText = defaults.string(forKey: "eventtitleKey")!
        let startDate = Date().addingTimeInterval(60 * 60)
        let endDate = startDate.addingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                self.createEvent(eventStore, title: String(format: "%@, %@", itemText, self.name!), startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: String(format: "%@ %@", itemText, self.name!), startDate: startDate, endDate: endDate)
        }
    }
    
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = String(format: "%@ %@ %@ %@", self.address!,self.city!,self.state!,self.zip!)
        event.notes = self.comments
        event.calendar = eventStore.defaultCalendarForNewEvents
        //event.addAlarm(EKAlarm.init(relativeOffset: 60.0))
        do {
            try eventStore.save(event, span: .thisEvent)
            savedEventId = event.eventIdentifier
            
            self.simpleAlert(title: "Event", message: "Event successfully saved.")
            
        } catch {
            print("An error occurred")
        }
    }
    
    private func checkContactsAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        // Update our UI if the user has granted access to their Contacts
        case .authorized:
            self.createContact()
            
        // Prompt the user for access to Contacts if there is no definitive answer
        case .notDetermined :
            self.requestContactsAccess()
            
        // Display a message if the user has denied or restricted access to Contacts
        case .denied,
             .restricted:
            let alert = UIAlertController(title: "Privacy Warning!",
                                          message: "Permission was not granted for Contacts.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func requestContactsAccess() {
        
        let store = CNContactStore()

        store.requestAccess(for: .contacts) {granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.createContact()
                    return
                }
            }
        }
    }
    
    
    private func createContact() {
        
        let newContact = CNMutableContact()
        
        if (formController == "Leads") {
            
            newContact.givenName = self.tbl13! as String
            newContact.familyName = self.name!
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = "US"
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone = CNLabeledValue(label:CNLabelHome, value:CNPhoneNumber(stringValue: self.tbl12! as String))
            newContact.phoneNumbers = [homephone]
            
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl15!)
            newContact.emailAddresses = [homeEmail]
            
            newContact.note = self.comments!
        }
        
        if (formController == "Customer") {
            
            newContact.givenName = self.tbl13! as String
            newContact.familyName = self.name!
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = "US"
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone = CNLabeledValue(label:CNLabelHome, value:CNPhoneNumber(stringValue:self.tbl12! as String))
            newContact.phoneNumbers = [homephone]
            
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl15!)
            newContact.emailAddresses = [homeEmail]
            
            newContact.organizationName = self.tbl11!
            newContact.note = self.comments!
        }
        
        if (formController == "Vendor") {
            
            newContact.jobTitle = (self.tbl25)!
            newContact.organizationName = (self.name)!
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = "US"
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone1 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl11! as String))
            let homephone2 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl12! as String))
            let homephone3 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl13! as String))
            let homephone4 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl14! as String))
            newContact.phoneNumbers = [homephone1, homephone2, homephone3, homephone4]
            
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl21!)
            newContact.emailAddresses = [homeEmail]
            
            newContact.note = self.comments!
        }
        
        if (formController == "Employee") {
            
            newContact.givenName = self.tbl26! as String
            newContact.middleName = self.tbl15! as String
            newContact.familyName = self.custNo!
            
            newContact.jobTitle = (self.tbl23)
            newContact.organizationName = (self.tbl27!)
            
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = self.address!
            homeAddress.city = self.city!
            homeAddress.state = self.state!
            homeAddress.postalCode = self.zip!
            homeAddress.country = self.tbl25!
            newContact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
            
            let homephone1 = CNLabeledValue(label:CNLabelHome, value:CNPhoneNumber(stringValue: self.tbl11! as String))
            let homephone2 = CNLabeledValue(label:CNLabelWork, value:CNPhoneNumber(stringValue: self.tbl12! as String))
            let homephone3 = CNLabeledValue(label:CNLabelPhoneNumberMobile, value:CNPhoneNumber(stringValue: self.tbl13! as String))
            newContact.phoneNumbers = [homephone1, homephone2, homephone3]

            let homeEmail = CNLabeledValue(label: CNLabelHome, value: self.tbl21!)
            //let workEmail = CNLabeledValue(label: CNLabelWork,value: "liam@workemail.com")
            newContact.emailAddresses = [homeEmail]
            
            var birthday = DateComponents()
            birthday.year = 1988 // You can omit the year value for a yearless birthday
            birthday.month = 12
            birthday.day = 05
            newContact.birthday = birthday
            
            var anniversaryDate = DateComponents()
            anniversaryDate.month = 10
            anniversaryDate.day = 12
            //let anniversary = CNLabeledValue(label: "Anniversary", value: anniversaryDate)
            //newContact.dates = [anniversary]
            
            //newContact.departmentName = "Food and Beverages"
            
            /*
            let facebookProfile = CNLabeledValue(label: "FaceBook", value:
            CNSocialProfile(urlString: nil, username: "ios_blog",
            userIdentifier: nil, service: CNSocialProfileServiceFacebook))
            
            let twitterProfile = CNLabeledValue(label: "Twitter", value:
            CNSocialProfile(urlString: nil, username: "ios_blog",
            userIdentifier: nil, service: CNSocialProfileServiceTwitter))
            
            newContact.socialProfiles = [facebookProfile, twitterProfile]
            */
            
            if let img = UIImage(named: "profile-rabbit-toy"),
                let imgData = UIImagePNGRepresentation(img) {
                newContact.imageData = imgData
            }
            
            newContact.note = self.comments!
        }
        
        do {
//-------------dupicate Contact-----------

            let nameStr: String
            if (formController == "Leads") || (formController == "Customer") {
                nameStr = "\(self.tbl13!) \(self.name!)"
            } else {
                nameStr = "\(self.name!)"
            }

            let predicateForMatchingName = CNContact
                .predicateForContacts(matchingName: nameStr)
            
            let matchingContacts = try! CNContactStore()
                .unifiedContacts(matching: predicateForMatchingName, keysToFetch: [])
            
            guard matchingContacts.isEmpty else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "There can only be one\n \(nameStr)", message: "Name already exists", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
//---------------------------------
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            let contactStore = CNContactStore()
            
            try contactStore.execute(saveRequest)
            
            self.simpleAlert(title: "Contact", message: "Contact successfully saved.")
        }
        catch {
            
            self.simpleAlert(title: "Contact", message: "Failed to add the contact.")
            
        }
        
    }
    
    
     // FIXME:
    
    func getBirthday() {
        
        let store = CNContactStore()
        
        //This line retrieves all contacts for the current name and gets the birthday and name properties
        
        let contacts:[CNContact] = try! store.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: "\(self.name!)"), keysToFetch:[CNContactBirthdayKey, CNContactGivenNameKey, CNContactFamilyNameKey])
        
        //Get the first contact in the array of contacts (since you're only looking for 1 you don't need to loop through the contacts)
        
        let contact = contacts[0]
        if (contact != 0) {

            if ((contact.birthday as NSDateComponents?)?.date as Date!) != nil {
                let dateFormatter = DateFormatter()
                //dateFormatter.timeZone = TimeZone(name: "UTC")
                dateFormatter.dateFormat = "MMM-dd-yyyy"
                let stringDate = dateFormatter.string(from: (contact.birthday! as NSDateComponents).date!)
                
                self.simpleAlert(title: "\(self.name!) Birthday", message: stringDate)
            } else {
                self.simpleAlert(title: "Info", message: "No Birthdays")
            }
        }
    }
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showmapSegue" {
            
            let controller = segue.destination as? MapView
            controller!.mapaddress = self.address
            controller!.mapcity = self.city
            controller!.mapstate = self.state
            controller!.mapzip = self.zip
        }
        
        if segue.identifier == "editFormSegue" {
            
            let controller = segue.destination as? EditData
            
            if (formController == "Leads") {
                
                if (self.status == "Edit") {
                    
                    controller!.formController = self.formController
                    controller!.status = "Edit"
                    controller!.objectId = self.objectId //Parse Only
                    controller!.leadNo = self.leadNo
                    controller!.frm11 = self.tbl13 //first
                    controller!.frm12 = self.name
                    controller!.frm13 = nil
                    controller!.frm14 = self.address
                    controller!.frm15 = self.city
                    controller!.frm16 = self.state
                    controller!.frm17 = self.zip
                    controller!.frm18 = self.date
                    controller!.frm19 = self.tbl21 as? String //aptdate
                    controller!.frm20 = self.tbl12 //phone
                    controller!.frm21 = self.tbl22 //salesNo
                    controller!.frm22 = self.tbl23 //jobNo
                    controller!.frm23 = self.tbl24 //adNo
                    controller!.frm24 = self.amount
                    controller!.frm25 = self.tbl15 as? String//email
                    controller!.frm26 = self.tbl14 //spouse
                    controller!.frm27 = self.tbl11 //callback
                    controller!.frm28 = self.comments
                    controller!.frm29 = self.photo
                    controller!.frm30 = self.active
                    controller!.saleNo = self.tbl22
                    controller!.jobNo = self.tbl23
                    controller!.adNo = self.tbl24
                    
                } else if (self.status == "New") { //new Customer from Lead
                    
                    controller!.formController = "Customer"
                    controller!.status = "New"
                    controller!.custNo = self.custNo
                    controller!.frm11 = self.tbl13 //first
                    controller!.frm12 = self.name
                    controller!.frm13 = nil
                    controller!.frm14 = self.address
                    controller!.frm15 = self.city
                    controller!.frm16 = self.state
                    controller!.frm17 = self.zip
                    controller!.frm18 = nil //date
                    controller!.frm19 = nil //aptdate
                    controller!.frm20 = self.tbl12 //phone
                    controller!.frm21 = self.salesman
                    controller!.frm22 = self.jobdescription
                    controller!.frm23 = nil //adNo
                    controller!.frm24 = self.amount
                    controller!.frm25 = self.tbl15 as? String //email
                    controller!.frm26 = self.tbl14 //spouse
                    controller!.frm27 = nil //callback
                    controller!.frm28 = self.comments
                    controller!.frm29 = self.photo
                    controller!.frm30 = self.active
                    controller!.frm31 = nil //start
                    controller!.frm32 = nil //completion
                }
                
            } else if (formController == "Customer") {
                controller!.formController = self.formController
                controller!.status = "Edit"
                controller!.objectId = self.objectId //Parse Only
                controller!.custNo = self.custNo
                controller!.leadNo = self.leadNo
                controller!.frm11 = self.tbl13 //first
                controller!.frm12 = self.name
                controller!.frm13 = self.tbl11
                controller!.frm14 = self.address
                controller!.frm15 = self.city
                controller!.frm16 = self.state
                controller!.frm17 = self.zip
                controller!.frm18 = self.date
                controller!.frm19 = self.tbl26 as? String //rate
                controller!.frm20 = self.tbl12 //phone
                controller!.frm21 = self.tbl22 //salesNo
                controller!.frm22 = self.tbl23 //jobNo
                controller!.frm23 = self.tbl24 //prodNo
                controller!.frm24 = self.amount
                controller!.frm25 = self.tbl15 as? String //email
                controller!.frm26 = self.tbl14 //spouse
                controller!.frm27 = self.tbl25 //quan
                controller!.frm28 = self.comments
                controller!.frm29 = self.photo
                controller!.frm30 = self.active
                controller!.frm31 = self.tbl21 as? String
                controller!.frm32 = self.complete
                controller!.saleNo = self.tbl22
                controller!.jobNo = self.tbl23
                controller!.adNo = self.tbl24
                controller!.time = self.tbl16
              //controller!.frm33 = self.photo1
              //controller!.frm34 = self.photo2
                
            } else if (formController == "Vendor") {
                controller!.formController = self.formController
                controller!.status = "Edit"
                controller!.objectId = self.objectId //Parse Only
                controller!.leadNo = self.leadNo //vendorNo
                controller!.frm11 = self.name //vendorname
                controller!.frm12 = self.date //webpage
                controller!.frm13 = self.tbl24 //manager
                controller!.frm14 = self.address
                controller!.frm15 = self.city
                controller!.frm16 = self.state
                controller!.frm17 = self.zip
                controller!.frm18 = self.tbl25 //profession
                controller!.frm19 = self.tbl15 as? String //assistant
                controller!.frm20 = self.tbl11 //phone
                controller!.frm21 = self.tbl12 //phone1
                controller!.frm22 = self.tbl13 //phone2
                controller!.frm23 = self.tbl14 //phone3
                controller!.frm24 = self.tbl22 //department
                controller!.frm25 = self.tbl21 as? String //email
                controller!.frm26 = self.tbl23 //office
                controller!.frm27 = nil
                controller!.frm28 = self.comments
                controller!.frm29 = nil
                controller!.frm30 = self.active

            } else if (formController == "Employee") {
                controller!.formController = self.formController
                controller!.status = "Edit"
                controller!.objectId = self.objectId //Parse Only
                controller!.leadNo = self.leadNo //employeeNo
                controller!.frm11 = self.tbl26 as? String //first
                controller!.frm12 = self.custNo //lastname
                controller!.frm13 = self.tbl27 //company
                controller!.frm14 = self.address
                controller!.frm15 = self.city
                controller!.frm16 = self.state
                controller!.frm17 = self.zip
                controller!.frm18 = self.tbl23 //title
                controller!.frm19 = self.tbl15 as? String //middle
                controller!.frm20 = self.tbl11 //homephone
                controller!.frm21 = self.tbl12 //workphone
                controller!.frm22 = self.tbl13 //cellphone
                controller!.frm23 = self.tbl14 //social
                controller!.frm24 = self.tbl22 //department
                controller!.frm25 = self.tbl21 as? String//email
                controller!.frm26 = self.tbl25 //manager
                controller!.frm27 = self.tbl24
                controller!.frm28 = self.comments
                controller!.frm29 = nil
                controller!.frm30 = self.active
                
            }
        }
    }
    
}

