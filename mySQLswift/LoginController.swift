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
import TwitterKit

// A delay function
/*
func delay(_ seconds: Double, completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(seconds * 1000.0))) {
        completion()
    }
} */


class LoginController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate,  GIDSignInUIDelegate, GIDSignInDelegate {
    
    let ipadtitle = UIFont.systemFont(ofSize: 20)
    let celltitle = UIFont.systemFont(ofSize: 18)
    
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
    var googleButton : GIDSignInButton = GIDSignInButton()
    //Twitter
    var twitterButton : TWTRLogInButton = TWTRLogInButton()
    
    let userImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Facebook
        fbButton.delegate = self
        if (FBSDKAccessToken.current() != nil) {
            self.simpleAlert(title: "Alert", message: "User is already logged in")
        } else {
            fbButton.readPermissions = ["public_profile", "email", "user_friends","user_birthday"]
        }
        
        //Google
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
      //GIDSignIn.sharedInstance().signInSilently()
        
        //Twitter
        setupTwitterButton()
        
        setupView()
        setupFont()
        setupConstraints()
    }
    
    func setupFont() {
        if UI_USER_INTERFACE_IDIOM() == .pad {
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
    }
    
    fileprivate func setupView() {
        
        if ((defaults.string(forKey: "registerKey") == nil)) {
            self.registerBtn!.setTitle("Register", for: .normal)
            self.loginBtn!.isHidden = true //hide login button no user is regsitered
            self.forgotPassword!.isHidden = true
            self.authentButton!.isHidden = true
            self.fbButton.isHidden = true
            self.googleButton.isHidden = true
            self.twitterButton.isHidden = true
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
            self.googleButton.isHidden = false
            self.twitterButton.isHidden = false
            self.emailField!.isHidden = true
            self.phoneField!.isHidden = true
            self.backloginBtn!.isHidden = true
        }

        self.registerBtn!.setTitleColor(.white, for: .normal)
        self.loginBtn!.setTitleColor(.white, for: .normal)
        self.backloginBtn!.setTitleColor(.white, for: .normal)
        self.emailField!.keyboardType = .emailAddress
        self.phoneField!.keyboardType = .numbersAndPunctuation
        
        self.passwordField!.text = ""
        self.userimage = nil
    }
    
    func setupConstraints() {
        self.mainView.addSubview(fbButton)
        self.mainView.addSubview(googleButton)
        
        mapView?.translatesAutoresizingMaskIntoConstraints = false
        if UI_USER_INTERFACE_IDIOM() == .pad {
            mapView?.heightAnchor.constraint(equalToConstant: 380).isActive = true
        } else {
            mapView?.heightAnchor.constraint(equalToConstant: 175).isActive = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .black
    }
    
    //Animate Buttons
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeKeyboardNotifications() //Move Keyboard
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.googleButton.frame = CGRect(x: self.view.frame.width - 125, y: 320, width: 110, height: 40)
            self.fbButton.frame = CGRect(x: 10, y: 325, width: 110, height: 38)
            if UI_USER_INTERFACE_IDIOM() == .pad {
                self.twitterButton.frame = CGRect(x: self.view.frame.width/2 - 90, y: 325, width: 180, height: 40)
            } else {
                self.twitterButton.frame = CGRect(x: self.view.frame.width/2 - 55, y: 325, width: 110, height: 40)
            }
        }, completion: nil
        )
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
                //self.redirectToHome()
                
            } else {
                
                self.simpleAlert(title: "Oooops", message: "Your username and password does not match")
                
                PFUser.current()?.fetchInBackground(block: { (object, error)  in
                    
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
        self.registerBtn!.setTitle("Create an Account", for: .normal)
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
        self.googleButton.isHidden = false
        self.twitterButton.isHidden = false
        
    }
    
    // MARK: - RegisterUser
    
    @IBAction func registerUser(_ sender:AnyObject) {
        
        if (self.registerBtn!.titleLabel!.text == "Create an Account") {
            
            self.registerBtn!.setTitle("Register", for: .normal)
            self.usernameField!.text = ""
            self.loginBtn!.isHidden = true
            self.forgotPassword!.isHidden = true
            self.authentButton!.isHidden = true
            self.backloginBtn!.isHidden = false
            self.reEnterPasswordField!.isHidden = false
            self.emailField!.isHidden = false
            self.phoneField!.isHidden = false
            self.fbButton.isHidden = true
            self.googleButton.isHidden = true
            self.twitterButton.isHidden = true
            
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
        user.email = emailField!.text
        
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
                self.simpleAlert(title: "Alert", message: "Error: \(String(describing: error))")
            }
        }
        /*
        FIRAuth.auth()?.createUser(withEmail: (emailField?.text!)!, password: (passwordField?.text!)!) { (user, error) in
            
            if error == nil {
                print("You have successfully signed up")
                //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(vc!, animated: true)
                
            } else {
                self.simpleAlert(title: "Alert", message: "Error: \(error)")
            }
        } */
        
    }
    
    // MARK: - TwitterButton
    
    fileprivate func setupTwitterButton() {
        twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print("Failed to login via Twitter: ", err)
                return
            }
            //print("Successfully logged in under Twitter...")
            //lets login with Firebase
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if let err = error {
                    print("Failed to login to Firebase with Twitter: ", err)
                    return
                }
                print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
            })
        }
        self.mainView.addSubview(twitterButton)
    }
    
    
    // MARK: - Google

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        self.usernameField!.text = user.profile.name
        self.emailField!.text = user.profile.email
        self.passwordField!.text = user.userID //"3911"
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            print("Successfully logged into Firebase with Google", uid)
        })
        
        /*
        var pictureUrl = ""
        pictureUrl = user.profile.imageURL(withDimension: 400)
        
        self.userimage = UIImage(data: try! Data(contentsOf: URL(string: pictureUrl)!))
        DispatchQueue.main.async(execute: { ()  in
            self.userImageView.image = self.userimage
        }) */
        
        //print(user.profile.imageURL(withDimension: 400))
        //GIDSignIn.sharedInstance().disconnect()
        
        self.registerNewUser()
        self.redirectToHome()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
    }
    
    
    // MARK: - Facebook

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil) {
            print(error)
            return
        }
        
        fetchProfileFB()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    
    func fetchProfileFB() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            
            print("Successfully logged in with our user: ", user ?? "")
        })
        
        //if((FBSDKAccessToken.current()) != nil){
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
            .start { (connection, result, error) in
                if (error == nil) {
                    
                    guard let result = result as? NSDictionary,
                        let firstName = result["first_name"] as? String,
                        let lastName = result["last_name"] as? String,
                        let email = result["email"] as? String,
                        let useId = result["id"]  as? String
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
                    DispatchQueue.main.async(execute: { ()  in
                        self.userImageView.image = self.userimage
                    })
                    
                    self.usernameField!.text = "\(firstName) \(lastName)"
                    self.emailField!.text = "\(email)"
                    self.passwordField!.text = "\(useId)" //"3911"
                    
                    self.registerNewUser()
                    self.redirectToHome()
                    
                } else {
                    print("Failed to start graph request:", error ?? "")
                    return
                }
                
        }
        //}
    }

    /*
    func showFriendFB() {
        let parameters = ["fields": "name,picture.type(normal),gender"]
        FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError)  in
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
        let finalEmail = email!.removeWhiteSpace()        
        PFUser.requestPasswordResetForEmail(inBackground: finalEmail) { (success, error)  in
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
        let reason = "Identify yourself!"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self.didAuthenticateWithTouchId()
                    } else {
                        
                        switch authenticationError!._code {
                            
                        case LAError.systemCancel.rawValue:
                            print("Authentication was cancelled by the system.")
                        case LAError.userCancel.rawValue:
                            print("Authentication was cancelled by the user.")
                            
                        case LAError.userFallback.rawValue:
                            print("User selected to enter password.")
                        default:
                            let alert = UIAlertController(title: "Authentication failed", message: "Your fingerprint could not be verified; please try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        } else {
            print(error as Any)
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
    
    
    // MARK: - Map
    
    func refreshLocation() {
        
        PFGeoPoint.geoPointForCurrentLocation {(geoPoint: PFGeoPoint?, error: Error?) in
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
        self.performSegue(withIdentifier: "loginSegue", sender: self)
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
        
        if email != "", password != "" {
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
            
            FIRAuth.auth()?.currentUser?.link(with: credential, completion: { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true)
                } else {
                    self.firebase!.child("users/\(user!.uid)/email").setValue(user!.email!)
                }
            })
            
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true)
        }
        
    } */
    
}

