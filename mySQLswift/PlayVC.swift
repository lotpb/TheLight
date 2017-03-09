//
//  PlayVC.swift
//  YouTube
//
//  Created by Haik Aslanyan on 7/25/16.
//  Copyright © 2016 Haik Aslanyan. All rights reserved.
//
protocol PlayerVCDelegate {
    func didMinimize()
    func didmaximize()
    func swipeToMinimize(translation: CGFloat, toState: stateOfVC)
    func didEndedSwipe(toState: stateOfVC)
}

import UIKit
import AVFoundation
import Parse

class PlayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    //MARK: Properties
    
    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var containView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var player = AVPlayer.init()
    private var playerLayer: AVPlayerLayer?
    var videoURL: String?
    var isPlaying = true
    var gradientLayer = CAGradientLayer()
    
    var delegate: PlayerVCDelegate?
    var state = stateOfVC.hidden
    var direction = Direction.none
    
    var _feedItems: NSMutableArray = NSMutableArray()
    var imageObject: PFObject!
    var imageFile: PFFile!
    
    var titleLookup: String?
    var viewLookup: String?
    var likesLookup: String?
    var dislikesLookup: String?
    var imageLookup: String?
    var selectedImage : UIImage?
    var selectedChannelPic : UIImage?

    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    lazy var minimizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "minimize"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(minimize), for: .touchUpInside)
        return button
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containView.backgroundColor = .clear
        self.customization()
        self.setupConstraints()
        self.fetchVideos()
 
        if videoURL == nil {
            videoURL = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        }
        self.playVideo(videoURL: videoURL!)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func prepareToDeinit() {
        
        self.resetPlayer()
    }
    
    open func resetPlayer() {
        
        self.player.pause()
        self.playerLayer?.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Video Player
    
    private func playVideo(videoURL: String) {
        
        self.player.pause()
        
        if let url = NSURL(string: videoURL) {
            DispatchQueue.main.async(execute: {
                self.player = AVPlayer(url: url as URL)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill //AVLayerVideoGravityResizeAspectFill
                //self.playerLayer?.frame = self.playerView.bounds
                self.playerView.layer.addSublayer(self.playerLayer!)
                if self.state != .hidden {
                    self.player.play()

                }
                //self.loopVideo(videoPlayer: self.videoPlayer)
                self.playDidEnd(videoPlayer: self.player)
                self.setupGradientLayer()
                self.setupTimeRanges()//must keep below videoPlayer.play()
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = containView.bounds
    }

    
    // MARK: - Setup View
    
    func setupConstraints() {
        
        //make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        
        containView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
        
        containView.addSubview(minimizeButton)
        minimizeButton.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 20).isActive = true
        minimizeButton.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 20).isActive = true
        minimizeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        minimizeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        containView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
        //pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -2).isActive = true
        //videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        containView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 8).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -2).isActive = true
        //currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        for label in [pausePlayButton, videoLengthLabel, currentTimeLabel] as [Any] {
            (label as AnyObject).widthAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        containView.addSubview(videoSlider)
        videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
        videoSlider.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func customization() {
        
        self.view.backgroundColor = .clear
        self.playerView.layer.anchorPoint.applying(CGAffineTransform.init(translationX: -0.5, y: -0.5))
        self.tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.containView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(PlayVC.tapPlayView)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(tapPlayView), name: NSNotification.Name("open"), object: nil)
    }
    
    /*
     @IBAction func backwardTouch(sender: AnyObject) {
     playerVideo.rate = playerVideo.rate - 0.5
     }
     
     @IBAction func playTouch(sender: AnyObject) {
     if playerVideo.rate == 0 {
     playerVideo.play()
     } else {
     playerVideo.pause()
     }
     }
     
     @IBAction func fowardTouch(sender: AnyObject) {
     playerVideo.rate = playerVideo.rate + 0.5
     } */
    
    func animate()  {
        switch self.state {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, animations: {
                self.minimizeButton.alpha = 1
                self.containView.alpha = 1
                self.tableView.alpha = 1
                self.playerView.transform = CGAffineTransform.identity
                UIApplication.shared.isStatusBarHidden = true
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                UIApplication.shared.isStatusBarHidden = false
                self.minimizeButton.alpha = 0
                self.containView.alpha = 0
                self.tableView.alpha = 0
                let scale = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -self.playerView.bounds.width/4, y: -self.playerView.bounds.height/4))
                self.playerView.transform = trasform
            })
        default: break
        }
    }
    
    // MARK: - Setup Video Container
    
    private func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = playerView.bounds //CGRect(x: 64, y: 64, width: 160, height: 160)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        playerView.layer.addSublayer(gradientLayer)
    }
    
    func handlePause() {
        if isPlaying {
            player.pause()
            pausePlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            player.play()
            pausePlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    func handleSliderChange() {
        
        print(videoSlider.value)
        if let duration = player.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }

    private func setupTimeRanges() {
        
        self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        //track player progress
        let interval = CMTime(value: 1, timescale: 2)
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            //lets move the slider thumb
            if let duration = self.player.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
            }
        })
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            containView.backgroundColor = .clear
            self.hideControlObjects()
            isPlaying = true
            
            if let duration = player.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    
    func showControlObjects() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.pausePlayButton.alpha = 1
            self.minimizeButton.alpha = 1
            self.currentTimeLabel.alpha = 1
            self.videoSlider.alpha = 1
            self.videoLengthLabel.alpha = 1
            self.gradientLayer.isHidden = false
        }, completion: {
            Bool in
            //self.panelVisible = true
        })
     }
    
    
    func hideControlObjects() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.pausePlayButton.alpha = 0
            self.minimizeButton.alpha = 0
            self.currentTimeLabel.alpha = 0
            self.videoSlider.alpha = 0
            self.videoLengthLabel.alpha = 0
            self.gradientLayer.isHidden = true

        }, completion: {
            Bool in
            //self.panelVisible = false
        })
    }
    
    // return to start Video
    func playDidEnd(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in

            self.player.seek(to: kCMTimeZero, completionHandler: {
                Bool in
                self.videoSlider.setValue(0.0, animated: true)
                self.showControlObjects()
                self.handlePause()
            })
        }
    }
    
    /*
    // repeat Video
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            
            videoPlayer.seek(to: kCMTimeZero)
            videoPlayer.play()
        }
    } */
    
    
    // MARK: - Parse Subscribed
    
    func subscribedParse() {
        
        let query = PFObject(className:"User")
        query.add([(PFUser.current()?.objectId)!], forKey:"Subscribed")
        query.saveInBackground {(success: Bool, error: Error?) in
            if success == true {
                print("Yes")
            } else {
                print("No")
            }
        }
        /*
         let array = ["Peter Balsamo", "Crap"]
         let query = PFObject(className:"User")
         query["Subscribed"] = array
         query.saveInBackground() */
    }
    
    // MARK: - Button
    
    func setSubscribed(_ sender: UIButton) {
        
        if (sender.titleLabel!.text == " UNSUBSCRIBE")   {
            sender.setTitle(" SUBSCRIBE", for: .normal)
            sender.setTitleColor(Color.youtubeRed, for: .normal)
            sender.tintColor = Color.youtubeRed
            sender.setImage(#imageLiteral(resourceName: "iosStar").withRenderingMode(.alwaysTemplate), for: .normal)
            sender.addTarget(self, action: #selector(subscribedParse), for: .touchUpInside)
        } else {
            sender.setTitle(" UNSUBSCRIBE", for: .normal)
            sender.setTitleColor(Color.DGrayColor, for: .normal)
            sender.tintColor = Color.DGrayColor
            sender.setImage(#imageLiteral(resourceName: "iosStarNA").withRenderingMode(.alwaysTemplate), for: .normal)
            sender.addTarget(self, action: #selector(subscribedParse), for: .touchUpInside)
        }
    }
    
    func setthumbUp(_ sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = Color.BlueColor
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "objectId") as? String!)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("Liked")
                object!.saveInBackground()
            }
        }
    }
    
    func setthumbDown(_ sender: UIButton) {
        
        sender.isSelected = true
        sender.tintColor = Color.BlueColor
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView!.indexPathForRow(at: hitPoint)
        
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as AnyObject).value(forKey: "objectId") as? String!)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("Dislikes")
                object!.saveInBackground()
            }
        }
    }
    
    func shareButton(_ sender: UIButton) {
        
        let image: UIImage = (self.selectedImage ?? nil)!

        let activityViewController = UIActivityViewController (activityItems: [(image), self.titleLookup!], applicationActivities: nil)
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = sender
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        }
        self.present(activityViewController, animated: true)
    }

    
    @IBAction func minimize(_ sender: UIButton) {
        self.state = .minimized
        self.delegate?.didMinimize()
        self.animate()
    }
    
    @IBAction func minimizeGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let velocity = sender.velocity(in: nil)
            if abs(velocity.x) < abs(velocity.y) {
                self.direction = .up
            } else {
                self.direction = .left
            }
        }
        var finalState = stateOfVC.fullScreen
        switch self.state {
        case .fullScreen:
            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
            self.changeValues(scaleFactor: factor)
            self.delegate?.swipeToMinimize(translation: factor, toState: .minimized)
            finalState = .minimized
        case .minimized:
            if self.direction == .left {
                finalState = .hidden
                let factor: CGFloat = sender.translation(in: nil).x
                self.delegate?.swipeToMinimize(translation: factor, toState: .hidden)
            } else {
                finalState = .fullScreen
                let factor = 1 - (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.changeValues(scaleFactor: factor)
                self.delegate?.swipeToMinimize(translation: factor, toState: .fullScreen)
            }
        default: break
        }
        if sender.state == .ended {
            self.state = finalState
            self.animate()
            self.delegate?.didEndedSwipe(toState: self.state)
            if self.state == .hidden {
                self.player.pause()
            }
        }
    }
    
    func changeValues(scaleFactor: CGFloat) {
        self.minimizeButton.alpha = 1 - scaleFactor
        self.containView.alpha = 1 - scaleFactor
        self.tableView.alpha = 1 - scaleFactor
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let transform = scale.concatenating(CGAffineTransform.init(translationX: -(self.playerView.bounds.width / 4 * scaleFactor), y: -(self.playerView.bounds.height / 4 * scaleFactor)))
        self.playerView.transform = transform
    }
    
    func tapPlayView()  {
        showControlObjects()
        self.player.play()
        self.state = .fullScreen
        self.delegate?.didmaximize()
        self.animate()
    }
    
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        if let count = _feedItems.count {
            return count + 1
        } else {
            return _feedItems.count
        } */
        
        return _feedItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header") as! headerCell
            
            cell.title.text = self.titleLookup ?? "Big Buck Bunny"
            cell.viewCount.text = self.viewLookup ?? "0 views"
            cell.likes.text = self.likesLookup ?? "0"
            cell.disLikes.text = self.dislikesLookup ?? "0"
            
            cell.shareView.tintColor = .lightGray
            cell.shareView.setImage(#imageLiteral(resourceName: "share"), for: .normal)
            cell.shareView .addTarget(self, action: #selector(shareButton), for: .touchUpInside)
            
            cell.thumbUp.tintColor = .lightGray
            cell.thumbUp.setImage(#imageLiteral(resourceName: "thumbUp"), for: .normal)
            cell.thumbUp .addTarget(self, action: #selector(setthumbUp), for: .touchUpInside)
            
            cell.thumbDown.tintColor = .lightGray
            cell.thumbDown.setImage(#imageLiteral(resourceName: "thumbDown"), for: .normal)
            cell.thumbDown .addTarget(self, action: #selector(setthumbDown), for: .touchUpInside)
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo: self.imageLookup ?? (PFUser.current()?.username)!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
                            
                            UIView.transition(with: (cell.channelPic)!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                self.selectedChannelPic = UIImage(data: imageData! as Data)
                            }, completion: nil)
                        }
                    }
                }
            }
            cell.channelPic.layer.cornerRadius = 20
            cell.channelPic.clipsToBounds = true
            cell.channelPic.image = self.selectedChannelPic
            
            cell.channelTitle.text = self.imageLookup ?? (PFUser.current()?.username)!
            cell.channelSubscribers.text = "235235 subscribers"
            
            cell.subscribed.tintColor = Color.youtubeRed
            cell.subscribed.setImage(#imageLiteral(resourceName: "iosStar").withRenderingMode(.alwaysTemplate), for: .normal)
            cell.subscribed.setTitle(" SUBSCRIBE", for: .normal)
            cell.subscribed.setTitleColor(Color.youtubeRed, for: .normal)
            cell.subscribed.addTarget(self, action: #selector(setSubscribed), for: .touchUpInside)
            
            cell.selectionStyle = .none
            returnCell = cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! videoCell
            // fix added - 1 to (indexPath).row - 1
            cell.title.text = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsTitle") as? String
            cell.title.numberOfLines = 2
            
            var newsView:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsView")as? Int
            if newsView == nil { newsView = 0 }
            
            let NewText = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsDetail") as? String
            cell.name.text =  String(format: "%@%@", "\(NewText!)", " \(newsView!) views")

            imageObject = _feedItems.object(at: ((indexPath as NSIndexPath).row) - 1) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
                UIView.transition(with: cell.tumbnail, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.tumbnail.image = UIImage(data: imageData!)
                }, completion: nil)
            }
            self.selectedImage = cell.tumbnail.image
            cell.tumbnail.backgroundColor = .black
            returnCell = cell
        }
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        switch indexPath.row {
        case 0:
            height = 180
        default:
            height = 90
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // fix added - 1 to (indexPath).row - 1
        self.titleLookup = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsTitle") as? String
        
        var newsView:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "newsView")as? Int
        if newsView == nil { newsView = 0 }
        self.viewLookup = "\(newsView!) views"
        
        var Liked:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "Liked")as? Int
        if Liked == nil { Liked = 0 }
        self.likesLookup = "\(Liked!)"
        
        var Disliked:Int? = (_feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "Dislikes")as? Int
        if Disliked == nil { Disliked = 0 }
        self.dislikesLookup = "\(Disliked!)"

        self.imageLookup = (self._feedItems[(indexPath).row - 1] as AnyObject).value(forKey: "username") as? String
        
        //update View Count
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo:((_feedItems.object(at: ((indexPath as NSIndexPath?)?.row)! - 1) as AnyObject).value(forKey: "objectId") as? String!)!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("newsView")
                object!.saveInBackground()
            }
        }
        
        imageObject = _feedItems.object(at: indexPath.row - 1) as! PFObject
        imageFile = imageObject.object(forKey: "imageFile") as? PFFile
        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
            let imageDetailurl = self.imageFile.url
            let result1 = imageDetailurl!.contains("movie.mp4")
            if (result1 == true) {
                self.playVideo(videoURL: self.imageFile.url!)
            }
        }
        scrollToFirstRow()
    }
    
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    //MARK: - Fetch Data
    
    func fetchVideos() {
        
        let query = PFQuery(className:"Newsios")
      //query.whereKey("imageFile", equalTo:"movie.mp4")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
}
/*
extension PlayVC: UrlLookupDelegate {
    func urlController(passedData: String) {
        self.videoURL = passedData
    }
    func titleController(passedData: String) {
        self.titleLookup = passedData
    }
    func likesController(passedData: String) {
        //self.likeLookuo = passedData as String
    }
    /*
    func playVideo(videoURL: String) {
        self.playVideo(videoURL)
    } */
} */


class headerCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var disLikes: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelPic: UIImageView!
    @IBOutlet weak var channelSubscribers: UILabel!
    @IBOutlet weak var subscribed: UIButton! //added
    @IBOutlet weak var thumbUp: UIButton! //added
    @IBOutlet weak var thumbDown: UIButton! //added
    @IBOutlet weak var shareView: UIButton! //added
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class videoCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var tumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var name: UILabel!
    
    //MARK: Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


