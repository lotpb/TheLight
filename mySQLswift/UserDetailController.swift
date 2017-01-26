//
//  UserDetailController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/18/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation
import MobileCoreServices //kUTTypeImage
import MessageUI

class UserDetailController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userimageView: UIImageView?
    
    @IBOutlet weak var usernameField : UITextField?
    @IBOutlet weak var emailField : UITextField?
    @IBOutlet weak var phoneField : UITextField?
    
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel?
    
    @IBOutlet weak var updateBtn: UIButton?
    @IBOutlet weak var callBtn: UIButton?
    @IBOutlet weak var emailBtn: UIButton?

    var status : String?
    var objectId : String?
    var username : String?
    var create : String?
    var email : String?
    var phone : String?
    
    var user : PFUser?
    var userquery : PFObject?
    var userimage : UIImage?
    var pickImage : UIImage?
    var pictureData : Data?
    
    var imagePicker: UIImagePickerController!
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
 
    var emailTitle :NSString?
    var messageBody:NSString?
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            button.setTitle("TheLight - User Profile", for: .normal)
        } else {
            button.setTitle("Profile", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let cameraBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectCamera))
        let videoBtn = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(selectVideo))
        navigationItem.rightBarButtonItems = [cameraBtn, videoBtn]
        
        emailTitle = defaults.string(forKey: "emailtitleKey")! as NSString
        messageBody = defaults.string(forKey: "emailmessageKey")! as NSString
        
        self.emailField!.keyboardType = .emailAddress
        self.phoneField!.keyboardType = .numbersAndPunctuation
        
        if status == "Edit" {
            setupData()
        }
        setupForm()
        setupBorder()
        setupFonts()
        setupConstraints()
        self.navigationItem.titleView = self.titleButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBorder() {
        let bottomBorder = CALayer()
        let width1 = CGFloat(2.0)
        bottomBorder.borderColor = UIColor.darkGray.cgColor
        bottomBorder.frame = CGRect(x: 0, y: self.mainView!.frame.size.height-1, width: view.frame.size.width, height: 0.5)
        bottomBorder.borderWidth = width1
        self.mainView!.layer.masksToBounds = true
        self.mainView!.layer.addSublayer(bottomBorder)
    }
    
    func setupForm() {
        self.view.backgroundColor = .white //Color.LGrayColor
        self.mainView!.backgroundColor = UIColor(white:0.99, alpha:1.0)
        
        if status == "Edit" {
            self.usernameField?.text = self.username
            self.emailField?.text = self.email
            self.phoneField?.text = self.phone
            self.createLabel!.text = self.create
            self.userimageView?.image = self.userimage
        } else {
            self.userimageView?.image = UIImage(named:"profile-rabbit-toy")
        }
        
        self.userimageView?.backgroundColor = .white
        self.userimageView!.isUserInteractionEnabled = true
        self.userimageView!.layer.masksToBounds = true
        self.userimageView!.layer.cornerRadius = 60.0
        
        mapView.delegate = self
        mapView!.layer.borderColor = UIColor.lightGray.cgColor
        mapView!.layer.borderWidth = 1.0
        
        callBtn!.layer.cornerRadius = 24.0
        callBtn!.layer.borderColor = Color.BlueColor.cgColor
        callBtn!.layer.borderWidth = 3.0
        callBtn!.setTitleColor(Color.BlueColor, for: .normal)
        
        updateBtn!.layer.cornerRadius = 24.0
        updateBtn!.layer.borderColor = Color.BlueColor.cgColor
        updateBtn!.layer.borderWidth = 3.0
        updateBtn!.setTitleColor(Color.BlueColor, for: .normal)
        
        emailBtn!.layer.cornerRadius = 24.0
        emailBtn!.layer.borderColor = Color.BlueColor.cgColor
        emailBtn!.layer.borderWidth = 3.0
        emailBtn!.setTitleColor(Color.BlueColor, for: .normal)
    }
    
    func setupData() {
        let query = PFUser.query()
        do {
            userquery = try query!.getObjectWithId(self.objectId!)
            let location = userquery!.value(forKey: "currentLocation") as! PFGeoPoint
            
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let span = MKCoordinateSpanMake(0.02, 0.02)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView!.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.title = userquery!.object(forKey: "username") as? String
            annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            self.mapView!.addAnnotation(annotation)
            self.mapView!.showsUserLocation = true
        } catch {
            print("")
        }
    }
    
    func setupFonts() {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.usernameField!.font = Font.celltitle20l
            self.emailField!.font = Font.celltitle20l
            self.phoneField!.font = Font.celltitle20l
            self.createLabel!.font = Font.celltitle16l
            self.mapLabel!.font = Font.celltitle20l
        } else {
            self.usernameField!.font = Font.celltitle18l
            self.emailField!.font = Font.celltitle18l
            self.phoneField!.font = Font.celltitle18l
            self.createLabel!.font = Font.celltitle14l
            self.mapLabel!.font = Font.celltitle20l
        }
    }
    
    func setupConstraints() {
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
        containView.translatesAutoresizingMaskIntoConstraints = false
        containView.heightAnchor.constraint(equalToConstant: 800).isActive = true
        }
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: (mapLabel?.bottomAnchor)!, constant: +25).isActive = true
        mapView.leadingAnchor.constraint( equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint( equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint( equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    // MARK: - Button
    
    func selectVideo() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.showsCameraControls = true
            //imagePicker.videoMaximumDuration = 10.0
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    
    func selectCamera() {
        
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: false, completion: nil)
    }
    
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.userimageView!.image = pickedImage
            dismiss(animated: true, completion: { () -> Void in
            })
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Call Phone
    
    @IBAction func callPhone(_ sender: AnyObject) {
        
        let phoneNo : String?
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            
            phoneNo = self.phoneField!.text
            if let phoneCallURL:URL = URL(string:"telprompt:\(phoneNo!)") {
                
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    
                    UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                    //application.openURL(phoneCallURL)
                }
            } else {
                
                self.simpleAlert(title: "Alert", message: "Call facility is not available!!!")
            }
        } else {
            
            self.simpleAlert(title: "Alert", message: "Your device doesn't support this feature.")
        }
    }
    
    
    // MARK: - Send Email
    
    @IBAction func sendEmail(_ sender: AnyObject) {
        
        if (self.emailField != NSNull()) {
            
            self.getEmail((emailField?.text)! as NSString)
            
        } else {
            
            self.simpleAlert(title: "Alert", message: "Your field doesn't have valid email.")
        }
    }
    
    
    func getEmail(_ emailfield: NSString) {
        
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setToRecipients([emailfield as String])
        email.setSubject((emailTitle as? String)!)
        email.setMessageBody((messageBody as? String)!, isHTML:true)
        email.modalTransitionStyle = .flipHorizontal
        self.present(email, animated: true, completion: nil)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func Update(_ sender: AnyObject) {
        
        self.user = PFUser.current()
        if self.usernameField!.text! == self.user?.username {
            
            self.activityIndicator.center = self.userimageView!.center
            self.activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            
            pictureData = UIImageJPEGRepresentation(self.userimageView!.image!, 1.0)
            let file = PFFile(name: "img", data: pictureData!)
            
            file!.saveInBackground { (success: Bool, error: Error?) -> Void in
                if success {
                    self.user!.setObject(self.usernameField!.text!, forKey:"username")
                    self.user!.setObject(self.emailField!.text!, forKey:"email")
                    self.user!.setObject(self.phoneField!.text!, forKey:"phone")
                    self.user!.setObject(file!, forKey:"imageFile")
                    self.user!.saveInBackground { (success: Bool, error: Error?) -> Void in
                    }
                    self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                } else {
                    self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                }
            }
            //self.navigationController?.popToRootViewControllerAnimated(true)
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        } else {
            self.simpleAlert(title: "Alert", message: "User is not valid to edit data")
        }
    }
    
}
