//
//  SpotBeaconController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation


class SpotBeaconController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnSwitchSpotting: UIButton!
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!
    
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var lastProximity: CLProximity! = CLProximity.unknown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("TheLight Software", for: UIControlState())
        titleButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 25.0)
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goHome))
        }
        
        lblBeaconDetails.isHidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = UUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "com.TheLight.beacon")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(_ sender: AnyObject) {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.pausesLocationUpdatesAutomatically = false //added
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Stop Spotting", for: UIControlState())
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", for: UIControlState())
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.isHidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.isHidden = false
        simpleAlert(title: "Welcome", message: "Welcome to our store") //added
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.isHidden = true
        simpleAlert(title: "Good Bye", message: "Have a nice day") //added
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        var shouldHideBeaconDetails = true
        let foundBeacons = beacons
        
        if foundBeacons.count > 0 {
            //if let closestBeacon = beacons[0] as? CLBeacon {
            let closestBeacon = beacons[0] as CLBeacon
            
            if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                lastFoundBeacon = closestBeacon
                lastProximity = closestBeacon.proximity
                
             
                
                var proximityMessage: String!
                
                
                UIView.animate(withDuration: 0.8) {
                    
                    
                    switch self.lastFoundBeacon.proximity {
                    case CLProximity.immediate:
                        proximityMessage = "Very close"
                        self.view.backgroundColor = .red
                        self.lblBeaconReport.textColor = .white
                        self.lblBeaconDetails.textColor = .white
                        self.lblBeaconReport.textColor = .white
                    case CLProximity.near:
                        proximityMessage = "Near"
                        self.view.backgroundColor = .purple
                        self.lblBeaconReport.textColor = .white
                        self.lblBeaconDetails.textColor = .white
                        self.lblBeaconReport.textColor = .white
                    case CLProximity.far:
                        proximityMessage = "Far"
                        self.view.backgroundColor = .blue
                        self.lblBeaconReport.textColor = .white
                        self.lblBeaconDetails.textColor = .white
                        self.lblBeaconReport.textColor = .white
                    case CLProximity.unknown:
                        proximityMessage = "Where's the beacon?"
                        self.view.backgroundColor = .green
                        //lblBeaconReport.textColor = .white
                        //lblBeaconDetails.textColor = .white
                        //lblBeaconReport.textColor = .white
                        /*
                         default:
                         proximityMessage = "Where's the beacon?"
                         self.view.backgroundColor = .white */
                    }
                }
                
                shouldHideBeaconDetails = false
                
                lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.int32Value) + "\nMinor = " + String(closestBeacon.minor.int32Value) + "\nDistance: " + proximityMessage
                /*
                var makeString = "Beacon Details:\n"
                makeString += "UUID = \(closestBeacon.proximityUUID.UUIDString)\n"
                makeString += "Identifier = \(region.identifier)\n"
                makeString += "Major Value = \(closestBeacon.major.intValue)\n"
                makeString += "Minor Value = \(closestBeacon.minor.intValue)\n"
                makeString += "Distance From iBeacon = \(proximityMessage)"
                lblBeaconDetails.text = makeString */
            }
            //}
        }
        //}
        
        lblBeaconDetails.isHidden = shouldHideBeaconDetails
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }
    
    // MARK: - Button
    
    func goHome() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
    }
    
}
