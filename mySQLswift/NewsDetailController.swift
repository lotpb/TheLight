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
    var newsDate: Date?
    var videoURL: String?
    
    var newsViewHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            newsViewHeight = 450
        } else {
            newsViewHeight = 258
        }
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("News Detail", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.newsImageview.backgroundColor = .black
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editData))

        navigationItem.rightBarButtonItems = [editItem]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setbackButton))
        
        self.newsImageview.isUserInteractionEnabled = true
        

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.newsImageview.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
            self.newsImageview.contentMode = .scaleAspectFill //.scaleAspectFit
            self.newsImageview.clipsToBounds = true
            
            self.titleLabel.font = ipadtitle
            self.detailLabel.font = ipadsubtitle
            self.newsTextview.isEditable = true //bug fix
            self.newsTextview.font = ipadtextview
        } else {
            self.newsImageview.contentMode = .scaleToFill //.scaleAspectFill //.scaleAspectFit
    
            self.titleLabel.font = Font.News.newstitle
            self.detailLabel.font = Font.cellsubtitle
            self.newsTextview.isEditable = true//bug fix
            self.newsTextview.font = Font.News.newssource
        }
        UIView.transition(with: self.newsImageview, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.newsImageview.image = self.image
        }, completion: nil)
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
        
        self.newsTextview.text = self.newsStory
        self.newsTextview.delegate = self
        self.newsTextview.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        // Make web links clickable
        self.newsTextview.isSelectable = true
        self.newsTextview.isEditable = false
        self.newsTextview.dataDetectorTypes = UIDataDetectorTypes.link
        
        self.findFace()
        setupConstraints()
        
    }
    
    //fix TextView Scroll first line
    override func viewWillAppear(_ animated: Bool) {
        
        self.newsTextview.isScrollEnabled = false
        self.navigationController?.navigationBar.tintColor = .white
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.News.navColor
        }
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
    
    func setupConstraints() {
        //height newsImageview
        let heightRouteConstraints = NSLayoutConstraint(item: newsImageview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: newsViewHeight)
        view.addConstraints([heightRouteConstraints])
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
            print("Number of Faces: \(faces!.count)")
        } else {
            print("No Faces 😢")
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
