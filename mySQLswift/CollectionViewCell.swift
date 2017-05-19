//
//  CCollectionViewCell.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/17/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class CollectionViewCell: UICollectionViewCell {
    
//-----------youtube---------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    lazy var playButton2: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CollectionViewCell.playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()
    
    
    let activityIndicatorView1: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        //aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    var playerLayer2: AVPlayerLayer?
    var player2: AVPlayer?
    
    func playVideo(sender: UITapGestureRecognizer) {
        
        let button = sender.view as? UIButton
        if let videoURL = button!.titleLabel!.text {
            let URL = NSURL(string: videoURL)
            player2 = AVPlayer(url: URL! as URL)
            playerLayer2 = AVPlayerLayer(player: player2)
            playerLayer2?.frame = (user2ImageView?.bounds)!
            user2ImageView?.layer.addSublayer(playerLayer2!)
            player2?.play()
            loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            loadingSpinner?.startAnimating()
            playButton2.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer2?.removeFromSuperlayer()
        player2?.pause()
        loadingSpinner?.stopAnimating()
    }
    
//---------------------------------
    
    // News
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var profileView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var sourceLabel: UILabel?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var actionBtn: UIButton?
    @IBOutlet weak var numLabel: UILabel?
    @IBOutlet weak var uploadbyLabel: UILabel?
    
    // Snapshot Controller / UserView Controller
    @IBOutlet weak var user2ImageView: UIImageView?
    
    // Snapshot Controller / UserView Controller
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //self.layer.cornerRadius = 7.0
        //self.clipsToBounds = true
    }
    
}

class VideoCell: CollectionViewCell {
    
    var news: NewsModel? {
        didSet {
            
            guard let newsImageUrl = news?.imageUrl else {return}
            customImageView.loadImage(urlString: newsImageUrl)
            
            guard let userImageUrl = news?.imageUrl else {return}
            userProfileImageView.loadImage(urlString: userImageUrl)
            userProfileImageView.image = #imageLiteral(resourceName: "profile-rabbit-toy")
            
            titleLabelnew.text = news?.newsTitle
            subtitleLabel.text = news?.newsDetail
            storyLabel.text = news?.storyLabel
            uploadbylabel.text = news?.creationDate.timeAgoDisplay()
            
            var Liked:Int? = news?.liked as? Int
            if Liked == nil { Liked = 0 }
            numberLabel.text = "\(Liked!)"
            
            let imageDetailurl = newsImageUrl
            let result1 = imageDetailurl.contains("movie.mp4")
            playButton.isHidden = result1 == false
            playButton.setTitle(imageDetailurl, for: .normal)
        }
    }
 
    let customImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .black
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        //imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        //cell.profileView?.tag = indexPath.row
        return imageView
    }()
    
    let titleLabelnew: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.numberOfLines = 2
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .lightGray
        return label
    }()
    
    let storyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Comment by:"
        label.numberOfLines = 3
        return label
    }()
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10"
        label.textColor = .blue
        return label
    }()
    
    let uploadbylabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Uploaded by:"
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "nav_more_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let likeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "Thumb Up").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    
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
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()

    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    override func playVideo(sender: UITapGestureRecognizer) {
        
        let button = sender.view as? UIButton
        if let videoURL = button!.titleLabel!.text {
            let URL = NSURL(string: videoURL)
            player = AVPlayer(url: URL! as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = (customImageView.bounds)
            customImageView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    override func setupViews() {
        addSubview(customImageView)
        addSubview(separatorView)
        addSubview(userProfileImageView)
        addSubview(titleLabelnew)
        addSubview(subtitleLabel)
        addSubview(actionButton)
        addSubview(likeBtn)
        addSubview(numberLabel)
        addSubview(uploadbylabel)
        addSubview(storyLabel)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            //width constraints
            addConstraintsWithFormat(format: "H:|-16-[v0(400)]", views: customImageView)
            addConstraintsWithFormat(format: "H:|-450-[v0]-16-|", views: titleLabelnew)
            addConstraintsWithFormat(format: "H:|-450-[v0(44)]", views: userProfileImageView)
            addConstraintsWithFormat(format: "H:|-510-[v0]-16-|", views: subtitleLabel)
            addConstraintsWithFormat(format: "H:|-450-[v0]-16-|", views: storyLabel)
            addConstraintsWithFormat(format: "H:|-450-[v0(25)]", views: actionButton)
   
            //vertical constraints
            addConstraintsWithFormat(format: "V:|-0-[v0(1)]|", views: separatorView)
            addConstraintsWithFormat(format: "V:|-16-[v0(240)]|", views: customImageView)
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .top, relatedBy: .equal, toItem: customImageView, attribute: .top, multiplier: 1, constant: 0))
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: userProfileImageView, attribute: .top, relatedBy: .equal, toItem: titleLabelnew, attribute: .bottom, multiplier: 1, constant: 5))
            
            //Height Contraint
            let heightConstraint  = NSLayoutConstraint(item: userProfileImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
            addConstraints([heightConstraint])

            //top constraint
            addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 5))
            //left constraint
            addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .left, relatedBy: .equal, toItem: userProfileImageView, attribute: .right, multiplier: 1, constant: 12))
 
            //top constraint
            addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 5))

            //top constraint
            addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 5))
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: storyLabel, attribute: .top, relatedBy: .equal, toItem: likeBtn, attribute: .bottom, multiplier: 1, constant: 5))
            
            addConstraint(NSLayoutConstraint(item: storyLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 65))
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: actionButton, attribute: .top, relatedBy: .equal, toItem: storyLabel, attribute: .bottom, multiplier: 1, constant: 10))
            
            //left constraint
            addConstraint(NSLayoutConstraint(item: actionButton, attribute: .left, relatedBy: .equal, toItem: customImageView, attribute: .right, multiplier: 1, constant: 30))

        } else {
            
            addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: customImageView)
            addConstraintsWithFormat(format: "H:|-16-[v0(44)]", views: userProfileImageView)
            addConstraintsWithFormat(format: "H:|-26-[v0(25)]", views: actionButton)
            
            //vertical constraints
            addConstraintsWithFormat(format: "V:|-16-[v0]-8-[v1(44)]-21-[v2(25)]-10-[v3(1)]|", views: customImageView, userProfileImageView, actionButton, separatorView)
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .top, relatedBy: .equal, toItem: customImageView, attribute: .bottom, multiplier: 1, constant: 6))
            
            //left constraint
            addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .left, relatedBy: .equal, toItem: userProfileImageView, attribute: .right, multiplier: 1, constant: 8))

            //top constraint
            addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 1))
            //left constraint
            addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .left, relatedBy: .equal, toItem: actionButton, attribute: .right, multiplier: 1, constant: 14))
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 1))
            
            //top constraint
            addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .top, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 1))
        }
        
        //all Contraints
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
        
        //left constraint
        addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .left, relatedBy: .equal, toItem: userProfileImageView, attribute: .right, multiplier: 1, constant: 8))
        //right constraint
        addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .right, relatedBy: .equal, toItem: customImageView, attribute: .right, multiplier: 1, constant: 0))
        
        //height constraint
        titleLabelHeightConstraint = NSLayoutConstraint(item: titleLabelnew, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 44)
        addConstraint(titleLabelHeightConstraint!)
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabelnew, attribute: .bottom, multiplier: 1, constant: 1))

        //height constraint
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 21))
        
        addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 25))
        
        
        //left constraint
        addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .left, relatedBy: .equal, toItem: likeBtn, attribute: .right, multiplier: 1, constant: 1))

        addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 25))
        
        //left constraint
        addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .left, relatedBy: .equal, toItem: numberLabel, attribute: .right, multiplier: 1, constant: 5))
        //right constraint
 
        //height constraint
        addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 25))
        
        customImageView.addSubview(playButton)
        //x,y,w,h
        playButton.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        customImageView.addSubview(activityIndicatorView)
        //x,y,w,h
        activityIndicatorView.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
   
    }
}

