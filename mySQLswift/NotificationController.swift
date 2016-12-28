//
//  NotificationController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/20/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationController: UIViewController {
    
    let celltitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
    
    @IBOutlet weak var customMessage: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var frequencySegmentedControl : UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar

        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleButton.setTitle("TheLight - Notifications", for: UIControlState())
        } else {
            titleButton.setTitle("Notifications", for: UIControlState())
        }
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton

        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(NotificationController.actionButton))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(NotificationController.editButton))
        navigationItem.rightBarButtonItems = [editButton, actionButton]
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goHome))
        }
        
        self.customMessage.clearButtonMode = .always
        self.customMessage!.font = celltitle
        self.customMessage.placeholder = "enter notification"
        
        self.saveButton.setTitleColor(.orange, for: UIControlState())
        self.saveButton.backgroundColor = .white
        self.saveButton.layer.cornerRadius = 24.0
        self.saveButton.layer.borderColor = UIColor.orange.cgColor
        self.saveButton.layer.borderWidth = 3.0
        
        UITextField.appearance().tintColor = .orange

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = .white
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.DGrayColor
        }
    }
    
    // MARK: - localNotification
    
    @IBAction func datePickerDidSelectNewDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        print("Selected date: \(selectedDate)")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleNotification(at: selectedDate)
    }
    
    @IBAction func sendNotification(_ sender:AnyObject) {
        
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.body = customMessage.text!
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "myCategory"
            
            if let path = Bundle.main.path(forResource: "calendar", ofType: "png") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    let attachment = try UNNotificationAttachment(identifier: "calendar", url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("The attachment was not loaded.")
                }
            }
            
            let month = datePicker.calendar.component(.month, from: datePicker.date)
            let day = datePicker.calendar.component(.day, from: datePicker.date)
            let hour = datePicker.calendar.component(.hour, from: datePicker.date)
            let minute = datePicker.calendar.component(.minute, from: datePicker.date)
            
            var dateComponents = DateComponents()
            dateComponents.timeZone = .current
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: "member-id-123", content: content, trigger: trigger)
            
            UNUserNotificationCenter .current().add(request, withCompletionHandler: nil)
            
        } else {
        
        let notifications:UILocalNotification = UILocalNotification()
        notifications.timeZone = TimeZone.current
        notifications.fireDate = fixedNotificationDate(datePicker.date)
        
        switch(frequencySegmentedControl.selectedSegmentIndex){
        case 0:
            //notifications.repeatInterval = NSCalendar.Unit.
            break;
        case 1:
            notifications.repeatInterval = .day
            break;
        case 2:
            notifications.repeatInterval = .weekday
            break;
        case 3:
            notifications.repeatInterval = .year
            break;
        default:
            //notifications.repeatInterval = Calendar.init(identifier: 0)
            break;
        }
        
        notifications.alertBody = customMessage.text
        notifications.alertAction = "Hey you! Yeah you! Swipe to unlock!"
        notifications.category = "status"
        notifications.userInfo = [ "cause": "inactiveMembership"]
        notifications.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        notifications.soundName = "Tornado.caf"
        UIApplication.shared.scheduleLocalNotification(notifications)
        self.customMessage.text = ""
        }
    }
    
    
    func memberNotification() {
      
        if #available(iOS 10.0, *) {

            let content = UNMutableNotificationContent()
            content.title = "Membership Status"
            content.body = "Our system has detected that your membership is inactive."
            content.badge = 1
            content.sound = UNNotificationSound(named: "Tornado.caf")
            content.categoryIdentifier = "myCategory"
            
            let imageURL = Bundle.main.url(forResource: "map", withExtension: "png")
            let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
            content.attachments = [attachment]
            
          //content.userInfo = ["customNumber": 100]
            content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "member-id-123", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
            
            let localNotification: UILocalNotification = UILocalNotification()
            localNotification.alertAction = "Membership Status"
            localNotification.alertBody = "Our system has detected that your membership is inactive."
            localNotification.fireDate = Date(timeIntervalSinceNow: 15)
            localNotification.timeZone = TimeZone.current
            localNotification.category = "status"
            localNotification.userInfo = ["cause": "inactiveMembership"]
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            localNotification.soundName = "Tornado.caf"
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        
    }
    
    
    func blogNotification() {
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Blog Post"
            content.subtitle = "New message posted"
            content.body = "TheLight just posted a new message"
            content.badge = 1
            content.sound = UNNotificationSound(named: "Tornado.caf")
            content.categoryIdentifier = "myCategory"
            
            let imageURL = Bundle.main.url(forResource: "comments", withExtension: "png")
            let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
            content.attachments = [attachment]
            content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "newBlog-id-123", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
            
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Blog Post"
        localNotification.alertBody = "New Blog Posted at TheLight"
        localNotification.fireDate = Date(timeIntervalSinceNow: 15)
        localNotification.timeZone = TimeZone.current
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
    func HeyYouNotification() {
        //setup for 2:30PM
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Work-Out and be awesome!"
            content.body = "Hey you! Yeah you! Time to Workout!"
            content.badge = 1
            content.sound = UNNotificationSound(named: "Tornado.caf")
            content.categoryIdentifier = "myCategory"
            
            let imageURL = Bundle.main.url(forResource: "news", withExtension: "png")
            let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
            content.attachments = [attachment]
            content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
            
            var dateComponents = DateComponents()
            dateComponents.hour = 14
            dateComponents.minute = 30
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
          //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "heyYou-id-123", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "be awesome!"
        localNotification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
        localNotification.fireDate = Date(timeIntervalSinceNow: 15)
        localNotification.timeZone = TimeZone.current
        localNotification.userInfo = ["CustomField1": "w00t"]
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        localNotification.soundName = "Tornado.caf"
        UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        
    }
    
    func promoNotification() {
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Promo Sale"
            content.body = "Forget Something? Come back and SAVE 15% with Promo Code MYCART"
            content.badge = 1
            content.sound = UNNotificationSound(named: "Tornado")
            content.categoryIdentifier = "myCategory"
            
            let imageURL = Bundle.main.url(forResource: "calendar", withExtension: "png")
            let attachment = try! UNNotificationAttachment(identifier: "", url: imageURL!, options: nil)
            content.attachments = [attachment]
            content.userInfo = ["link":"https://www.facebook.com/himinihana/photos/a.104501733005072.5463.100117360110176/981809495274287"]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "promo-id-123", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "TheLight!"
        localNotification.alertBody = "Forget Something? Come back and SAVE 15% with Promo Code MYCART"
        localNotification.fireDate = Date(timeIntervalSinceNow: 15)
        localNotification.timeZone = TimeZone.current
        localNotification.userInfo = ["CustomField1": "w00t"]
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        localNotification.soundName = "Tornado.caf"
        UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        
    }
    
    
    //Here we are going to set the value of second to zero
    func fixedNotificationDate(_ dateToFix: Date) -> Date {
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: dateToFix)
        
        dateComponents.second = 0
        
        let fixedDate: Date = Calendar.current.date(from: dateComponents)!
        
        return fixedDate
        
    }
    
    // MARK: - Button
    
    func actionButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        
        let buttonSix = UIAlertAction(title: "Membership Status", style: .default, handler: { (action) -> Void in
            self.memberNotification()
        })
        
        let newBog = UIAlertAction(title: "New Blog Posted", style: .default, handler: { (action) -> Void in
            self.blogNotification()
        })
        let heyYou = UIAlertAction(title: "Hey You", style: .default, handler: { (action) -> Void in
            self.HeyYouNotification()
        })
        
        let promo = UIAlertAction(title: "Promo Code", style: .default, handler: { (action) -> Void in
            self.promoNotification()
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        }
        
        alertController.addAction(buttonSix)
        alertController.addAction(newBog)
        alertController.addAction(heyYou)
        alertController.addAction(promo)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func editButton(_ sender:AnyObject) {
        
        self.performSegue(withIdentifier: "notificationdetailsegue", sender: self)
        
    }
    
    func goHome() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
    }
    
}

