//
//  SocialController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import Social

class SocialController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var noteTextview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleButton.setTitle("TheLight - Social", for: UIControlState())
        } else {
            titleButton.setTitle("Social", for: UIControlState())
        }
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goHome))
        }
        
        configureNoteTextView()
        
        noteTextview.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBAction Function
    
    @IBAction func showShareOptions(_ sender: AnyObject) {
        
        // Dismiss the keyboard if it's visible.
        if noteTextview.isFirstResponder {
            noteTextview.resignFirstResponder()
        }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // Configure a new action for sharing the note in Twitter.
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) -> Void in
            
            // Check if sharing to Twitter is possible.
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                // Initialize the default view controller for sharing the post.
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                // Set the note text as the default post message.
                if self.noteTextview.text.characters.count <= 140 {
                    twitterComposeVC?.setInitialText("\(self.noteTextview.text)")
                }
                else {
                    let index = self.noteTextview.text.index(self.noteTextview.text.startIndex, offsetBy: 140)
                    let subText = self.noteTextview.text.substring(to: index)
                    twitterComposeVC?.setInitialText("\(subText)")
                }
                
                // Display the compose view controller.
                self.present(twitterComposeVC!, animated: true, completion: nil)
            }
            else {
                self.showAlertMessage("You are not logged in to your Twitter account.")
            }

            
        }
        
        
        // Configure a new action to share on Facebook.
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) -> Void in
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                facebookComposeVC?.setInitialText("\(self.noteTextview.text)")
                
                self.present(facebookComposeVC!, animated: true, completion: nil)
            }
            else {
                self.showAlertMessage("You are not connected to your Facebook account.")
            }
            
        }
        
        // Configure a new action to show the UIActivityViewController
        let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.default) { (action) -> Void in
            
            let activityViewController = UIActivityViewController(activityItems: [self.noteTextview.text], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [UIActivityType.mail]
            
            self.present(activityViewController, animated: true, completion: nil)
            
        }
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showAlertMessage(_ message: String!) {
        let alertController = UIAlertController(title: "EasyShare", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: Custom Functions
    
    func configureNoteTextView() {
        
        noteTextview.layer.cornerRadius = 8.0
        noteTextview.layer.borderColor = UIColor(white: 0.75, alpha: 0.5).cgColor
        noteTextview.layer.borderWidth = 1.2
    }
    
    
    // MARK: UITextViewDelegate Functions
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // MARK: - Button
    
    func goHome() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
    }
}

