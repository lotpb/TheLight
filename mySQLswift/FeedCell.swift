//
//  FeedCell.swift
//  youtube
//
//  Created by Brian Voong on 7/3/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

protocol UrlLookupDelegate {
    func urlController(passedData: String)
    func titleController(passedData: String)
    //func playVideo(videoURL: String)
    //func likesController(passedData: String)
}

import UIKit
import Parse
import AVFoundation

class FeedCell: CollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate:UrlLookupDelegate?
    
    var _feedItems : NSMutableArray = NSMutableArray()
    var imageObject :PFObject!
    var imageFile :PFFile!
    var selectedImage : UIImage?
    
    let cellId = "cellId"
    
    // MARK: NavigationController Hidden
    var lastContentOffset: CGFloat = 0.0
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white//Color.News.navColor
        refreshControl.tintColor = .lightGray
        let attributes = [NSForegroundColorAttributeName: UIColor.lightGray]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    func fetchVideos() {
        
        let query = PFQuery(className:"Newsios")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.collectionView.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        fetchVideos()
        backgroundColor = .brown
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        self.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView.addSubview(self.refreshControl)
    }
    
    // MARK: - refresh
    
    func refreshData() {
        fetchVideos()
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - NavigationController Hidden
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    
    // MARK: - Button
    
    func likeSetButton(sender:UIButton) {
        
        sender.tintColor = Color.BlueColor
        let hitPoint = sender.convert(CGPoint.zero, to: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: hitPoint)
        
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "objectId") as? String!)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                object!.incrementKey("Liked")
                object!.saveInBackground()
            }
        }
    }
    
    func shareButton(sender: UIButton) {
        
        let point : CGPoint = sender.convert(.zero, to: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        let socialText = (_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "newsTitle") as? String
        
        imageObject = _feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
            self.selectedImage = UIImage(data: imageData! as Data)
        }
        let image: UIImage = self.selectedImage!
        let activityViewController = UIActivityViewController (activityItems: [(image), socialText!], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = (sender)
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self._feedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? VideoCell else { fatalError("Unexpected Index Path") }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.titleLabelnew.font = Font.News.newstitlePad
            cell.subtitleLabel.font = Font.News.newssourcePad
            cell.numberLabel.font = Font.News.newslabel1Pad
            cell.uploadbylabel.font = Font.News.newslabel2Pad
            cell.storyLabel.font = Font.News.newslabel2Pad
            
        } else {
            cell.titleLabelnew.font = Font.News.newstitle
            cell.subtitleLabel.font = Font.News.newssource
            cell.numberLabel.font = Font.News.newslabel1
            cell.uploadbylabel.font = Font.News.newslabel2
            //cell.storyLabel.font = Font.News.newslabel1
        }
        
        cell.subtitleLabel.textColor = Color.DGrayColor
        cell.uploadbylabel.textColor = Color.DGrayColor
        
        imageObject = _feedItems.object(at: (indexPath).row) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
            
            UIView.transition(with: cell.thumbnailImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.selectedImage = UIImage(data: imageData!)
                cell.thumbnailImageView.image = self.selectedImage
            }, completion: nil)
        }
        
        //profile Image
        let query:PFQuery = PFUser.query()!
        query.whereKey("username",  equalTo:(self._feedItems[(indexPath).row] as AnyObject).value(forKey: "username") as! String)
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                        
                        UIView.transition(with: cell.userProfileImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            cell.userProfileImageView.image = UIImage(data: imageData!)
                        }, completion: nil)
                    }
                }
            }
        }
        
        cell.titleLabelnew.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsTitle") as? String
        cell.actionButton.addTarget(self, action: #selector(shareButton), for: UIControlEvents.touchUpInside)
        cell.likeBtn.addTarget(self, action: #selector(likeSetButton), for: UIControlEvents.touchUpInside)
        
        let date1 = ((self._feedItems[(indexPath).row] as AnyObject).value(forKey: "createdAt") as? Date)!
        let date2 = Date()
        let calendar = Calendar.current
        let diffDateComponents = calendar.dateComponents([.day], from: date1, to: date2)
        cell.subtitleLabel.text = String(format: "%@, %d%@" , ((self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsDetail") as? String)!, diffDateComponents.day!," days ago" )
        
        let updated:Date = date1
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "h:mm a"
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date1 as Date)
        let secondInDays: TimeInterval = 60 * 60 * 24
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MMM dd, yyyy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEEE"
        }
        
        let createString = dateFormatter.string(from: updated)
        cell.uploadbylabel.text = String(format: "%@ %@", "Uploaded", createString)
        
        let imageDetailurl = self.imageFile.url
        let result1 = imageDetailurl!.contains("movie.mp4")
        cell.playButton.isHidden = result1 == false
        cell.playButton.setTitle(imageDetailurl, for: .normal)
        
        var Liked:Int? = (_feedItems[(indexPath).row] as AnyObject).value(forKey: "Liked")as? Int
        if Liked == nil {
            Liked = 0
        }
        cell.numberLabel.text = "\(Liked!)"
        
        if !(cell.numberLabel.text! == "0") {
            cell.numberLabel.textColor = Color.News.buttonColor
        } else {
            cell.numberLabel.text! = ""
        }
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.storyLabel.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "storyText") as? String
        } else {
            cell.storyLabel.text = ""
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let size = CGSize.init(width: UIScreen.main.bounds.width, height: 275)
            return size
        } else {
            let height = (frame.width - 16 - 16) * 9 / 16
            return CGSize(width: frame.width, height: height + 16 + 88)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Segues
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        imageObject = _feedItems.object(at: indexPath.row) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
            
            let imageDetailurl = self.imageFile.url
            let result1 = imageDetailurl!.contains("movie.mp4")
            if (result1 == true) {
                /*
                 let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                 let vc = storyboard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
                 vc.videoURL = self.imageFile.url!
                 */
                
                //self.delegate? .urlController(passedData: self.imageFile.url!)
                
                //self.delegate? .titleController(passedData: ((self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String)!)
                
                /*
                 likesLookup = self.imageFile.url
                 self.delegate? .likesController(likesLookup!) */
                
                NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
                
            } else {
                
                self.selectedImage = UIImage(data: imageData! as Data)
                
                let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController
                
                vc.objectId = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                vc.newsTitle = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
                vc.newsDetail = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsDetail") as? String
                vc.newsDate = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
                vc.newsStory = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "storyText") as? String
                vc.image = self.selectedImage
                vc.videoURL = self.imageFile.url
                
                let navigationController = UINavigationController(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true)
                
            }
        }
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}



















