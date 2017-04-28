 //
//  AppDelegate.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import GoogleSignIn
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    
    //let locationManager = CLLocationManager()
    var defaults = UserDefaults.standard
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // MARK: - Register Settings
        defaults.register(defaults: [
            "soundKey": false,
            "parsedataKey": true,
            "autolockKey": false,
            "fontKey": "System",
            "fontsizeKey": "20pt",
            "nameColorKey": "Blue",
            "usernameKey": "Peter Balsamo",
            "passwordKey": "3911",
            "websiteKey": "http://lotpb.github.io/UnitedWebPage/index.html",
            "eventtitleKey": "Appt",
            "areacodeKey": "516",
            "versionKey": "1.0",
            "emailtitleKey": "TheLight Support",
            "emailmessageKey": "<h3>Programming in Swift</h3>",
            "weatherKey": "2446726",
            "weatherNotifyKey": "false"
            ])
        
        // MARK: - Parse
        if (defaults.bool(forKey: "parsedataKey"))  {
            
            let configuration = ParseClientConfiguration {
                $0.applicationId = "lMUWcnNfBE2HcaGb2zhgfcTgDLKifbyi6dgmEK3M"
                $0.clientKey = "UVyAQYRpcfZdkCa5Jzoza5fTIPdELFChJ7TVbSeX"
                $0.server = "https://parseapi.back4app.com"
                //$0.isLocalDatastoreEnabled = true
            }
            Parse.initialize(with: configuration)
        }

        // MARK: - prevent Autolock
        if (defaults.bool(forKey: "autolockKey"))  {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        // MARK: - Background Fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        // MARK: - Register login
        if (!(defaults.bool(forKey: "registerKey")) || defaults.bool(forKey: "loginKey")) {
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as UIViewController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        // MARK: - Login
        let userId:String = defaults.object(forKey: "usernameKey") as! String!
        let userpassword:String = defaults.object(forKey: "passwordKey") as! String!
        let userSuccessful: Bool = KeychainWrapper.standard.set(userId, forKey: "usernameKey")
        let passSuccessful: Bool = KeychainWrapper.standard.set(userpassword, forKey: "passwordKey")
        
        // MARK: - Keychain
        if (userSuccessful == true), (passSuccessful == true) {
            print("Keychain successful")
        } else {
            print("Keychain failed")
        }
        //KeychainWrapper.accessGroup = "group.TheLightGroup"
        
        // MARK: - Parse
        PFUser.logInWithUsername(inBackground: userId, password:userpassword) { (user, error) in
            if error != nil {
                print("Error: \(String(describing: error)) \(String(describing: error!._userInfo))")
                return
            }
        }

        // MARK: - Facebook Sign-in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
       
        // MARK: - Firebase
        FIRApp.configure()
        
        // MARK: - AddGeotification
        //locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        
        customizeAppearance()
        registerCategories()
        registerLocal()
        set3DTouch()
        
        return true
    }

    
    // MARK: - Google/Facebook
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }

    
    // MARK: - 3D Touch
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let handledShortCutItem = handleShortCutItem(shortcutItem: shortcutItem)
        completionHandler(handledShortCutItem)
        
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
       
        var handled = false
        
        if shortcutItem.type == "1" {
            
            let rootNavigationViewController = window!.rootViewController as? UINavigationController
            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            
            //rootNavigationViewController?.popToRootViewController(animated: false)
            rootViewController?.performSegue(withIdentifier: "showleadSegue", sender: nil)
            handled = true
        }
        
        if shortcutItem.type == "2" {
            
            let rootNavigationViewController = window!.rootViewController as? UINavigationController
            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            
            //rootNavigationViewController?.popToRootViewController(animated: false)
            rootViewController?.performSegue(withIdentifier: "showcustSegue", sender: nil)
            handled = true
        }
        return handled
    }
    
    
    // MARK: - Schedule Notification set in NotificationController
    
    func scheduleNotification(at date: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = "Tutorial Reminder"
        content.body = "Just a reminder to read your tutorial over at appcoda.com!"
        content.sound = UNNotificationSound(named: "Tornado.caf")
        content.categoryIdentifier = "myCategory"
        
        let imageName = "profile-rabbit-toy"
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // MARK: - Background Fetch
    
    private func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("########### Received Background Fetch ###########")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Background transfer service download!"
            content.body = "Background transfer service: Download complete!"
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "myCategory"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "notification1", content: content, trigger: trigger)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
            
            let localNotification: UILocalNotification = UILocalNotification()
            localNotification.alertAction = "Background transfer service download!"
            localNotification.alertBody = "Background transfer service: Download complete!"
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            UIApplication.shared.presentLocalNotificationNow(localNotification)
            
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    
    // MARK: - Split view opens maincontroller
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        return true
    } 
    
     // MARK: - Music Controller
    
    internal func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    // MARK:
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    // MARK: - Facebook

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }
    
    // MARK:

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
}
// MARK: - setup RegisterUserNotification, 3DTouch
extension AppDelegate {
    
    // MARK: - App Theme Customization
    func customizeAppearance() {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .gray 
        UINavigationBar.appearance().isTranslucent = false
        
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().isTranslucent = false
        
        UIToolbar.appearance().barTintColor = Color.DGrayColor
        UIToolbar.appearance().tintColor = .white
        
        UISearchBar.appearance().barTintColor = .black
        UISearchBar.appearance().tintColor = .white
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .gray
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
                UIApplication.shared.applicationIconBadgeNumber = 0
                //center.removeAllDeliveredNotifications()
                center.removeAllPendingNotificationRequests()
            }
        }
    }
    
    func registerCategories() {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        //setup actions categories
        let action = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [action], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    func set3DTouch() {

        let firstItemIcon:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .share)
        let firstItem = UIMutableApplicationShortcutItem(type: "1", localizedTitle: "Share", localizedSubtitle: "Share an item.", icon: firstItemIcon, userInfo: nil)
        
        let firstItemIcon1:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .compose)
        let firstItem1 = UIMutableApplicationShortcutItem(type: "2", localizedTitle: "Add", localizedSubtitle: "Add an item.", icon: firstItemIcon1, userInfo: nil)
        UIApplication.shared.shortcutItems = [firstItem,firstItem1]
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        
        print("Notification being triggered")

      //window?.rootViewController?.showAlert(withTitle: nil, message: "Crap")
        completionHandler([.alert, .badge, .sound])
    }
    
    // Schedule Notification Action
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeInterval: 900, since: Date())
            scheduleNotification(at: newDate)
        }
        
        completionHandler()
    }
}




