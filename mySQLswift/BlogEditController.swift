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
    
    var _feedItems : NSMutableArray = NSMutableArray()
    var _feedItems1 : NSMutableArray = NSMutableArray()
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
    
    lazy var replylikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        button.isHidden = false
        button.addTarget(self, action: #selector(BlogEditController.likeButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.twitterText
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(BlogEditController.shareButton))
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(BlogEditController.deleteButton))
        navigationItem.rightBarButtonItems = [actionButton,trashButton]
        
        self.toolBar!.barTintColor = .white
        self.toolBar!.isTranslucent = false
        self.toolBar!.layer.masksToBounds = true
        
        self.Like!.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        self.Like!.setTitleColor(.gray, for: .normal)
        
        setupTableView()
        setupForm()
        parseData()
        self.tableView!.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTwitterNavigationBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupForm() {
        self.view.backgroundColor = .lightGray

        self.update?.backgroundColor = Color.twitterBlue
        self.update?.setTitleColor(.white, for: .normal)
        let btnLayer: CALayer = self.update!.layer
        btnLayer.cornerRadius = 9.0
        btnLayer.masksToBounds = true
        
        
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
            self.Like!.setTitle("", for: .normal)
        } else {
            self.Like!.tintColor = Color.Blog.buttonColor
            self.Like!.setTitle(" Likes \(liked!)", for: .normal)
        }
    }
    
    func setupTableView() {
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
    }
    
    func refreshData(sender:AnyObject) {
        
        parseData()
        self.refreshControl.endRefreshing()
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
            cell?.subtitleLabel?.textColor = Color.twitterText
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                
                cell?.titleLabel!.font = Font.Blog.celltitlePad
                cell?.subtitleLabel!.font = Font.Blog.cellsubtitlePad
                cell?.msgDateLabel.font = Font.Blog.celldatePad
                
            } else {
                
                cell?.titleLabel!.font = Font.Blog.celltitle
                cell?.subtitleLabel!.font = Font.celltitle20r 
                cell?.msgDateLabel.font = Font.Blog.celldate
            }
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:self.postby!)
            query.limit = 1
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
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
            let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            let matches = detector?.matches(in: text!, options: [], range: NSRange(location: 0, length: (text?.utf16.count)!))
            
            for match in matches! {
                
                let webattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.weblinkText])
                
                let emailattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.emaillinkText])
                
                let phoneattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSBackgroundColorAttributeName: Color.Blog.phonelinkText])
                
                let dateattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSBackgroundColorAttributeName: Color.Blog.phonelinkText])
                
                if match.resultType == .link {
                    if match.url?.absoluteString.lowercased().range(of: "mailto:") != nil {
                        cell?.subtitleLabel!.attributedText = emailattributedText
                    } else {
                        cell?.subtitleLabel!.attributedText = webattributedText
                    }
                } else if match.resultType == .phoneNumber {
                    cell?.subtitleLabel!.attributedText = phoneattributedText
                } else if match.resultType == .date {
                    cell?.subtitleLabel!.attributedText = dateattributedText
                }
            }

/*
            let text = self.subject
            let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            
            detector?.enumerateMatches(in: text!, options: [], range: NSMakeRange(0, (text! as NSString).length)) { (result, flags, _) in
                
                let webattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.weblinkText])
                
                let emailattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSForegroundColorAttributeName: Color.Blog.emaillinkText])
                
                let phoneattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSBackgroundColorAttributeName: Color.Blog.phonelinkText])
                
                let dateattributedText = NSMutableAttributedString(string: text!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular), NSBackgroundColorAttributeName: Color.Blog.phonelinkText])
                
                if result!.resultType == .link {
                    
                    if result?.url?.absoluteString.lowercased().range(of: "mailto:") != nil {
                        cell?.subtitleLabel!.attributedText = emailattributedText
                    } else {
                        cell?.subtitleLabel!.attributedText = webattributedText
                    }
                } else if result?.resultType == .phoneNumber {
                    
                    cell?.subtitleLabel!.attributedText = phoneattributedText
                } else if result?.resultType == .date {
                    
                    cell?.subtitleLabel!.attributedText = dateattributedText
                }
            } */
//--------------------------------------------------
            
            return cell!
        }
        else { //----listViewTable--------------
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell") as! CustomTableCell!
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo: (self._feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as! String)
            query.limit = 1
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
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
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
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
            query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) in
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
        query1.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
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
