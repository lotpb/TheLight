//
//  LoginController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/13/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import MapKit
import LocalAuthentication
import FBSDKLoginKit
import GoogleSignIn
import SwiftKeychainWrapper
import Firebase

// A delay function
func delay(_ seconds: Double, completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(seconds * 1000.0))) {
        completion()
    }
}


class LoginController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate,  GIDSignInUIDelegate, GIDSignInDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
    let celltitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var registerBtn: UIButton?
    @IBOutlet weak var loginBtn: UIButton?
    @IBOutlet weak var backloginBtn: UIButton?
    @IBOutlet weak var forgotPassword: UIButton?
    @IBOutlet weak var authentButton: UIButton!
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    @IBOutlet weak var reEnterPasswordField: UITextField?
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var phoneField: UITextField?
    
    var defaults = UserDefaults.standard
    var pictureData : Data?
    var userimage : UIImage?
    var user : PFUser?
    
    //Facebook
    var fbButton : FBSDKLoginButton = FBSDKLoginButton()
    
    //Google
    var signInButton : GIDSignInButton = GIDSignInButton()
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    //var firebase: FIRDatabaseReference?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        self.firebase = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            self.firebase!.child("users/\(user.uid)/userID").setValue(user.uid)
        } else {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.firebase!.child("users").child(user!.uid).setValue(["userID": user!.uid])
                }
            })
        } */
        
        observeKeyboardNotifications() //Move Keyboard
        
        if ((defaults.string(forKey: "registerKey") == nil)) {
            
            self.registerBtn!.setTitle("Register", for: UIControlState())
            self.loginBtn!.isHidden = true //hide login button no user is regsitered
            self.forgotPassword!.isHidden = true
            self.authentButton!.isHidden = true
            self.fbButton.isHidden = true
            self.signInButton.isHidden = true
            self.emailField!.isHidden = false
            self.phoneField!.isHidden = false
            
        } else {
            //Keychain
            self.usernameField!.text = KeychainWrapper.standard.string(forKey: "usernameKey")
            self.passwordField!.text = KeychainWrapper.standard.string(forKey: "passwordKey")
            self.reEnterPasswordField!.isHidden = true
            self.registerBtn!.isHidden = false
            self.forgotPassword!.isHidden = false
            self.fbButton.isHidden = false
            self.signInButton.isHidden = false
            self.emailField!.isHidden = true
            self.phoneField!.isHidden = true
            self.backloginBtn!.isHidden = true
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.usernameField!.font = ipadtitle
            self.passwordField!.font = ipadtitle
            self.reEnterPasswordField!.font = ipadtitle
            self.emailField!.font = ipadtitle
            self.phoneField!.font = ipadtitle
        } else {
            self.usernameField!.font = celltitle
            self.passwordField!.font = celltitle
            self.reEnterPasswordField!.font = celltitle
            self.emailField!.font = celltitle
            self.phoneField!.font = celltitle
        }
        
        self.registerBtn!.setTitleColor(.white, for: UIControlState())
        self.loginBtn!.setTitleColor(.white, for: UIControlState())
        self.backloginBtn!.setTitleColor(.white, for: UIControlState())
        self.emailField!.keyboardType = .emailAddress
        self.phoneField!.keyboardType = .numbersAndPunctuation
        
        self.passwordField!.text = ""
        self.userimage = nil
        
        //Facebook

        fbButton.delegate = self
        if (FBSDKAccessToken.current() != nil) {
            self.simpleAlert(title: "Alert", message: "User is already logged in")
            //print("User is already logged in")
        } else {
            fbButton.readPermissions = ["public_profile", "email", "user_friends","user_birthday"]
        }
        self.mainView.addSubview(fbButton)
        
        //Google

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        //GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        //GIDSignIn.sharedInstance().signInSilently()
        //GIDSignIn.sharedInstance().disconnect()
        self.mainView.addSubview(signInButton)

    }
    
    //Animate Buttons
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [],
                       animations: {
                        self.signInButton.frame = CGRect(x: self.view.frame.size.width - 131, y: 320, width: 126, height: 40)
            },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.5, delay: 0.4, options: [],
                       animations: {
                        self.fbButton.frame = CGRect(x: 10, y: 325, width: 126, height: 38)
            },
                       completion: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .red
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - LoginUser
    
    @IBAction func LoginUser(_ sender:AnyObject) {
        
        PFUser.logInWithUsername(inBackground: usernameField!.text!, password: passwordField!.text!) { user, error in
            if user != nil {
                
                self.refreshLocation()
                
            } else {
                
                self.simpleAlert(title: "Oooops", message: "Your username and password does not match")
                
                PFUser.current()?.fetchInBackground(block: { (object, error) -> Void in
                    
                    let isEmailVerified = (PFUser.current()?.object(forKey: "emailVerified") as AnyObject).boolValue
                    
                    if isEmailVerified == true {
                        self.emailField!.text = "Email has been verified."
                    } else {
                        self.emailField!.text = "Email is not verified."
                    }
                })
            }
        }
    }
    
    @IBAction func returnLogin(_ sender:AnyObject) {

        self.view.endEditing(true)
        keyboardHide()
        self.registerBtn!.setTitle("Create an Account", for: UIControlState())
        self.usernameField!.text = defaults.string(forKey: "usernameKey")
        self.passwordField!.isHidden = false 
        self.loginBtn!.isHidden = false
        self.registerBtn!.isHidden = false
        self.forgotPassword!.isHidden = false
        self.authentButton!.isHidden = false
        self.backloginBtn!.isHidden = true
        self.reEnterPasswordField!.isHidden = true
        self.emailField!.isHidden = true
        self.phoneField!.isHidden = true
        self.fbButton.isHidden = false
        self.signInButton.isHidden = false
        
    }
    
    // MARK: - RegisterUser
    
    @IBAction func registerUser(_ sender:AnyObject) {
        
        if (self.registerBtn!.titleLabel!.text == "Create an Account") {
            
            self.registerBtn!.setTitle("Register", for: UIControlState())
            self.usernameField!.text = ""
            self.loginBtn!.isHidden = true
            self.forgotPassword!.isHidden = true
            self.authentButton!.isHidden = true
            self.backloginBtn!.isHidden = false
            self.reEnterPasswordField!.isHidden = false
            self.emailField!.isHidden = false
            self.phoneField!.isHidden = false
            self.fbButton.isHidden = true
            self.signInButton.isHidden = true
            
        } else {
            //check if all text fields are completed
            if (self.usernameField!.text == "" || self.emailField!.text == "" || self.passwordField!.text == "" || self.reEnterPasswordField!.text == "") {
                
                self.simpleAlert(title: "Oooops", message: "You must complete all fields")
            } else {
                checkPasswordsMatch()
            }
        }
    }
    
    func checkPasswordsMatch() {
        
        if self.passwordField!.text == self.reEnterPasswordField!.text {
            
            registerNewUser()
            
        } else {
            
            self.simpleAlert(title: "Oooops", message: "Your entered passwords do not match")
        }
        
    }
    
    func registerNewUser() {
        
        if (self.userimage == nil) {
            self.userimage = UIImage(named:"profile-rabbit-toy.png")
        }
        pictureData = UIImageJPEGRepresentation(self.userimage!, 0.9)
        let file = PFFile(name: "Image.jpg", data: pictureData!)
        
        let user = PFUser()
        user.username = usernameField!.text
        user.password = passwordField!.text
        
        user.setObject(file!, forKey:"imageFile")
        user.signUpInBackground { succeeded, error in
            if (succeeded) {
                
                self.refreshLocation()
                self.usernameField!.text = nil
                self.passwordField!.text = nil
                self.emailField!.text = nil
                self.phoneField!.text = nil
                self.simpleAlert(title: "Success", message: "You have registered a new user")
                
            } else {
                self.simpleAlert(title: "Alert", message: "Error: \(error)")
                //print("Error: \(error)")
            }
        }
    }
    
    
    // MARK: - Google

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        self.usernameField!.text = user.profile.name
        self.emailField!.text = user.profile.email
        self.passwordField!.text = "3911"
        print(user.profile.email)
        print(user.profile.imageURL(withDimension: 400))
        GIDSignIn.sharedInstance().disconnect()
        redirectToHome()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        //LoginController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Facebook

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil) {
            self.simpleAlert(title: "Alert", message: error.localizedDescription)
            print(error.localizedDescription)
            return
        } else {
            fetchProfileFB()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
    }
    
    
    func fetchProfileFB() {
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
                .start(completionHandler: { (connection, result, error) in
                if (error == nil) {
                    
                    guard let result = result as? NSDictionary,
                        let firstName = result["first_name"] as? String,
                        let lastName = result["last_name"] as? String,
                        let email = result["email"] as? String
                        //let user_id_fb = result["id"]  as? String
                        else {
                            return
                    }
                    
                    var pictureUrl = ""
                    if let picture = result["picture"] as? [String:AnyObject],
                        let data = picture["data"] as? [String:AnyObject],
                        let url = data["url"] as? String {
                        pictureUrl = url
                    }
                    
                    self.userimage = UIImage(data: try! Data(contentsOf: URL(string: pictureUrl)!))
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.userImageView.image = self.userimage
                    })
                    
                    self.usernameField!.text = "\(firstName) \(lastName)"
                    self.emailField!.text = "\(email)"
                    self.passwordField!.text = "3911"

                    self.registerNewUser()
                    self.redirectToHome()
                    
                } else {
                    print("Error: \(error)")
                }

            })
        }
    }

    /*
    func showFriendFB() {
        let parameters = ["fields": "name,picture.type(normal),gender"]
        FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            if requestError != nil {
                print(requestError)
                return
            }
            
            var friends = [Friend]()
            for friendDictionary in user["data"] as! [NSDictionary] {
                let name = friendDictionary["name"] as? String
                if let picture = friendDictionary["picture"]?["data"]?!["url"] as? String {
                    let friend = Friend(name: name, picture: picture)
                    friends.append(friend)
                }
            }
            
            let friendsController = FriendsController(collectionViewLayout: UICollectionViewFlowLayout())
            friendsController.friends = friends
            self.navigationController?.pushViewController(friendsController, animated: true)
            self.navigationController?.navigationBar.tintColor = .whiteColor()
        })
    } */

    
    // MARK: - Password Reset
    
    @IBAction func passwordReset(_ sender:AnyObject) {
        
        self.usernameField!.isHidden = true
        self.loginBtn!.isHidden = true
        self.passwordField!.isHidden = true
        self.authentButton!.isHidden = true
        self.backloginBtn!.isHidden = false
        self.registerBtn!.isHidden = true
        self.emailField!.isHidden = false
        
        let email = self.emailField!.text
        let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        PFUser.requestPasswordResetForEmail(inBackground: finalEmail) { (success, error) -> Void in
            if success {
                self.simpleAlert(title: "Alert", message: "Link to reset the password has been send to specified email")
                
            } else {
                
                self.simpleAlert(title: "Alert", message: "Enter email in field: %@")
            }
            
        }
    }

    
    // MARK: - Authenticate
    
    
    @IBAction func authenticateUser(_ sender: AnyObject) {
        
        let context = LAContext()
        var error: NSError?
        let reasonString = "Authentication is needed to access your app! :)"
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success, policyError) -> Void in
                
                if success {
                    
                    print("Authentication successful! :) ")
                    OperationQueue.main.addOperation({ () -> Void in
                        self.didAuthenticateWithTouchId()
                    })
                } else {
                    
                    switch policyError!._code {
                        
                    case LAError.systemCancel.rawValue:
                        print("Authentication was cancelled by the system.")
                    case LAError.userCancel.rawValue:
                        print("Authentication was cancelled by the user.")
                        
                    case LAError.userFallback.rawValue:
                        print("User selected to enter password.")
                        OperationQueue.main.addOperation({ () -> Void in
                            self.showPasswordAlert()
                        })
                    default:
                        let alert : UIAlertController = UIAlertController(title: "touch id failed", message: "Try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            })
        } else {
            print(error?.localizedDescription)
            OperationQueue.main.addOperation({ () -> Void in
                self.showPasswordAlert()
            })
        }
        
    }
    
    func didAuthenticateWithTouchId() {
        
        self.usernameField!.text = "Peter Balsamo"
        self.passwordField!.text = "3911"
        self.emailField!.text = "eunited@optonline.net"
        self.phoneField!.text = "(516)241-4786"

        PFUser.logInWithUsername(inBackground: usernameField!.text!, password: passwordField!.text!) { user, error in
            if user != nil {
                
                self.refreshLocation()
            }
        }
    }
    
    // MARK: Authenticate Password Alert
    
    func showPasswordAlert() {
        /*
        let alertController = UIAlertController(title: "Touch ID Password", message: "Please enter your password.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
            
            if let textField = alertController.textFields?.first as UITextField?
            {
                if textField.text == self.defaults.string(forKey: "usernameKey")! //"Peter Balsamo"
                {
                    print("Authentication successful! :) ")
                }
                else
                {
                    self.showPasswordAlert()
                }
            }
        }
        alertController.addAction(defaultAction)
        
        alertController.addTextField { (textField) -> Void in
            
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            
        }
        self.present(alertController, animated: true, completion: nil) */
    }
    
    
    // MARK: - Map
    
    func refreshLocation() {
        
        PFGeoPoint.geoPointForCurrentLocation {
            (geoPoint: PFGeoPoint?, error: Error?) -> Void in
            if error == nil {
                PFUser.current()!.setValue(geoPoint, forKey: "currentLocation")
                PFUser.current()!.saveInBackground()
                self.redirectToHome()
                //self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        self.defaults.set(self.usernameField!.text, forKey: "usernameKey")
        self.defaults.set(self.passwordField!.text, forKey: "passwordKey")
        self.defaults.set(self.phoneField!.text, forKey: "phone")
        
        if (self.emailField!.text != nil) {
            self.defaults.set(self.emailField!.text, forKey: "emailKey")
        }
        self.defaults.set(true, forKey: "registerKey")
    }
    
    
    // MARK: - RedirectToHome
    
    func redirectToHome() {
        
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
    }
    
//------------------------------------------------
    
    // MARK: - Move Keyboard
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: nil)
    }
    
    func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: -140, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: nil)
    }
    
//--------------Firebase----------------------------------
    /*
    @IBAction func createAccountAction(_ sender: AnyObject) {
        
        guard let email = self.emailField?.text else { return }
        guard let password = self.passwordField?.text else { return }
        
        if email != "" && password != "" {
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
            
            FIRAuth.auth()?.currentUser?.link(with: credential, completion: { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.firebase!.child("users/\(user!.uid)/email").setValue(user!.email!)
                }
            })
            
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    } */
    
}

