//
//  FeedCell.swift
//  youtube
//
//  Created by Brian Voong on 7/3/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//


import UIKit
import Parse
import Firebase
import AVFoundation

class FeedCell: CollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var newslist = [NewsModel]()
    
    var _feedItems = NSMutableArray()
    var imageObject :PFObject!
    var imageFile :PFFile!
    var selectedImage : UIImage?
    var defaults = UserDefaults.standard
    
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
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        
        backgroundColor = .brown
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        self.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView.addSubview(self.refreshControl)
        self.fetchVideos()
    }
    
    // MARK: - Parse
    
    func fetchVideos() {
        
        if (self.defaults.bool(forKey: "parsedataKey"))  {
            
            let query = PFQuery(className:"Newsios")
            query.limit = 1000
            query.cachePolicy = .cacheThenNetwork
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { objects, error in
                if error == nil {
                    let temp: NSArray = objects! as NSArray
                    self._feedItems = temp.mutableCopy() as! NSMutableArray
                    //DispatchQueue.main.async { //added
                    self.collectionView.reloadData()
                    //}
                } else {
                    print("Errortube")
                }
            }
        } else {
            //firebase
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
            let ref = FIRDatabase.database().reference().child("News").child(uid)
            ref.observe(.childAdded , with:{ (snapshot) in
    
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                
                let newsTxt = NewsModel(dictionary: dictionary)
                self.newslist.append(newsTxt)
                print(newsTxt)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
  
    // MARK: - refresh
    
    func refreshData() {
        fetchVideos()
        DispatchQueue.main.async { //added
            self.collectionView.reloadData()
        }
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
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            let query = PFQuery(className:"Newsios")
            query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "objectId") as? String!)!)
            query.getFirstObjectInBackground { object, error in
                if error == nil {
                    object!.incrementKey("Liked")
                    object!.saveInBackground()
                }
            }
        } else {
            
        }
    }
    
    func shareButton(sender: UIButton) {
        
        let point : CGPoint = sender.convert(.zero, to: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        let socialText = (_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "newsTitle") as? String
        
        imageObject = _feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile.getDataInBackground { imageData, error in
            
            self.selectedImage = UIImage(data: imageData!)
        }
        let image: UIImage = self.selectedImage!
        let activityViewController = UIActivityViewController (activityItems: [(image), socialText!], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = (sender)
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true)
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            return self._feedItems.count
        } else {
            return self.newslist.count
        }
        //return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? VideoCell else { fatalError("Unexpected Index Path") }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
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
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            imageObject = _feedItems.object(at: (indexPath).row) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile.getDataInBackground { data, error in
                if error == nil {
                    UIView.transition(with: cell.customImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.selectedImage = UIImage(data: data!)
                        cell.customImageView.image = UIImage(data: data!) //self.selectedImage
                    }, completion: nil)
                }
            }
            
            //profile Image
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:(self._feedItems[(indexPath).row] as AnyObject).value(forKey: "username") as! String)
            query.cachePolicy = .cacheThenNetwork
            query.getFirstObjectInBackground { object, error in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { imageData, error in
                            
                            UIView.transition(with: cell.userProfileImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                cell.userProfileImageView.image = UIImage(data: imageData!)
                            }, completion: nil)
                        }
                    }
                }
            }
            
            cell.titleLabelnew.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsTitle") as? String
            cell.actionButton.addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeSetButton), for: .touchUpInside)
            
            var newsView:Int? = (_feedItems[(indexPath).row] as AnyObject).value(forKey: "newsView")as? Int
            if newsView == nil { newsView = 0 }
            let date1 = ((self._feedItems[(indexPath).row] as AnyObject).value(forKey: "createdAt") as? Date)!
            let date2 = Date()
            let calendar = Calendar.current
            let diffDateComponents = calendar.dateComponents([.day], from: date1, to: date2)
            cell.subtitleLabel.text = String(format: "%@, %@, %d%@", ((self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsDetail") as? String)!, "\(newsView!) views", diffDateComponents.day!," days ago" )
            
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
            if Liked == nil { Liked = 0 }
            cell.numberLabel.text = "\(Liked!)"
            
        } else {
            
            //firebase
            cell.news = newslist[indexPath.item]
            
        }
        
        if !(cell.numberLabel.text! == "0") {
            cell.numberLabel.textColor = Color.News.buttonColor
        } else {
            cell.numberLabel.text! = ""
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if (defaults.bool(forKey: "parsedataKey"))  {
                cell.storyLabel.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "storyText") as? String
            } else {
                //firebase
            }
        } else {
            cell.storyLabel.text = ""
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
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
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            imageObject = _feedItems.object(at: indexPath.row) as! PFObject
        } else {
            //firebase
        }
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile.getDataInBackground { imageData, error in
            
            
            let imageDetailurl = self.imageFile.url
            let result1 = imageDetailurl!.contains("movie.mp4")
            if (result1 == true) {
                
                NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
                
            } else {
                
                self.selectedImage = UIImage(data: imageData! as Data)
                
                let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailController") as! NewsDetailController
                
                if (self.defaults.bool(forKey: "parsedataKey"))  {
                    vc.objectId = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "objectId") as? String
                    vc.newsTitle = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsTitle") as? String
                    vc.newsDetail = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "newsDetail") as? String
                    vc.newsDate = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "createdAt") as? Date
                    vc.newsStory = (self._feedItems[indexPath.row] as AnyObject).value(forKey: "storyText") as? String
                } else {
                    //firebase
                }
                
                vc.image = self.selectedImage
                vc.videoURL = self.imageFile.url
                
                let navigationController = UINavigationController(rootViewController: vc)
                UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true)
                
            }
        }
    }
}



















