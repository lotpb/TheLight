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
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight - Social", for: .normal)
        } else {
            button.setTitle("Social", for: .normal)
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
        
        configureNoteTextView()
        noteTextview.delegate = self
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
        setMainNavItems()
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
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action)  in
            
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
                self.present(twitterComposeVC!, animated: true)
            } else {
                self.simpleAlert(title: "Alert", message: "You are not logged in to your Twitter account.")
            }
        }
        
        
        // Configure a new action to share on Facebook.
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action)  in
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                vc?.setInitialText("\(self.noteTextview.text)")
                self.present(vc!, animated: true)
            } else {
                self.simpleAlert(title: "Alert", message: "You are not connected to your Facebook account.")
            }
        }
        
        // Configure a new action to show the UIActivityViewController
        let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.default) { (action)  in
            
            let activityViewController = UIActivityViewController(activityItems: [self.noteTextview.text], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.mail]
            self.present(activityViewController, animated: true)
        }
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action)  in
            
        }
        
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        self.present(actionSheet, animated: true)
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
    
}

