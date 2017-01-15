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
import AVKit
import AVFoundation
import Parse

class PlayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    
    //MARK: Properties
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containView: UIView!
    
    var _feedItems : NSMutableArray = NSMutableArray()
    var imageObject :PFObject!
    var imageFile :PFFile!
    var selectedImage : UIImage?
    
    var delegate: PlayerVCDelegate?
    var state = stateOfVC.hidden
    var direction = Direction.none
    var videoPlayer = AVPlayer.init()
    
    var videoURL: String?
    var titleLookup: String?
    
    var isPlaying = true
    
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
        let image = UIImage(named: "minimize")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = false
        button.addTarget(self, action: #selector(minimize), for: .touchUpInside)
        return button
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
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
            //return
        }
        self.playVideo(videoURL: videoURL!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Video Player
    
    private func playVideo(videoURL: String) {
        //self.videoPlayer.pause()
        //NotificationCenter.default.removeObserver(self)
        
        if let url = NSURL(string: videoURL) {
            DispatchQueue.main.async(execute: {
                self.videoPlayer = AVPlayer(url: url as URL)
                let playerLayer = AVPlayerLayer(player: self.videoPlayer)
                playerLayer.frame = self.playerView.bounds
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.playerView.layer.addSublayer(playerLayer)
                if self.state != .hidden {
                    self.videoPlayer.play()
                }
                //self.loopVideo(videoPlayer: self.videoPlayer)
                self.playDidEnd(videoPlayer: self.videoPlayer)
                self.setupGradientLayer()
                self.setupTimeRanges()//must keep below videoPlayer.play()
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Video Full Screen
    //not working below
    func fullScreen(videoPlayer: AVPlayer) {
        let path = Bundle.main.path(forResource: "video", ofType: "mp4")!
        let url = URL(fileURLWithPath: path)
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let fullScreenPlayer = AVPlayer(playerItem: playerItem)
        fullScreenPlayer.play()
        
        let fullScreenPlayerViewController = AVPlayerViewController()
        fullScreenPlayerViewController.player = fullScreenPlayer
        present(fullScreenPlayerViewController, animated: true, completion: nil)
    }
    
    // MARK: - Setup View
    
    func setupConstraints() {
        /*
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
         
        } */
        
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
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -2).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        containView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 8).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -2).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
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
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containView.bounds //CGRect(x: 64, y: 64, width: 160, height: 160)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        playerView.layer.addSublayer(gradientLayer)
    }
    
    func handlePause() {
        if isPlaying {
            videoPlayer.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            videoPlayer.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    func handleSliderChange() {
        
        print(videoSlider.value)
        if let duration = videoPlayer.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            videoPlayer.seek(to: seekTime, completionHandler: { (completedSeek) in
                //self.videoPlayer.play()
                //perhaps do something later here
            })
        }
    }

    private func setupTimeRanges() {
        
        self.videoPlayer.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        //track player progress
        let interval = CMTime(value: 1, timescale: 2)
        self.videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            //lets move the slider thumb
            if let duration = self.videoPlayer.currentItem?.duration {
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
            
            if let duration = videoPlayer.currentItem?.duration {
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
            //self.containView.alpha = 1
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
            //self.containView.alpha = 0
        }, completion: {
            Bool in
            //self.panelVisible = false
        })
    }
    
    // return to start Video
    func playDidEnd(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in

            self.videoPlayer.seek(to: kCMTimeZero, completionHandler: {
                Bool in
                self.videoSlider.setValue(0.0, animated: true)
                self.showControlObjects()
            })
        }
    }
    // repeat Video
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            
            videoPlayer.seek(to: kCMTimeZero)
            videoPlayer.play()
        }
    }
    
    // MARK: - Button
    
    func likeSetButton(sender:UIButton) {
        /*
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
         } */
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
                self.videoPlayer.pause()
            }
        }
    }
    
    func changeValues(scaleFactor: CGFloat) {
        self.minimizeButton.alpha = 1 - scaleFactor
        self.containView.alpha = 1 - scaleFactor
        self.tableView.alpha = 1 - scaleFactor
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let trasform = scale.concatenating(CGAffineTransform.init(translationX: -(self.playerView.bounds.width / 4 * scaleFactor), y: -(self.playerView.bounds.height / 4 * scaleFactor)))
        self.playerView.transform = trasform
    }
    
    func tapPlayView()  {
        showControlObjects()
        self.videoPlayer.play()
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
            return 0
        } */
        
        return _feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header") as! headerCell
            cell.title.text = "Title" //self.titleLookup
            cell.viewCount.text = "2234534 views"
            
            var Liked:Int? = (_feedItems[(indexPath).row] as AnyObject).value(forKey: "Liked")as? Int
            if Liked == nil {
                Liked = 0
            }
            cell.likes.text = "\(Liked!)"
            
            var Disliked:Int? = (_feedItems[(indexPath).row] as AnyObject).value(forKey: "Dislikes")as? Int
            if Disliked == nil {
                Disliked = 0
            }
            cell.disLikes.text = "\(Disliked!)"
            
            cell.channelTitle.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "username") as? String
            
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:"Peter Balsamo")
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                        imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                            
                            UIView.transition(with: (cell.channelPic)!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                cell.channelPic.image = UIImage(data: imageData! as Data)
                            }, completion: nil)
                        }
                    }
                }
            }

            cell.channelPic.layer.cornerRadius = 25
            cell.channelPic.clipsToBounds = true
            cell.channelSubscribers.text = "235235 subscribers"
            cell.selectionStyle = .none
            returnCell = cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! videoCell
            cell.name.numberOfLines = 2
            cell.name.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsDetail") as? String
            cell.title.text = (self._feedItems[(indexPath).row] as AnyObject).value(forKey: "newsTitle") as? String
            imageObject = _feedItems.object(at: ((indexPath as NSIndexPath?)?.row)!) as! PFObject
            imageFile = imageObject.object(forKey: "imageFile") as? PFFile
            imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                UIView.transition(with: cell.tumbnail, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    cell.tumbnail.image = UIImage(data: imageData!)
                }, completion: nil)
            }
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
        //FloatingView.sharedInstance.videoView.playUrl(url: URL.init(string: _feedItems[indexPath.row])!)
    }
    
    //MARK: - Fetch Data
    
    func fetchVideos() {
        
        let query = PFQuery(className:"Newsios")
        //query.whereKey("imageFile", equalTo:"movie.mp4")
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
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
}


class headerCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var disLikes: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelPic: UIImageView!
    @IBOutlet weak var channelSubscribers: UILabel!
    
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


