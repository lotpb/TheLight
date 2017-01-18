//
//  UploadController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices //kUTTypeImage
import AVKit
import AVFoundation
import UserNotifications

class UploadController: UIViewController, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UITextViewDelegate {
    
    
    let addText = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imgToUpload: UIImageView!
    @IBOutlet weak var commentTitle: UITextField!
    @IBOutlet weak var commentSorce: UITextField!
    @IBOutlet weak var commentDetail: UITextView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var selectPic: UIButton!
    
    var playerViewController = AVPlayerViewController()
    var imagePicker = UIImagePickerController()
    var pickImage = false
    var editImage = false
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 150, height: 150)) as UIActivityIndicatorView
    
    var formStat : String?
    var objectId : String?
    var newstitle : String?
    var newsdetail : String?
    var newsStory : String?
    var imageDetailurl : String?
    var newsImage : UIImage!
    
    var file : PFFile!
    var pictureData : Data!
    var videoURL : URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("Upload", for: .normal)
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: .normal)
        self.navigationItem.titleView = titleButton
        
        self.mainView.backgroundColor = Color.LGrayColor
        self.progressView.isHidden = true
        self.progressView.setProgress(0, animated: true)
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(shootPhoto))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(uploadImage))
        navigationItem.rightBarButtonItems = [saveButton, cameraButton]
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            self.commentTitle!.font = Font.celllabel1
            self.commentDetail!.font = Font.celllabel1
            self.commentSorce.font = Font.celllabel1
            
        } else {
            self.commentTitle!.font = Font.cellsubtitle
            self.commentDetail!.font = Font.cellsubtitle
            self.commentSorce.font = Font.cellsubtitle
            
        }
        
        if (self.formStat == "Update") {
            // FIXME:
            if (newsImage != nil) {
                pickImage = true
            } else {
                pickImage = false
            }
            
            self.commentTitle.text = self.newstitle
            self.commentDetail.text = self.newsStory
            self.commentSorce.text = self.newsdetail
            self.imgToUpload.image = self.newsImage
        } else {
            self.commentDetail.text = addText
        }
        
        self.imgToUpload.isUserInteractionEnabled = true
        
        self.clearButton.setTitle("Clear", for: .normal)
        self.clearButton .addTarget(self, action: #selector(clearBtn), for: UIControlEvents.touchUpInside)
        self.clearButton.tintColor = Color.DGrayColor
        self.clearButton.layer.cornerRadius = 12.0
        self.clearButton.layer.borderColor = Color.DGrayColor.cgColor
        self.clearButton.layer.borderWidth = 2.0
        
        self.selectPic.tintColor = Color.DGrayColor
        self.selectPic.layer.cornerRadius = 12.0
        self.selectPic.layer.borderColor = Color.DGrayColor.cgColor
        self.selectPic.layer.borderWidth = 2.0
        
        self.commentDetail.delegate = self
        self.commentDetail.autocorrectionType = UITextAutocorrectionType.yes
        self.commentDetail.dataDetectorTypes = UIDataDetectorTypes.all
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            setupConstraints()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.commentDetail.isScrollEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerViewController)
        self.commentDetail.isScrollEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setupConstraints() {
        
        commentTitle.translatesAutoresizingMaskIntoConstraints = false
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            commentTitle.widthAnchor.constraint(equalToConstant: 450).isActive = true
        } else {
           commentTitle.widthAnchor.constraint(equalToConstant: 338).isActive = true
        }
    }
    
    // MARK: - Button
    
    func clearBtn() {
        
        if (self.clearButton.titleLabel!.text == "Clear")   {
            self.commentDetail.text = ""
            self.clearButton.setTitle("add text", for: .normal)
        } else {
            self.commentDetail.text = addText
            self.clearButton.setTitle("Clear", for: .normal)
        }
    }
    
    // MARK: - Button
    
    // MARK: Camera
    
    func shootPhoto(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            imagePicker.delegate = self
            //imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
            self.present(imagePicker, animated: true, completion: nil)
        } else{
            self.simpleAlert(title: "Alert!", message: "Camera not available")
        }
    }
    
    @IBAction func selectImage(_ sender: AnyObject) {
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.delegate = self
        //imagePicker.videoQuality = UIImagePickerControllerQualityType.typeHigh
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.editImage = true
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeMovie as String) {
            
            pickImage = false
            videoURL = info[UIImagePickerControllerMediaURL] as? URL
            let player = AVPlayer(url: videoURL!)
            playerViewController.player = player
   
            playerViewController.view.frame = self.imgToUpload.bounds
            playerViewController.videoGravity = AVLayerVideoGravityResizeAspect
            playerViewController.showsPlaybackControls = true
            imgToUpload.addSubview(playerViewController.view)
            player.play()
            
        } else if mediaType.isEqual(to: kUTTypeImage as String) {
            
            pickImage = true
            let image = info[UIImagePickerControllerEditedImage] as? UIImage
            imgToUpload.contentMode = .scaleAspectFill
            imgToUpload.clipsToBounds = true
            imgToUpload.image = image
            
        } 
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - video playback
    
    func finishedPlaying(_ myNotification:Notification) {
        
        let stoppedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stoppedPlayerItem.seek(to: kCMTimeZero)
    }
    
    // MARK: - News Notification
    
    func newsNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Breaking News"
        content.body = "News Posted by \(PFUser.current()!.username!) at TheLight"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "status"
        
        let imageURL = Bundle.main.url(forResource: "news", withExtension: "png")
        let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
        content.attachments = [attachment]
        content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "news-id-123", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }

    
    // MARK: - Update Data
    
    func uploadImage(_ sender: AnyObject) {
        
        guard let text = self.commentTitle.text else { return }
        
        if text == "" {
            
            self.simpleAlert(title: "Oops!", message: "No text entered.")
            
        } else {
            
            self.navigationItem.rightBarButtonItem!.isEnabled = false
            self.progressView.isHidden = false
            
            activityIndicator.center = self.imgToUpload!.center
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            
            if (pickImage == true) { //image
                pictureData = UIImageJPEGRepresentation(self.imgToUpload!.image!, 1.0)
                file = PFFile(name: "img", data: pictureData!)
            } else { //video
                
                pictureData =  try? Data(contentsOf: videoURL!)
                file = PFFile(name: "movie.mp4", data: pictureData!)
            }
            
            if (self.formStat == "Update") {
                
                let query = PFQuery(className:"Newsios")
                query.whereKey("objectId", equalTo:self.objectId!)
                query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        updateblog!.setObject(self.commentTitle.text!, forKey:"newsTitle")
                        updateblog!.setObject(self.commentSorce.text!, forKey:"newsDetail")
                        updateblog!.setObject(self.commentDetail.text!, forKey:"storyText")
                        updateblog!.setObject(PFUser.current()!.username!, forKey:"username")
                        updateblog!.saveEventually()
                        
                        if self.editImage == true {
                            
                            self.file!.saveInBackground { (success: Bool, error: Error?) -> Void in
                                if success {
                                    updateblog!.setObject(self.file!, forKey:"imageFile")
                                    updateblog!.saveInBackground { (success: Bool, error: Error?) -> Void in
                                        
                                        self.simpleAlert(title: "Image Upload Complete", message: "Successfully updated the image")
                                        
                                        let newVC = News()
                                        self.navigationController?.pushViewController(newVC, animated: true)
                                        /*
                                         DispatchQueue.main.async {
                                         let vc = self.storyboard?.instantiateViewController(withIdentifier: "newsId")
                                         self.show(vc!, sender: self)
                                         } */
                                    }
                                }
                            }
                            
                        } else {
                            
                            self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        }
                        self.navigationItem.rightBarButtonItem!.isEnabled = true
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        
                    }
                }
                
            } else {
                
                file!.saveInBackground { (success: Bool, error: Error?) -> Void in
                    if success {
                        let updateuser:PFObject = PFObject(className:"Newsios")
                        updateuser.setObject(self.file!, forKey:"imageFile")
                        updateuser.setObject(self.commentTitle.text!, forKey:"newsTitle")
                        updateuser.setObject(self.commentSorce.text!, forKey:"newsDetail")
                        updateuser.setObject(self.commentDetail.text!, forKey:"storyText")
                        updateuser.setObject(PFUser.current()!.username!, forKey:"username")
                        updateuser.saveInBackground { (success: Bool, error: Error?) -> Void in
                            
                            if success {
                                
                                self.simpleAlert(title: "Upload Complete", message: "Successfully saved the data")
                                self.newsNotification()
                            } else {
                                
                                print("Error: \(error) \(error!._userInfo)")
                            }
                        }
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updated the data")
                        
                    }
                }
            }
            //self.navigationController?.popToRootViewController(animated: true)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }


}
