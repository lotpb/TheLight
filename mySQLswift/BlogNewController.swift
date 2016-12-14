//
//  BlogNewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/14/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import UserNotifications


class BlogNewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    let ipadsubject = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
    let CharacterLimit = 140
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var Share: UIButton?
    @IBOutlet weak var Like: UIButton?
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet weak var subject: UITextView?
    @IBOutlet weak var imageBlog: UIImageView?
    @IBOutlet weak var placeholderlabel: UILabel?
    @IBOutlet weak var characterCountLabel: UILabel?
    
    //@IBOutlet weak var myDatePicker: UIDatePicker?
    
    var objectId : String?
    var msgNo : String?
    var postby : String?
    var msgDate : String?
    var rating : String?
    var liked : Int?
    var replyId : String?
    
    var textcontentobjectId : String?
    var textcontentmsgNo : String?
    var textcontentdate : String?
    var textcontentpostby : String?
    var textcontentsubject : String?
    var textcontentrating : String?
    
    var formStatus : String?
    var activeImage : UIImageView? //star
    
//------inlineDatePicker---------
    
    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
 
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 1
    let kDateEndRow   = 1
    
    let kTitleCellID      = "titleCell"
    let kDateCellID       = "dateCell" // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"
    
    var dataArray: [[String: AnyObject]] = []
    var dateFormatter = DateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: IndexPath?
    var pickerCellRowHeight: CGFloat = 216

//-------------------------------------
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: view.frame.height))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleLabel.text = "TheLight Software - New Message"
        } else {
            titleLabel.text = "New Message"
        }
        titleLabel.textColor = .white
        titleLabel.font = Font.navlabel
        titleLabel.textAlignment = NSTextAlignment.center
        navigationItem.titleView = titleLabel
        
        parseData() //load image
        configureTextView()
        
        self.tableView!.backgroundColor =  UIColor(white:0.90, alpha:1.0)
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        self.imageBlog!.layer.masksToBounds = true
        self.imageBlog!.layer.cornerRadius = 5
        self.imageBlog!.contentMode = .scaleAspectFill
        
        if ((self.formStatus == "New") || (self.formStatus == "Reply")) {
            
            self.placeholderlabel!.textColor = .lightGray
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: (Date()) as Date)
            self.msgDate = dateString
            
            self.rating = "4"
            self.postby =  self.textcontentpostby
            
        } else if ((self.formStatus == "None")) { //set in BlogEdit
            
            self.placeholderlabel!.isHidden = true
            self.objectId = self.textcontentobjectId
            self.msgNo = self.textcontentmsgNo
            self.msgDate = self.textcontentdate
            self.subject!.text = self.textcontentsubject
            self.postby = self.textcontentpostby
            self.rating = self.textcontentrating
            if (self.liked == nil || self.liked == 0) {
                
                self.Like!.tintColor = .white
            } else {
                self.Like!.tintColor = Color.Blog.buttonColor
            }
        }
        
        if (self.formStatus! == "New") {
            self.placeholderlabel!.text = "Share an idea?"
            self.Like!.tintColor = .white
            
        } else if (self.formStatus == "Reply") {
            self.placeholderlabel!.isHidden = true
            self.subject!.text = self.textcontentsubject
            self.subject!.becomeFirstResponder()
            self.subject!.isUserInteractionEnabled = true
        }
        
        let likeimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        self.Like!.setImage(likeimage, for: UIControlState())
        self.Like!.setTitleColor(.white, for: UIControlState())
        
        //---------inline DatePicker---------------
        
        let itemOne = [kTitleKey : "Tap a cell to change its date:", kDateKey : ""]
        let itemTwo = [kTitleKey : "Date", kDateKey : Date()] as [String : Any]
        let itemThree = [kTitleKey : "Name", kDateKey : self.postby]
      //let itemFour = [kTitleKey : "Date", kDateKey : Date()] as [String : Any]
        dataArray = [itemOne as Dictionary<String, AnyObject>, itemTwo as Dictionary<String, AnyObject>, itemThree as Dictionary<String, AnyObject>]
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        NotificationCenter.default.addObserver(self, selector: #selector(localeChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        /*
         self.myDatePicker!.isHidden = false
         self.myDatePicker!.datePickerMode = UIDatePickerMode.date
         self.myDatePicker!.backgroundColor = UIColor(white:0.90, alpha:1.0)
         //self.myDatePicker!.setValue(UIColor.white(), forKeyPath: "textColor")
         self.myDatePicker!.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
         */
        //--------------------------------------
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - textView delegate
    
    func textViewDidBeginEditing(_ textView:UITextView) {
 
        if subject!.text.isEmpty {
            self.placeholderlabel?.isHidden = true
        }
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemClicked))
        
        navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
    }
    
    func textViewDidEndEditing(_ textView:UITextView) {
        
        if subject!.text.isEmpty {
         self.placeholderlabel?.isHidden = false
        }
    }
    
    // MARK: Characters Limit
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let myTextViewString = self.subject!.text
        characterCountLabel!.text = "\(CharacterLimit - (myTextViewString?.characters.count)!)"
        
        if range.length > CharacterLimit {
            return false
        }
        
        let newLength = (myTextViewString?.characters.count)! + range.length
        
        return newLength < CharacterLimit
    }
    
    // MARK: TextView configure
    
    func configureTextView() {
        
        subject?.delegate = self
        subject?.autocorrectionType = UITextAutocorrectionType.yes
        subject?.dataDetectorTypes = UIDataDetectorTypes.all
        self.characterCountLabel!.text = ""
        self.characterCountLabel!.textColor = .gray
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.subject!.font = ipadsubject
        } else {
            self.subject!.font = Font.Blog.cellsubject
        }
        
        if ((self.formStatus == "None") || (self.formStatus == "Reply")) {
            let text = self.textcontentsubject!
            let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            detector?.enumerateMatches(in: text, options: [], range: NSMakeRange(0, (text as NSString).length)) { (result, flags, _) in
                
                let webattributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.weblinkText])
                
                let emailattributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.emaillinkText])
                
                let phoneattributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSBackgroundColorAttributeName: Color.Blog.phonelinkText])
                
                //attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, attributedText.length))
                
                if result!.resultType == .link {
                    
                    if result?.url?.absoluteString.lowercased().range(of: "mailto:") != nil {
                        self.subject!.attributedText = emailattributedText
                    } else {
                        self.subject!.attributedText = webattributedText
                    }
                    
                } else if result?.resultType == .phoneNumber {
                    
                    self.subject!.attributedText = phoneattributedText
                }
            }
        }
    }
    
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePicker() {
  
            return dataArray.count + 1
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        var cellID = kTitleCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if indexPath.row == 0 {
            
            self.activeImage = UIImageView(frame:CGRect(x: tableView.frame.width-35, y: 10, width: 18, height: 22))
            self.activeImage!.contentMode = .scaleAspectFill
            
            if (self.liked == nil || self.liked == 0) {
                self.Like!.tintColor = .white
                self.Like!.setTitle(" Like", for: UIControlState.normal)
                self.activeImage!.image = UIImage(named:"iosStarNA.png")
                
            } else {
                self.Like!.tintColor = Color.Blog.buttonColor
                self.Like!.setTitle(" Likes \(liked!)", for: UIControlState.normal)
                self.activeImage!.image = UIImage(named:"iosStar.png")
            }
            cell?.contentView.addSubview(self.activeImage!)
            cell?.selectionStyle = .none
        }
        
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && (datePickerIndexPath?.row)! <= indexPath.row) {
            modelRow -= 1
        }
        
        let itemData = dataArray[modelRow]

        if cellID == kDateCellID {
            
            let dateCell : String
            if ((self.formStatus == "None")) {
                dateCell = self.msgDate!
            } else {
                dateCell = self.dateFormatter.string(from: itemData[kDateKey] as! Date)
            }
            
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = dateCell //self.dateFormatter.string(from: itemData[kDateKey] as! Date)
            
        } else if cellID == kTitleCellID {
            
            cell?.textLabel!.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = itemData[kDateKey] as! String?
            cell?.selectionStyle = .none
            
        }
        
        return cell!
    }

//------------------------------------------------------------------
    // MARK: - Inline Pickdate

    func localeChanged(_ notif: Notification) {

        self.tableView?.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath!.row == indexPath.row
    }
    
    func indexPathHasDate(_ indexPath: IndexPath) -> Bool {
        var hasDate = false
        
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }
    
    func displayInlineDatePickerForRowAtIndexPath(_ indexPath: IndexPath) {

        self.tableView?.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = (datePickerIndexPath?.row)! < indexPath.row
        }
        
        let sameCellClicked = ((datePickerIndexPath as NSIndexPath?)?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            self.tableView?.deleteRows(at: [IndexPath(row: datePickerIndexPath!.row, section: 0)], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = IndexPath(row: indexPathToReveal.row + 1, section: 0)
        }

        self.tableView?.deselectRow(at: indexPath, animated:true)
        
        self.tableView?.endUpdates()
        
        updateDatePicker()
    }
    
    func toggleDatePickerForSelectedIndexPath(_ indexPath: IndexPath) {
        
        self.tableView?.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: 0)]

        if hasPickerForIndexPath(indexPath) {
        
            self.tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
        
            self.tableView?.insertRows(at: indexPaths, with: .fade)
        }
        self.tableView?.endUpdates()
    }
    
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = self.tableView?.cellForRow(at: indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! Date, animated: false)
            }
        }
    }
    
    func hasPickerForIndexPath(_ indexPath: IndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = self.tableView?.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    
    @IBAction func dateAction(_ sender: UIDatePicker) {
        
        var targetedCellIndexPath: IndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = self.tableView?.indexPathForSelectedRow!
        }
        
        let cell = self.tableView?.cellForRow(at: targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date as AnyObject?
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.string(from: targetedDatePicker.date)
        
        // update the parse date string
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone.current
        let strDate = dateFormatter.string(from: (targetedDatePicker.date))
        self.msgDate = strDate
        
    }
//--------------------------------------------------------
    // MARK: - DatePicker
    /*
     func datePickerValueChanged(sender: UIDatePicker) {
     
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     dateFormatter.timeZone = TimeZone.current
     let strDate = dateFormatter.string(from: (myDatePicker?.date)!)
     self.msgDate = strDate
     self.tableView!.reloadData()
     } */
//---------------------------------------------------------
    
    // MARK: - Parse
    
    func parseData() {
       
        let query:PFQuery = PFUser.query()!
        query.whereKey("username",  equalTo: self.textcontentpostby!)
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                        self.imageBlog?.image = UIImage(data: imageData!)
                    }
                }
            }
        } 

    }
    
    // MARK: - Buttons
    
    @IBAction func like(sender:UIButton) {

        if(self.rating == "4") {
            self.rating = "5"
            self.liked = 1
        } else {
            self.rating = "4"
            self.liked = 0
        }
        self.tableView!.reloadData()
    }
    
    func doneBarButtonItemClicked() {
        // Dismiss the keyboard by removing it as the first responder.
        self.subject?.resignFirstResponder()
        
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    // MARK: - Notification
    
    func newBlogNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Blog Post"
        content.body = "New Blog Posted by \(self.postby!) at TheLight"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "status"
        
        let imageURL = Bundle.main.url(forResource: "comments", withExtension: "png")
        let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
        content.attachments = [attachment]
        content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "newBlog-id-123", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }

    // MARK: - Save Data
    
    @IBAction func saveData(sender: UIButton) {
        
        guard let text = self.subject?.text else { return }
        
        if text == "" {
            
            self.simpleAlert(title: "Oops!", message: "No text entered.")
            
        } else {
            
            if (self.formStatus == "None") {
                
                let query = PFQuery(className:"Blog")
                query.whereKey("objectId", equalTo:self.objectId!)
                query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        updateblog!.setObject(self.msgDate!, forKey:"MsgDate")
                        updateblog!.setObject(self.postby!, forKey:"PostBy")
                        updateblog!.setObject(self.rating!, forKey:"Rating")
                        updateblog!.setObject(self.subject!.text, forKey:"Subject")
                        updateblog!.setObject(self.msgNo ?? NSNumber(value:-1), forKey:"MsgNo")
                        updateblog!.setObject(self.replyId ?? NSNull(), forKey:"ReplyId")
                        updateblog!.saveEventually()
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "blogId")
                        self.show(vc!, sender: self)
                        //self.present(vc!, animated: true)
                        
                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                    }
                }
                
            } else if (self.formStatus == "New" || self.formStatus == "Reply") {
                
                let saveblog:PFObject = PFObject(className:"Blog")
                saveblog.setObject(self.msgDate!, forKey:"MsgDate")
                saveblog.setObject(self.postby!, forKey:"PostBy")
                saveblog.setObject(self.rating!, forKey:"Rating")
                saveblog.setObject(self.subject!.text, forKey:"Subject")
                saveblog.setObject(self.msgNo ?? NSNumber(value:-1), forKey:"MsgNo")
                saveblog.setObject(self.replyId ?? NSNull(), forKey:"ReplyId")
                saveblog.setObject(self.liked ?? NSNumber(value:0), forKey:"Liked")
                
                if (self.formStatus == "Reply") {
                    let query = PFQuery(className:"Blog")
                    query.whereKey("objectId", equalTo:self.replyId!)
                    query.getFirstObjectInBackground {(updateReply: PFObject?, error: Error?) -> Void in
                        if error == nil {
                            updateReply!.incrementKey("CommentCount")
                            updateReply!.saveEventually()
                        }
                    }
                }
                
                saveblog.saveInBackground { (success: Bool, error: Error?) -> Void in
                    if success == true {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "blogId")
                        self.show(vc!, sender: self)
                        
                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        self.newBlogNotification()
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                    }
                }
            }
        }
    }
    
}
