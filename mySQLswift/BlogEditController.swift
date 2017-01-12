//
//  BlogEditViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/14/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class BlogEditController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var listTableView: UITableView?
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet weak var Like: UIButton?
    @IBOutlet weak var update: UIButton?
    
    var replylikeButton: UIButton?
    
    var _feedItems : NSMutableArray = NSMutableArray()
    var _feedItems1 : NSMutableArray = NSMutableArray()
    var refreshControl: UIRefreshControl!
    var filteredString : NSMutableArray = NSMutableArray()
    var objects = [AnyObject]()
 
    var objectId : String?
    var msgNo : String?
    var postby : String?
    var subject : String?
    var msgDate : String?
    var rating : String?
    var replyId : String?
    var liked : Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: view.frame.height))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleLabel.text = "TheLight Software - Edit Message"
        } else {
            titleLabel.text = "Edit Message"
        }
        titleLabel.textColor = .white
        titleLabel.font = Font.navlabel
        titleLabel.textAlignment = NSTextAlignment.center
        navigationItem.titleView = titleLabel
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 110
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor =  .white
        
        self.listTableView!.delegate = self
        self.listTableView!.dataSource = self
        self.listTableView!.estimatedRowHeight = 75
        self.listTableView!.rowHeight = UITableViewAutomaticDimension
        self.listTableView!.tableFooterView = UIView(frame: .zero)

        self.view.backgroundColor = .lightGray
        self.toolBar!.isTranslucent = false
        self.toolBar!.barTintColor = .white
        
        self.toolBar!.layer.masksToBounds = true
        let width = CGFloat(2.0)
        
        let topBorder = CALayer()
        topBorder.borderColor = UIColor.lightGray.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width:  self.view.frame.width, height: 0.5)
        topBorder.borderWidth = width
        self.toolBar!.layer.addSublayer(topBorder)
        
        let bottomBorder = CALayer()
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        bottomBorder.frame = CGRect(x: 0, y: 43, width:self.view.frame.width, height: 0.5)
        bottomBorder.borderWidth = width
        self.toolBar!.layer.addSublayer(bottomBorder)
        
        
        if (self.liked == nil) {
            self.Like!.tintColor = .lightGray
            self.Like!.setTitle("", for: UIControlState())
        } else {
            self.Like!.tintColor = Color.Blog.buttonColor
            self.Like!.setTitle(" Likes \(liked!)", for: UIControlState())
        }
        let likeImage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        self.Like!.setImage(likeImage, for: UIControlState())
        self.Like!.setTitleColor(.gray, for: UIControlState())
        
        
        self.update!.setTitleColor(.gray, for: UIControlState())
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(BlogEditController.shareButton))
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(BlogEditController.deleteButton))
        navigationItem.rightBarButtonItems = [actionButton,trashButton]
        
        parseData()
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(BlogEditController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView!.addSubview(refreshControl)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData(sender:AnyObject) {
        
        parseData()
        self.refreshControl?.endRefreshing()
    }

    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.tableView) {
            return 1
        } else {
            return _feedItems1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableCell!
            
            if cell == nil {
                cell = CustomTableCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
            }
            
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                
                cell?.titleLabel!.font = Font.Blog.celltitlePad
                cell?.subtitleLabel!.font = Font.Blog.cellsubtitlePad
                cell?.msgDateLabel.font = Font.Blog.celldatePad
                
            } else {
                
                cell?.titleLabel!.font = Font.Blog.celltitle
                cell?.subtitleLabel!.font = Font.celltitle
                cell?.msgDateLabel.font = Font.Blog.celldate
            }
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:self.postby!)
            query.limit = 1
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                            cell?.blogImageView?.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
            
            let dateStr = self.msgDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date:Date = dateFormatter.date(from: (dateStr)! as String)!
            dateFormatter.dateFormat = "MM/dd/yy, h:mm a"
            
            cell?.titleLabel!.text = self.postby
            cell?.subtitleLabel!.text = self.subject
            cell?.msgDateLabel.text = dateFormatter.string(from: (date) as Date)
            
//---------------------NSDataDetector-----------------------------
            
            let text = self.subject
            let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            detector?.enumerateMatches(in: text!, options: [], range: NSMakeRange(0, (text! as NSString).length)) { (result, flags, _) in
                
                let webattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.weblinkText])
                
                let emailattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.emaillinkText])
                
                let phoneattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSBackgroundColorAttributeName: Color.Blog.phonelinkText])
                
                if result!.resultType == .link {
                    
                    if result?.url?.absoluteString.lowercased().range(of: "mailto:") != nil {
                        cell?.subtitleLabel!.attributedText = emailattributedText
                    } else {
                        cell?.subtitleLabel!.attributedText = webattributedText
                    }
                    
                } else if result?.resultType == .phoneNumber {
                    
                    cell?.subtitleLabel!.attributedText = phoneattributedText
                }
            }
//--------------------------------------------------
            
            return cell!
        }
        else { //----listViewTable--------------
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell") as! CustomTableCell!
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo: (self._feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as! String)
            query.limit = 1
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                            cell?.replyImageView?.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
            
            if cell == nil {
                cell = CustomTableCell(style: UITableViewCellStyle.default, reuseIdentifier: "ReplyCell")
            }
            
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.replydateLabel.textColor = .gray
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                
                cell?.replytitleLabel!.font = Font.BlogEdit.replytitlePad
                cell?.replysubtitleLabel!.font = Font.BlogEdit.replysubtitlePad
                cell?.replynumLabel!.font = Font.BlogEdit.replytitlePad
                cell?.replydateLabel!.font = Font.BlogEdit.replysubtitlePad
                
            } else {
                
                cell?.replytitleLabel!.font = Font.BlogEdit.replytitle
                cell?.replysubtitleLabel!.font = Font.BlogEdit.replysubtitle
                cell?.replynumLabel.font = Font.BlogEdit.replytitle
                cell?.replydateLabel.font = Font.BlogEdit.replysubtitle
            }

            let date1 = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
            let date2 = Date()
            let calendar = Calendar.current
            let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
            
            cell?.replytitleLabel!.text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as? String
            cell?.replysubtitleLabel!.text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as? String
            cell?.replydateLabel!.text = String(format: "%d%@", diffDateComponents.day!," days ago" )
            var Liked:Int? = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Liked") as? Int
            if Liked == nil {
                Liked = 0
            }
            cell?.replynumLabel!.text = "\(Liked!)"
            
            cell?.replylikeButton.tintColor = .lightGray
            let replyimage : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
            cell?.replylikeButton .setImage(replyimage, for: UIControlState())
            cell?.replylikeButton .addTarget(self, action: #selector(BlogEditController.likeButton), for: UIControlEvents.touchUpInside)
            
            if !(cell?.replynumLabel.text == "0") {
                cell?.replynumLabel.textColor = .red
            } else {
                cell?.replynumLabel.text? = ""
            }

            return cell!
        } 
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
    
    // MARK: - Button
    
    @IBAction func updateButton(sender: UIButton) {
        
        self.performSegue(withIdentifier: "blogeditSegue", sender: self)
    }
    
    func likeButton(sender:UIButton) {
        
        self.Like?.isSelected = true
        sender.tintColor = .red
        let hitPoint = sender.convert(CGPoint.zero, to: self.listTableView)
        let indexPath = self.listTableView!.indexPathForRow(at: hitPoint)
        
        let query = PFQuery(className:"Blog")
        query.whereKey("objectId", equalTo:((_feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                object!.incrementKey("Liked")
                object!.saveInBackground()
            }
        }
    }
    
    func shareButton(_ sender: AnyObject) {
        
        let activityViewController = UIActivityViewController (
            activityItems: [self.subject! as String],
            applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteButton(sender: UIButton) {
        
        let query = PFQuery(className:"Blog")
        query.whereKey("objectId", equalTo:self.objectId!)
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground()
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        return
        }
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        self.present(alertController, animated: true) {
        }
    }
    
    // MARK: - Parse
    
    func parseData() {
        
        let query1 = PFQuery(className:"Blog")
        query1.whereKey("ReplyId", equalTo:self.objectId!)
        query1.cachePolicy = PFCachePolicy.cacheThenNetwork
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems1 = temp.mutableCopy() as! NSMutableArray
                self.listTableView!.reloadData()
            } else {
                print("Error")
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blogeditSegue" {
            
            let VC = segue.destination as? BlogNewController
            VC!.formStatus = "None"
            VC!.textcontentobjectId = self.objectId
            VC!.textcontentmsgNo = self.msgNo
            VC!.textcontentpostby = self.postby
            VC!.textcontentsubject = self.subject
            VC!.textcontentdate = self.msgDate
            VC!.textcontentrating = self.rating
            VC!.liked = self.liked
        }
        
    }
}
