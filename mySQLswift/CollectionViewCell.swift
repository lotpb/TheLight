//
//  CCollectionViewCell.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/17/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
//import Parse
import AVFoundation

class CollectionViewCell: UICollectionViewCell {
    
//-----------youtube---------
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    lazy var playButton2: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0.9
        button.isUserInteractionEnabled = true
        let image = UIImage(named: "play_button.png")
        button.tintColor = .white
        button.setImage(image, for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CollectionViewCell.playVideo))
        button.addGestureRecognizer(tap)
        return button
    }()
    /*
    let activityIndicatorView2: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        //aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }() */
    
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
    
    func setupViews() {

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
 
        self.layer.cornerRadius = 7.0
        self.clipsToBounds = true
    }
    
}

class VideoCell: CollectionViewCell {
    /*
    var video: Video? {
        didSet {
     
        }
    } */
 
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .black
        imageView.image = UIImage(named: "taylor_swift_blank_space")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = UIImage(named: "taylor_swift_profile")
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        //cell.profileView?.tag = indexPath.row
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    
    let titleLabelnew: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Taylor Swift - Blank Space"
        label.numberOfLines = 2
        return label
    }()
    
    let subtitlelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TaylorSwiftVEVO • 1,604,684,607 views • 2 years ago"
        label.textColor = .lightGray
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let imagebutton : UIImage? = UIImage(named:"nav_more_icon.png")!.withRenderingMode(.alwaysTemplate)
        button.tintColor = .lightGray
        button.setImage(imagebutton, for: .normal)
        return button
    }()
    
    let likeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        let imagebutton : UIImage? = UIImage(named:"Thumb Up.png")!.withRenderingMode(.alwaysTemplate)
        button.tintColor = .lightGray
        button.setImage(imagebutton, for: .normal)
        return button
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
        //button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePlay))
        button.addGestureRecognizer(tap)
        return button
    }()

    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handlePlay(sender: UITapGestureRecognizer) {
        
        let button = sender.view as? UIButton
        if let videoURL = button!.titleLabel!.text {
            let URL = NSURL(string: videoURL)
            player = AVPlayer(url: URL! as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = (thumbnailImageView.bounds)
            thumbnailImageView.layer.addSublayer(playerLayer!)
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
        addSubview(thumbnailImageView)
        addSubview(separatorView)
        addSubview(userProfileImageView)
        addSubview(titleLabelnew)
        addSubview(subtitlelabel)
        addSubview(actionButton)
        addSubview(likeBtn)
        addSubview(numberLabel)
        addSubview(uploadbylabel)
        
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: thumbnailImageView)
        
        addConstraintsWithFormat(format: "H:|-16-[v0(44)]", views: userProfileImageView)
        
        addConstraintsWithFormat(format: "H:|-16-[v0(25)]", views: actionButton)
        
        //vertical constraints
        addConstraintsWithFormat(format: "V:|-16-[v0]-8-[v1(44)]-21-[v2(25)]-10-[v3(1)]|", views: thumbnailImageView, userProfileImageView, actionButton, separatorView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .top, relatedBy: .equal, toItem: thumbnailImageView, attribute: .bottom, multiplier: 1, constant: 6))
        //left constraint
        addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .left, relatedBy: .equal, toItem: userProfileImageView, attribute: .right, multiplier: 1, constant: 8))
        //right constraint
        addConstraint(NSLayoutConstraint(item: titleLabelnew, attribute: .right, relatedBy: .equal, toItem: thumbnailImageView, attribute: .right, multiplier: 1, constant: 0))
        
        thumbnailImageView.addSubview(playButton)
        //x,y,w,h
        playButton.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        thumbnailImageView.addSubview(activityIndicatorView)
        //x,y,w,h
        activityIndicatorView.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //height constraint
        titleLabelHeightConstraint = NSLayoutConstraint(item: titleLabelnew, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 44)
        addConstraint(titleLabelHeightConstraint!)

        //top constraint
        addConstraint(NSLayoutConstraint(item: subtitlelabel, attribute: .top, relatedBy: .equal, toItem: titleLabelnew, attribute: .bottom, multiplier: 1, constant: 1))
        //left constraint
        addConstraint(NSLayoutConstraint(item: subtitlelabel, attribute: .left, relatedBy: .equal, toItem: userProfileImageView, attribute: .right, multiplier: 1, constant: 8))
        //right constraint
        addConstraint(NSLayoutConstraint(item: subtitlelabel, attribute: .right, relatedBy: .equal, toItem: thumbnailImageView, attribute: .right, multiplier: 1, constant: 0))
        //height constraint
        addConstraint(NSLayoutConstraint(item: subtitlelabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 21))
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .top, relatedBy: .equal, toItem: subtitlelabel, attribute: .bottom, multiplier: 1, constant: 1))
        //left constraint
        addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .left, relatedBy: .equal, toItem: actionButton, attribute: .right, multiplier: 1, constant: 12))
        //right constraint
        //addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .Right, relatedBy: .Equal, toItem: thumbnailImageView, attribute: .Right, multiplier: 1, constant: 0))
        //height constraint
        addConstraint(NSLayoutConstraint(item: likeBtn, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 25))
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .top, relatedBy: .equal, toItem: subtitlelabel, attribute: .bottom, multiplier: 1, constant: 1))
        //left constraint
        addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .left, relatedBy: .equal, toItem: likeBtn, attribute: .right, multiplier: 1, constant: 1))
        //right constraint
        //addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .Right, relatedBy: .Equal, toItem: thumbnailImageView, attribute: .Right, multiplier: 1, constant: 0))
        //height constraint
        addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 25))
        
        //top constraint
        addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .top, relatedBy: .equal, toItem: subtitlelabel, attribute: .bottom, multiplier: 1, constant: 1))
        //left constraint
        addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .left, relatedBy: .equal, toItem: numberLabel, attribute: .right, multiplier: 1, constant: 5))
        //right constraint
      //addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .Right, relatedBy: .Equal, toItem: thumbnailImageView, attribute: .Right, multiplier: 1, constant: 0))
        //height constraint
        addConstraint(NSLayoutConstraint(item: uploadbylabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 25))
    }
}

