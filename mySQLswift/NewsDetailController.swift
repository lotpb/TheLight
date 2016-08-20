//
//  NewsDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import AVKit
import AVFoundation
//import MobileCoreServices //kUTTypeImage

class NewsDetailController: UIViewController, UITextViewDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 26, weight: UIFontWeightRegular)
    let ipadsubtitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    let ipadtextview = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newsImageview: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var newsTextview: UITextView!
    
    var image: UIImage!
    var objectId: String?
    var newsTitle: String?
    var newsDetail: String?
    var newsStory: String?
    var newsDate: String?
    
    //var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var playerViewController = AVPlayerViewController()
    var videoURL: String?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        let image = UIImage(named: "play_button.png")
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.setTitle(self.videoURL, for: UIControlState.normal)
        //button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("News Detail", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.newsImageview.backgroundColor = .black
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(NewsDetailController.editData))
        let buttons:NSArray = [editItem]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        //let playButton = UIButton(type: UIButtonType.custom) as UIButton

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            self.titleLabel.font = ipadtitle
            self.detailLabel.font = ipadsubtitle
            self.newsTextview.isEditable = true //bug fix
            self.newsTextview.font = ipadtextview
            self.newsTextview.isEditable = false //bug fix
            playButton.frame = CGRect(x: self.newsImageview.frame.size.width/2-140, y: self.newsImageview.frame.origin.y+100, width: 50, height: 50)
        } else {
            self.titleLabel.font = Font.News.newstitle
            self.detailLabel.font = Font.celllabel1
            self.newsTextview.isEditable = true//bug fix
            self.newsTextview.font = Font.News.newssource
            self.newsTextview.isEditable = false //bug fix
            playButton.frame = CGRect(x: self.newsImageview.frame.size.width/2, y: self.newsImageview.frame.height/2, width: 50, height: 50)
        }
        
        self.newsImageview.isUserInteractionEnabled = true
        self.newsImageview.image = self.image
        self.newsImageview.contentMode = .scaleToFill
        
        self.titleLabel.text = self.newsTitle
        self.titleLabel.numberOfLines = 2

        self.detailLabel.text = String(format: "%@ %@ %@", (self.newsDetail)!, "Uploaded", (self.newsDate)!)
        self.detailLabel.textColor = .lightGray
        self.detailLabel.sizeToFit()
        
        self.newsTextview.text = self.newsStory
        self.newsTextview.delegate = self
        self.newsTextview.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        // Make web links clickable
        self.newsTextview.isSelectable = true
        self.newsTextview.isEditable = false
        self.newsTextview.dataDetectorTypes = UIDataDetectorTypes.link
        
        let imageDetailurl = self.videoURL
        let result1 = imageDetailurl!.contains("movie.mp4")
        playButton.isHidden = result1 == false
        playButton.setTitle(imageDetailurl, for: UIControlState.normal)
        /*
         let result1 = self.videoURL?.contains("movie.mp4")
         if (result1 == true) {
         /*
         playButton.alpha = 0.9
         playButton.isUserInteractionEnabled = true
         let image : UIImage? = UIImage(named:"play_button.png")
         playButton.tintColor = .white
         playButton.setImage(image, for: .normal)
         //playButton.setTitle(self.imageFile.url, forState: UIControlState.Normal)
         let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
         playButton.addGestureRecognizer(tap) */
         
         self.newsImageview.addSubview(playButton)
         } */
        
    }
    
    //fix TextView Scroll first line
    override func viewWillAppear(_ animated: Bool) {
        self.newsTextview.isScrollEnabled = false
    }
    //fix TextView Scroll first line
    override func viewDidAppear(_ animated: Bool) {
        self.newsTextview.isScrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.newsImageview
    }
    
    // MARK: - Video
    
    func playVideo(_ sender: UITapGestureRecognizer) {
        
        let url = URL(string: self.videoURL!)
        player = AVPlayer(url: url!)
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect
        playerViewController.showsPlaybackControls = true
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            self.playerViewController.player?.play()
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func prepareForReuse() {
        //super.prepareForReuse()
        //playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    func setupViews() {
        
        newsImageview.addSubview(playButton)
        //x,y,w,h
        playButton.centerXAnchor.constraint(equalTo: newsImageview.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: newsImageview.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        newsImageview.addSubview(activityIndicatorView)
        //x,y,w,h
        activityIndicatorView.centerXAnchor.constraint(equalTo: newsImageview.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: newsImageview.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Button
    
    func editData(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "uploadSegue", sender: self)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "uploadSegue"
        {
            let photo = segue.destination as? UploadController
            
            photo!.formStat = "Update"
            photo!.objectId = self.objectId
            photo!.newsImage = self.newsImageview.image
            photo!.newstitle = self.titleLabel.text
            photo!.newsdetail = self.newsDetail
            photo!.newsStory = self.newsStory
            photo!.imageDetailurl = self.videoURL //as String
        }
    }


}
