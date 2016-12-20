//
//  AppDelegate.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import UserNotifications
import GoogleSignIn
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var backgroundSessionCompletionHandler: (() -> Void)?
    var window: UIWindow?
    var defaults = UserDefaults.standard

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
            "weatherKey": "2446726"
            ])
        
        
        // MARK: - Parse
        
        if (defaults.bool(forKey: "parsedataKey"))  {
            
        Parse.setApplicationId("lMUWcnNfBE2HcaGb2zhgfcTgDLKifbyi6dgmEK3M", clientKey: "UVyAQYRpcfZdkCa5Jzoza5fTIPdELFChJ7TVbSeX")
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        }

        // MARK: - prevent Autolock
        
        if (defaults.bool(forKey: "autolockKey"))  {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        // MARK: - RegisterUserNotification
        
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
                if !accepted {
                    print("Request Authorization Failed (\(error), \(error?.localizedDescription))")
                }
            }
            
            let action = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
            let category = UNNotificationCategory(identifier: "myCategory", actions: [action], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
        } else {
            
            let mySettings = UIUserNotificationSettings(types:[.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(mySettings)
        }
        
        application.applicationIconBadgeNumber = 0
        
        
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
        
        //Keychain
        
        //KeychainWrapper.accessGroup = "group.TheLightGroup"
        if (userSuccessful == true) && (passSuccessful == true) {
            print("Keychain successful")
        } else {
            print("Keychain failed")
        }
        
        //Parse
        
        PFUser.logInWithUsername(inBackground: userId, password:userpassword) { (user, error) -> Void in
            if error != nil {
                print("Error: \(error) \(error!._userInfo)")
                return
            }
        }
        
        
        // MARK: - Customize Appearance
        
        customizeAppearance()

        
        // MARK: - Facebook Sign-in
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
       
        // MARK: - Firebase
        
        FIRApp.configure()
        
        // MARK: - 3D Touch
        
        let firstItemIcon:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .share)
        let firstItem = UIMutableApplicationShortcutItem(type: "1", localizedTitle: "Share", localizedSubtitle: "Share an item.", icon: firstItemIcon, userInfo: nil)
        
        let firstItemIcon1:UIApplicationShortcutIcon = UIApplicationShortcutIcon(type: .compose)
        let firstItem1 = UIMutableApplicationShortcutItem(type: "2", localizedTitle: "Add", localizedSubtitle: "Add an item.", icon: firstItemIcon1, userInfo: nil)
        
        
        application.shortcutItems = [firstItem,firstItem1]
  
        
        // MARK: - SplitViewController
        /*
         // Override point for customization after application launch.
         let splitViewController = self.window!.rootViewController as! UISplitViewController
         let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
         navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
         splitViewController.delegate = self */
        
        
        return true
    }

    
    // MARK: - Google/Facebook
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }
    

    /*
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return (FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation))
    } */

    
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
    
    
    // MARK: - Schedule Notification
    
    func scheduleNotification(at date: Date) {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Membership Status"
        content.body = "Our system has detected that your membership is inactive.!"
        content.sound = UNNotificationSound(named: "Tornado.caf")
        content.categoryIdentifier = "status"
        
        if let path = Bundle.main.path(forResource: "wishlist", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "wishlist", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("The attachment was not loaded.")
            }
        }
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
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
            content.categoryIdentifier = "Background Fetch"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let request = UNNotificationRequest(identifier: "notification1", content: content, trigger: trigger)
            
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
    
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        /*
         guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
         guard let topAsDetailController = secondaryAsNavController.topViewController as? SnapshotController else { return false }
         
         if topAsDetailController.detailItem == nil {
         // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
         return true
         } */
        
        return false
    }
    
    
     // MARK: - Music Controller
    
    internal func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    // MARK: - Geotify
    
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            
            let content = UNMutableNotificationContent()
            content.title = note(fromRegionIdentifier: region.identifier)!
            content.body = note(fromRegionIdentifier: region.identifier)!
            content.badge = 1
            content.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "Geotify-id-123", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
        let index = geotifications?.index { $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.note : nil
    }
    
    
    // MARK: - App Theme Customization
    
    private func customizeAppearance() {
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .gray
        UINavigationBar.appearance().isTranslucent = false
        
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().isTranslucent = false
        //UITabBar.appearance().unselectedItemTintColor = UIColor.yellow
        
        UIToolbar.appearance().barTintColor = Color.DGrayColor
        UIToolbar.appearance().tintColor = .white
        
        UISearchBar.appearance().barTintColor = .black
        UISearchBar.appearance().tintColor = .white
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .gray
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeInterval: 5, since: Date())
            scheduleNotification(at: newDate)
        }
    }
}
// add for Geotify
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
}


