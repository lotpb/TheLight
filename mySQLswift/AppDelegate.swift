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
//import Firebase
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var backgroundSessionCompletionHandler: (() -> Void)?
    var window: UIWindow?
    var defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
            "emailmessageKey": "<h3>Programming in Swift</h3>"
            ])
        
        // MARK: - Firebase
        
         //FIRApp.configure()
        
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
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if granted == true {
                    print("Allow Authorization")
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    print("Don't Allow Authorization")
                }
            }
        } else {
            
            let mySettings = UIUserNotificationSettings(types:[.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(mySettings)
        }
        
        application.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().delegate = self
        
        let likeAction = UNNotificationAction(identifier: "like", title: "好感動", options: [.foreground])
        let dislikeAction = UNNotificationAction(identifier: "dislike", title: "沒感覺", options: [])
        let category = UNNotificationCategory(identifier: "luckyMessage", actions: [likeAction, dislikeAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
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
        
        // MARK: - SplitViewController
        
        /*
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self */

        
        // MARK: - Facebook Sign-in
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        customizeAppearance()
        
        return true
    }

    
    // MARK: - Google/Facebook
    /*
    @available(iOS 9.0, *)
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
            return self.application(application: app, openURL: url, sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?, annotation: [])
    } */
    
    private func application(application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return (FBSDKApplicationDelegate.sharedInstance().application( application,open: url as URL!,sourceApplication: sourceApplication,annotation: annotation) || GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation))
    }

    
    // MARK: - Background Fetch
    
    private func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
            print("########### Received Background Fetch ###########")
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Background transfer service download!"
            //content.subtitle = "米花兒"
            content.body = "Background transfer service: Download complete!"
            content.badge = 1 //UIApplication.shared.applicationIconBadgeNumber + 1
            content.sound = UNNotificationSound(named: "Tornado.caf")
            //content.categoryIdentifier = "status"

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
    
    
     // MARK: - Music Controller
    
    private func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        //backgroundSessionCompletionHandler = completionHandler
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
    
    // MARK - App Theme Customization
    
    private func customizeAppearance() {
        
      //UIApplication.sharedApplication().networkActivityIndicatorVisible = true //Activity Status Bar
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

}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler:  @escaping () -> Void) {
        
        let content = response.notification.request.content
        print("title \(content.title)")
        print("userInfo \(content.userInfo)")
        print("actionIdentifier \(response.actionIdentifier)")
        
        completionHandler()
    }
}

// MARK: CLLocationManagerDelegate - Beacons
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Are you forgetting something?"
            content.subtitle = "米花兒"
            content.body = "Are you forgetting something?"
            content.badge = 1 //UIApplication.shared.applicationIconBadgeNumber + 1
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "notification1", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
            
            if let _ = region as? CLBeaconRegion {
                let notification = UILocalNotification()
                notification.alertBody = "Are you forgetting something?"
                notification.soundName = "Default"
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
    }
}

