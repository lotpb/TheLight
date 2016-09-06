//
//  FeedCell.swift
//  youtube
//
//  Created by Brian Voong on 7/3/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class FeedCell: CollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var _feedItems : NSMutableArray = NSMutableArray()
    var imageObject :PFObject!
    var imageFile :PFFile!
    var selectedImage : UIImage?
    var refreshControl: UIRefreshControl!
    
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
    
    let cellId = "cellId"
    
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
        
        self.refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white//Color.News.navColor
        refreshControl.tintColor = .lightGray
        let attributes = [NSForegroundColorAttributeName: UIColor.lightGray]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        self.collectionView.addSubview(refreshControl)
        
        fetchVideos()
        
        backgroundColor = .brown
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    // MARK: - refresh
    
    func refreshData() {
        fetchVideos()
        self.collectionView.reloadData()
        self.refreshControl?.endRefreshing()
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
        UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self._feedItems.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoCell
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            cell.titleLabelnew.font = Font.News.newstitle
            cell.subtitlelabel.font = Font.News.newssource
            cell.numberLabel.font = Font.News.newslabel1
            cell.uploadbylabel.font = Font.News.newslabel2
            
        } else {
            cell.titleLabelnew.font = Font.News.newstitle
            cell.subtitlelabel.font = Font.News.newssource
            cell.numberLabel.font = Font.News.newslabel1
            cell.uploadbylabel.font = Font.News.newslabel2
        }
        
        cell.subtitlelabel.textColor = Color.DGrayColor
        cell.uploadbylabel.textColor = Color.DGrayColor
        
        imageObject = _feedItems.object(at: (indexPath as NSIndexPath).row) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile!.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
            self.selectedImage = UIImage(data: imageData!)
            cell.thumbnailImageView.image = self.selectedImage
            
            /*
            let URL = NSURL(string: self.imageFile.url!)
            let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: URL!)
            cell.thumbnailImageView.image = thumbnailImage */
            
        }
        
        //profile Image
        let query:PFQuery = PFUser.query()!
        query.whereKey("username",  equalTo:(self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "username") as! String)
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                        cell.userProfileImageView.image = UIImage(data: imageData!)
                    }
                }
            }
        }
        
        cell.titleLabelnew.text = (self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "newsTitle") as? String
        cell.actionButton.addTarget(self, action: #selector(shareButton), for: UIControlEvents.touchUpInside)
        cell.likeBtn.addTarget(self, action: #selector(likeSetButton), for: UIControlEvents.touchUpInside)
        
        let date1 = ((self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "createdAt") as? Date)!
        let date2 = Date()
        let calendar = Calendar.current
        let diffDateComponents = calendar.dateComponents([.day], from: date1, to: date2)
        cell.subtitlelabel.text = String(format: "%@, %d%@" , ((self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "newsDetail") as? String)!, diffDateComponents.day!," days ago" )
        
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
        cell.playButton.setTitle(imageDetailurl, for: UIControlState.normal)
        
        var Liked:Int? = (_feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "Liked")as? Int
        if Liked == nil {
            Liked = 0
        }
        cell.numberLabel.text = "\(Liked!)"
        
        if !(cell.numberLabel.text! == "0") {
            cell.numberLabel.textColor = Color.News.buttonColor
        } else {
            cell.numberLabel.text! = ""
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (frame.width - 16 - 16) * 9 / 16
        return CGSize(width: frame.width, height: height + 16 + 88)
        //let size = CGSize.init(width: UIScreen.main.bounds.width, height: 300)
        //return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    /*
    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage? {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    } */
    
    
    // MARK: - Segues

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        imageObject = _feedItems.object(at: indexPath.row) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
            
            let imageDetailurl = self.imageFile.url
            let result1 = imageDetailurl!.contains("movie.mp4")
            if (result1 == true) {
                
                let videoLauncher = VideoLauncher()
                videoLauncher.videoURL = self.imageFile.url
                videoLauncher.showVideoPlayer()
                
            } else {
                self.selectedImage = UIImage(data: imageData! as Data)
                //self.performSegue(withIdentifier: "newsdetailSeque", sender: self)

                let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController

                vc.objectId = (self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "objectId") as? String
                vc.newsTitle = (self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "newsTitle") as? String
                vc.newsDetail = (self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "newsDetail") as? String
                vc.newsDate = (self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "createdAt") as? Date
                vc.newsStory = (self._feedItems[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "storyText") as? String
                vc.image = self.selectedImage
                vc.videoURL = self.imageFile.url

                let navigationController = UINavigationController(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "newsdetailSeque"
        {

        }
    }

}


















