//
//  NewsDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse


class NewsDetailController: UIViewController, UITextViewDelegate,  UISplitViewControllerDelegate {
    
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
    var newsDate: Date?
    var videoURL: String?
    
    var SnapshotBool = false //hide leftBarButtonItems
    
    //var newsViewHeight: CGFloat!
    
    let faceLabel: UILabel = {
        let label = UILabel()
        label.text = "---"
        label.font = Font.celltitle14r
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        button.setTitle("News Detail", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editData))
        let backItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setbackButton))
        navigationItem.rightBarButtonItems = [editItem]
        if SnapshotBool == false {
            navigationItem.leftBarButtonItems = [backItem]
        } else {
            navigationItem.leftBarButtonItems = nil
        }
        
        let query = PFQuery(className:"Newsios")
        query.whereKey("objectId", equalTo: self.objectId!)
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            if error == nil {
                object!.incrementKey("newsView")
                object!.saveInBackground()
            }
        }

        setupConstraints()
        setupForm()
        setupImageView()
        setupFonts()
        setupTextView()
        findFace()
        
        self.navigationItem.titleView = self.titleButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        //fix TextView Scroll first line
        self.newsTextview.isScrollEnabled = false
        setupNewsNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //fix TextView Scroll first line
        self.newsTextview.isScrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.newsImageview
    }
    
    func setupImageView() {
        
        //self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        UIView.transition(with: self.newsImageview, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.newsImageview.image = self.image
        }, completion: nil)
        
        self.newsImageview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.newsImageview.contentMode = .scaleAspectFill //.scaleAspectFill //.scaleAspectFit
        self.newsImageview.clipsToBounds = true
        
        self.newsImageview.backgroundColor = .black
        self.newsImageview.isUserInteractionEnabled = true
        
    }
    
    func setupForm() {
        
        self.titleLabel.text = self.newsTitle
        self.titleLabel.numberOfLines = 2
        
        let date1 = self.newsDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date1! as Date)
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MMM dd, yyyy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEEE"
        }
        
        let dateString = dateFormatter.string(from: date1!)
        self.detailLabel.text = String(format: "%@ %@ %@", (self.newsDetail!), "Uploaded", "\(dateString)")
        self.detailLabel.textColor = .gray
        self.detailLabel.sizeToFit()
    }
    
    func setupFonts() {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.titleLabel.font = Font.celltitle36r
            self.detailLabel.font = Font.celltitle20r
            self.newsTextview.isEditable = true //bug fix
            self.newsTextview.font = Font.celltitle26l
        } else {
            self.titleLabel.font = Font.News.newstitle
            self.detailLabel.font = Font.celltitle16r
            self.newsTextview.isEditable = true//bug fix
            self.newsTextview.font = Font.News.newssource
        }
    }
    
    func setupTextView() {
        
        self.newsTextview.text = self.newsStory
        self.newsTextview.delegate = self
        self.newsTextview.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        // Make web links clickable
        self.newsTextview.isSelectable = true
        self.newsTextview.isEditable = false
        self.newsTextview.dataDetectorTypes = .link
    }
    
    func setupConstraints() {
        
        let height = (view.frame.width * 9 / 16)
        
        newsImageview.addSubview(faceLabel)
  
        newsImageview.translatesAutoresizingMaskIntoConstraints = false
        newsImageview.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        faceLabel.topAnchor.constraint( equalTo: newsImageview.topAnchor, constant: +5).isActive = true
        faceLabel.leadingAnchor.constraint( equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        faceLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    // MARK: - Button
    
    func setbackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func editData(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "uploadSegue", sender: self)
    }
    
    // MARK: - FaceDetector
    
    func findFace() {
        
        guard let faceImage = CIImage(image: self.newsImageview.image!) else { return }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: faceImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true])
        
        for face in faces as! [CIFaceFeature] {
            
            if face.hasSmile {
                print("😁")
            }
            
            if face.leftEyeClosed {
                print("Left: 😉")
            }
            
            if face.rightEyeClosed {
                print("Right: 😉")
            }
        }
        
        if faces!.count != 0 {
            self.faceLabel.text = "Faces: \(faces!.count)"
        } else {
            self.faceLabel.text = "No Faces 😢"
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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

