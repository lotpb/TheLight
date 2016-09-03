//
//  BlogNewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/14/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class BlogNewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    let ipadsubject = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
    let CharacterLimit = 140
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var Share: UIButton?
    @IBOutlet weak var Like: UIButton?
    @IBOutlet weak var myDatePicker: UIDatePicker?
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet weak var subject: UITextView?
    @IBOutlet weak var imageBlog: UIImageView?
    @IBOutlet weak var placeholderlabel: UILabel?
    @IBOutlet weak var characterCountLabel: UILabel?
    
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

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("New Message", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        parseData() //load image
        subject?.delegate = self
        self.tableView!.backgroundColor =  UIColor(white:0.90, alpha:1.0)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.subject!.font = ipadsubject
        } else {
            self.subject!.font = Font.Blog.cellsubject
        }
        
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
            self.subject?.text = self.textcontentsubject
            self.postby = self.textcontentpostby
            self.rating = self.textcontentrating
            if (self.liked == nil || self.liked == 0) {
                
                self.Like!.tintColor = .white
            } else {
                self.Like!.tintColor = Color.Blog.buttonColor
            }
            
//---------------------NSDataDetector-----------------------------
            
            let text = self.textcontentsubject!
            let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            detector?.enumerateMatches(in: text, options: [], range: NSMakeRange(0, (text as NSString).length)) { (result, flags, _) in
                
                let webattributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.weblinkText])
                
                //attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, attributedText.length))
                
                let emailattributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.emaillinkText])
                
                let phoneattributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.phonelinkText])

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
//--------------------------------------------------
        
        if (self.formStatus == "New") {
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
        
        self.myDatePicker!.isHidden = false
        self.myDatePicker!.datePickerMode = UIDatePickerMode.date
        self.myDatePicker!.backgroundColor = UIColor(white:0.90, alpha:1.0)
      //self.myDatePicker!.setValue(UIColor.white(), forKeyPath: "textColor")
        self.myDatePicker!.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

        self.characterCountLabel!.text = ""
        self.characterCountLabel!.textColor = .gray
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - DatePicker
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let strDate = dateFormatter.string(from: (myDatePicker?.date)!)
        self.msgDate = strDate
        self.tableView!.reloadData()
    }
    
    // MARK: - textView delegate
    
    func textViewDidBeginEditing(_ textView:UITextView) {
        
        if subject!.text.isEmpty {
            self.placeholderlabel?.isHidden = true
        }
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
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.textLabel!.font = ipadtitle
            cell.detailTextLabel!.font = ipadtitle
            
        } else {
            cell.textLabel!.font = Font.Blog.cellsubtitle
            cell.detailTextLabel!.font = Font.Blog.cellsubtitle
        }
        
        if (indexPath.row == 0) {
            
            self.activeImage = UIImageView(frame:CGRect(x: tableView.frame.size.width-35, y: 10, width: 18, height: 22))
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
            
            cell.textLabel!.text = self.postby
            cell.detailTextLabel!.text = ""
            cell.contentView.addSubview(self.activeImage!)
            
        } else if (indexPath.row == 1) {
            
            cell.textLabel!.text = self.msgDate
            cell.detailTextLabel!.text = "Date"
            
        }
        
        return cell
    }
    
    
    // MARK: - Parse
    
    func parseData() {
       
        let query:PFQuery = PFUser.query()!
        query.whereKey("username",  equalTo:self.textcontentpostby!)
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
    
    
    // MARK: - Update Buttons
    
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
    
    // MARK: - Notification
    
    func newBlogNotification() {
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Blog Post"
        localNotification.alertBody = "New Blog Posted by \(self.postby) at TheLight"
        localNotification.fireDate = Date(timeIntervalSinceNow: 10)
        localNotification.timeZone = TimeZone.current
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }

    
    @IBAction func saveData(sender: UIButton) {
        
        guard let text = self.subject?.text else { return }
        
        if text == "" {

            let alert = UIAlertController(title: "Oops!", message: "No text entered.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
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
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeBlog")
                        self.show(vc!, sender: self)
                        
                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                    }
                }
                
            } else if (self.formStatus == "New") {
                
                let saveblog:PFObject = PFObject(className:"Blog")
                saveblog.setObject(self.msgDate!, forKey:"MsgDate")
                saveblog.setObject(self.postby!, forKey:"PostBy")
                saveblog.setObject(self.rating!, forKey:"Rating")
                saveblog.setObject(self.subject!.text, forKey:"Subject")
                saveblog.setObject(self.msgNo ?? NSNumber(value:-1), forKey:"MsgNo")
                saveblog.setObject(self.replyId ?? NSNull(), forKey:"ReplyId")
                saveblog.setObject(self.liked ?? NSNumber(value:0), forKey:"Liked")
                
                if self.formStatus == "Reply" {
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
                        self.newBlogNotification()
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeBlog")
                        self.show(vc!, sender: self)
                        
                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                    }
                }
            }
        }
    }
    
}
