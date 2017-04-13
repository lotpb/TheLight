//
//  BlogEditViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/14/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class BlogEditController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var listTableView: UITableView?
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet weak var Like: UIButton?
    @IBOutlet weak var update: UIButton?
    
    var _feedItems : NSMutableArray = NSMutableArray()
    var _feedItems1 : NSMutableArray = NSMutableArray()
    var filteredString : NSMutableArray = NSMutableArray()
    var objects = [AnyObject]()
    var pasteBoard = UIPasteboard.general
 
    var objectId : String?
    var msgNo : String?
    var postby : String?
    var subject : String?
    var msgDate : String?
    var rating : String?
    var replyId : String?
    var liked : Int?
    //added reply
    var posttoIndex: String?
    var userIndex: String?
    var isReplyClicked = false
    var defaults = UserDefaults.standard
    
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

        let actionBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        let trashBtn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [actionBtn,trashBtn]
        
        self.toolBar!.barTintColor = .white
        self.toolBar!.isTranslucent = false
        self.toolBar!.layer.masksToBounds = true
        
        self.Like!.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        self.Like!.setTitleColor(.gray, for: .normal)
        
        setupTableView()
        setupForm()
        parseData()
        self.tableView!.addSubview(self.refreshControl)
        self.listTableView!.register(BlogReplyTableCell.self, forCellReuseIdentifier: "ReplyCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTwitterNavigationBarItems()
        self.navigationController?.isNavigationBarHidden = false //fix
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
        topBorder.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5)
        topBorder.borderWidth = width
        self.toolBar!.layer.addSublayer(topBorder)
        
        let bottomBorder = CALayer()
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        bottomBorder.frame = CGRect(x: 0, y: 43, width: view.bounds.width, height: 0.5)
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

    // MARK: - Button
    
    @IBAction func updateButton(sender: UIButton) {
        
        self.performSegue(withIdentifier: "blogeditSegue", sender: self)
    }
    
    func likeButton(sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = Color.twitterBlue
        let hitPoint = sender.convert(CGPoint.zero, to: self.listTableView)
        let indexPath = self.listTableView!.indexPathForRow(at: hitPoint)
        
        let query = PFQuery(className:"Blog")
        query.whereKey("objectId", equalTo: ((_feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("Liked")
                object!.saveInBackground()
            }
        }
    }
    
    func shareButton(_ sender: AnyObject) {
        
        let AV = UIActivityViewController (
            activityItems: [self.subject! as String],
            applicationActivities: nil)
        
        if let popoverController = AV.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(AV, animated: true)
    }
 
    func deleteButton(_ sender: AnyObject) {
        deleteBlog(name: self.objectId!)
    }
    
    func deleteBlog(name: String) {
        
        let alertController = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            let query = PFQuery(className:"Blog")
            query.whereKey("objectId", equalTo: name)
            query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground()
                        //self.deincrementComment()
                        self.navigationController?.popViewController(animated: true)
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
    
    
    // MARK: - AlertController
    
    func replyShare(sender: UIButton) {
        
        let hitPoint = sender.convert(CGPoint.zero, to: self.listTableView)
        let indexPath = self.listTableView!.indexPathForRow(at: hitPoint)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let replyAction = UIAlertAction(title: "Reply", style: .default) { (alert: UIAlertAction!) in
   
            self.isReplyClicked = true
            self.posttoIndex = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "PostBy") as? String
            self.userIndex = self.objectId
            self.performSegue(withIdentifier: "blogeditSegue", sender: self)
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (alert: UIAlertAction!) in
            
            self.isReplyClicked = false
            self.objectId = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String
            self.msgNo = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "MsgNo") as? String
            self.postby = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "PostBy") as? String
            self.subject = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Subject") as? String
            self.msgDate = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "MsgDate") as? String
            self.rating = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Rating") as? String
            self.liked = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Liked") as? Int
            self.replyId = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "ReplyId") as? String
            
            self.performSegue(withIdentifier: "blogeditSegue", sender: self)
        }
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (alert: UIAlertAction!) in
            
             self.pasteBoard.string = (self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "Subject") as? String
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) in
            
            self.deleteBlog(name: ((self._feedItems1.object(at: (indexPath?.row)!) as AnyObject).value(forKey: "objectId") as? String)!)
            self.deincrementComment()
        }
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) in
        }
        actionSheet.addAction(replyAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(copyAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(dismissAction)
        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            //actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        self.present(actionSheet, animated: true)
    }
    
    // MARK: - Deincrement Comment
    func deincrementComment() {
        let query = PFQuery(className:"Blog")
        query.whereKey("objectId", equalTo: self.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object?.incrementKey("CommentCount", byAmount: -1)
                object?.saveInBackground()
            }
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
            if isReplyClicked == true {
                VC!.formStatus = "Reply"
                VC!.textcontentsubject = String(format: "%@", "@\(posttoIndex!.removingWhitespaces()) ")
                VC!.textcontentpostby = defaults.string(forKey: "usernameKey")
                VC!.replyId = String(format:"%@", userIndex!)
            } else {
                VC!.formStatus = "None"
                VC!.textcontentobjectId = self.objectId
                VC!.textcontentmsgNo = self.msgNo
                VC!.textcontentpostby = self.postby
                VC!.textcontentsubject = self.subject
                VC!.textcontentdate = self.msgDate
                VC!.textcontentrating = self.rating
                VC!.textcontentreplyId = self.replyId
                VC!.liked = self.liked
            }
        }
    }
}

class BlogReplyTableCell: UITableViewCell {
    
        override init(style: UITableViewCellStyle, reuseIdentifier: String?){
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.setupViews()
        }
    
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        let replyImageView: CustomImageView = {
            let imageView = CustomImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "")
            imageView.layer.cornerRadius = 22
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 0.5
            imageView.isUserInteractionEnabled = true
            return imageView
        }()
        
        let replytitleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = ""
            return label
        }()
        
        let replysubtitleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = ""
            label.textColor = .lightGray
            label.numberOfLines = 4
            return label
        }()
        
        let replylikeBtn: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isUserInteractionEnabled = true
            button.tintColor = .lightGray
            button.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
            return button
        }()
        
        let replyactionBtn: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .lightGray
            button.setImage(#imageLiteral(resourceName: "nav_more_icon").withRenderingMode(.alwaysTemplate), for: .normal)
            return button
        }()
        
        let replylikeLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "10"
            label.textColor = .blue
            return label
        }()
        
        let replydateLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Uploaded by:"
            return label
        }()
        
    func setupViews() {
        
        addSubview(replyImageView)
        replyImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        replyImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        replyImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        replyImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(replytitleLabel)
        replytitleLabel.topAnchor.constraint(equalTo: replyImageView.topAnchor, constant: 0).isActive = true
        replytitleLabel.leftAnchor.constraint(equalTo: replyImageView.rightAnchor, constant: 10).isActive = true
        replytitleLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        addSubview(replyactionBtn)
        replyactionBtn.topAnchor.constraint(equalTo: replyImageView.topAnchor, constant: 2).isActive = true
        replyactionBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        replyactionBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        replyactionBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(replysubtitleLabel)
        replysubtitleLabel.topAnchor.constraint(equalTo: replytitleLabel.bottomAnchor, constant: 0).isActive = true
        replysubtitleLabel.leftAnchor.constraint(equalTo: replyImageView.rightAnchor, constant: 10).isActive = true
        replysubtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        addSubview(replylikeBtn)
        replylikeBtn.topAnchor.constraint(equalTo: replysubtitleLabel.bottomAnchor, constant: 0).isActive = true
        replylikeBtn.leftAnchor.constraint(equalTo: replyImageView.rightAnchor, constant: 10).isActive = true
        replylikeBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        replylikeBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(replylikeLabel)
        replylikeLabel.topAnchor.constraint(equalTo: replysubtitleLabel.bottomAnchor, constant: 0).isActive = true
        replylikeLabel.leftAnchor.constraint(equalTo: replylikeBtn.rightAnchor, constant: 0).isActive = true
        replylikeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(replydateLabel)
        replydateLabel.topAnchor.constraint(equalTo: replysubtitleLabel.bottomAnchor, constant: 0).isActive = true
        replydateLabel.leftAnchor.constraint(equalTo: replylikeLabel.rightAnchor, constant: 6).isActive = true
        replydateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        replydateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
    }
}
extension BlogEditController: UITableViewDataSource {
    
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
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableCell else { fatalError("Unexpected Index Path") }
            
            cell.selectionStyle = .none
            cell.subtitleLabel?.textColor = Color.twitterText
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                
                cell.titleLabel!.font = Font.Blog.celltitlePad
                cell.subtitleLabel!.font = Font.Blog.cellsubtitlePad
                cell.msgDateLabel.font = Font.Blog.celldatePad
                
            } else {
                
                cell.titleLabel!.font = Font.Blog.celltitle
                cell.subtitleLabel!.font = Font.celltitle20r
                cell.msgDateLabel.font = Font.Blog.celldate
            }
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:self.postby!)
            query.limit = 1
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
                            cell.blogImageView?.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
            
            let dateStr = self.msgDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date:Date = dateFormatter.date(from: (dateStr)! as String)!
            dateFormatter.dateFormat = "MM/dd/yy, h:mm a"
            
            cell.titleLabel!.text = self.postby
            cell.subtitleLabel!.text = self.subject
            cell.msgDateLabel.text = dateFormatter.string(from: (date) as Date)
            
            //---------------------NSDataDetector 1 of 2-----------------------------
            
            let text = (self.subject!) as NSString
            let attributedText = NSMutableAttributedString(string: text as String)
            
            let boldRange = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: Color.Blog.weblinkText]
            let highlightedRange = [NSBackgroundColorAttributeName: Color.Blog.phonelinkText]
            let underlinedRange = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
            let tintedRange1 = [NSForegroundColorAttributeName: Color.Blog.weblinkText]
            
            attributedText.addAttributes(boldRange, range: text.range(of: "VCSY"))
            attributedText.addAttributes(highlightedRange, range: text.range(of: "(516)241-4786"))
            attributedText.addAttributes(underlinedRange, range: text.range(of: "Lost", options: .caseInsensitive))
            attributedText.addAttributes(underlinedRange, range: text.range(of: "Made", options: .caseInsensitive))
            
            let input = self.subject
            let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            let matches = detector?.matches(in: input!, options: [], range: NSRange(location: 0, length: (input?.utf16.count)!))
            
            for match in matches! {
                let url = input?.substring(with: match.range.range(for: text as String)!)
                attributedText.addAttributes(tintedRange1, range: text.range(of: url!))
            }
            
            cell.subtitleLabel!.attributedText = attributedText
            
            //--------------------------------------------------
            
            return cell
        }
        else {
            //-------------------listViewTable--------------
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as? BlogReplyTableCell else { fatalError("Unexpected Index Path") }
            
            cell.selectionStyle = .none
            cell.replydateLabel.textColor = .gray
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo: (self._feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as! String)
            query.limit = 1
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
                            cell.replyImageView.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                
                cell.replytitleLabel.font = Font.BlogEdit.replytitlePad
                cell.replysubtitleLabel.font = Font.BlogEdit.replysubtitlePad
                cell.replylikeLabel.font = Font.BlogEdit.replytitlePad
                cell.replydateLabel.font = Font.BlogEdit.replysubtitlePad
                
            } else {
                
                cell.replytitleLabel.font = Font.BlogEdit.replytitle
                cell.replysubtitleLabel.font = Font.BlogEdit.replysubtitle
                cell.replylikeLabel.font = Font.BlogEdit.replytitle
                cell.replydateLabel.font = Font.BlogEdit.replysubtitle
            }
            
            cell.replytitleLabel.text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "PostBy") as? String
            cell.replysubtitleLabel.text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as? String
            cell.replylikeBtn.addTarget(self, action: #selector(likeButton), for: .touchUpInside)
            cell.replyactionBtn.addTarget(self, action: #selector(replyShare), for: .touchUpInside)
            
            var Liked:Int? = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Liked") as? Int
            if Liked == nil { Liked = 0 }
            cell.replylikeLabel.text = "\(Liked!)"
            
            let date1 = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
            let date2 = Date()
            let calendar = Calendar.current
            let diffDateComponents = calendar.dateComponents([.day], from: date1!, to: date2)
            cell.replydateLabel.text = String(format: "%d%@", diffDateComponents.day!," days ago" )
            
            if !(cell.replylikeLabel.text! == "0") {
                cell.replylikeLabel.textColor = Color.twitterBlue
            } else {
                cell.replylikeLabel.text! = ""
            }
            
            //---------------------NSDataDetector 2 of 2-----------------------------
            
            let text = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as! NSString
            let attributedText = NSMutableAttributedString(string: text as String)
            let tintedRange1 = [NSForegroundColorAttributeName: Color.Blog.weblinkText]
            
            let textName = String(format: "%@", "@\(self.postby!.removingWhitespaces())")
            attributedText.addAttributes(tintedRange1, range: text.range(of: textName))
            
            let input = (_feedItems1[indexPath.row] as AnyObject).value(forKey: "Subject") as? String
            let types: NSTextCheckingResult.CheckingType = [.date, .phoneNumber, .link]
            let detector = try? NSDataDetector(types: types.rawValue)
            let matches = detector?.matches(in: input!, options: [], range: NSRange(location: 0, length: (input?.utf16.count)!))
            
            for match in matches! {
                let url = input?.substring(with: match.range.range(for: text as String)!)
                attributedText.addAttributes(tintedRange1, range: text.range(of: url!))
            }
            
            cell.replysubtitleLabel.attributedText = attributedText
            
            //--------------------------------------------------
            
            return cell
        } 
    }
}

extension BlogEditController: UITableViewDelegate {
    
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
}
