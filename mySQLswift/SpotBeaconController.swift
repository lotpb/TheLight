//
//  SpotBeaconController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import CoreLocation
//import QuartzCore


class SpotBeaconController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnSwitchSpotting: UIButton!
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!
    @IBOutlet weak var beaconspotLabel: UILabel!
    @IBOutlet weak var beaconlocateLabel: UILabel!
    
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    //var lastFoundBeacon: CLBeacon! = CLBeacon()
    //var lastProximity: CLProximity! = CLProximity.unknown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleButton.setTitle("TheLight - Spot Beacon", for: UIControlState())
        } else {
            titleButton.setTitle("Spot Beacon", for: UIControlState())
        }
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        lblBeaconDetails.isHidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            //self.btnSwitchSpotting?.font = Font.Snapshot.celltitlePad
            self.lblBeaconReport?.font = Font.Snapshot.celltitlePad
            self.lblBeaconDetails?.font = Font.Snapshot.celltitlePad
            //self.beaconspotLabel?.font = Font.Snapshot.celltitlePad
            self.beaconlocateLabel?.font = Font.Snapshot.celltitlePad
        } else {
            //self.btnSwitchSpotting?.font = Font.Snapshot.celltitlePad
            //self.lblBTStatus?.font = Font.Snapshot.celltitlePad
            //self.lblBeaconReport?.font = Font.Snapshot.celltitlePad
            //self.lblBeaconDetails?.font = Font.Snapshot.celltitlePad
            //self.beaconspotLabel?.font = Font.Snapshot.celltitlePad
            //self.beaconlocateLabel?.font = Font.Snapshot.celltitlePad

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(_ sender: AnyObject) {
        
        let uuid = UUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "com.TheLight.beacon")
      //beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 100, minor: 1, identifier: "com.TheLight.beacon")
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
        if !isSearchingForBeacons {
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
            self.view.backgroundColor = UIColor.white
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    //startScanning()
                }
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    
    func updateDistance(_ distance: CLProximity) {
        
        var proximityMessage: String!
        
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                proximityMessage = "Where's the beacon?"
                self.view.backgroundColor = .gray
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .orange
                self.beaconspotLabel.textColor = .orange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
                
            case .far:
                proximityMessage = "Far"
                self.view.backgroundColor = .blue
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .orange
                self.beaconspotLabel.textColor = .orange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .white
                
            case .near:
                proximityMessage = "Near"
                self.view.backgroundColor = .orange
                self.btnSwitchSpotting?.titleLabel?.textColor = .orange
                self.btnSwitchSpotting?.backgroundColor = .white
                self.beaconspotLabel.textColor = .white
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
                
            case .immediate:
                proximityMessage = "Very close"
                self.view.backgroundColor = .red
                self.btnSwitchSpotting?.titleLabel?.textColor = .white
                self.btnSwitchSpotting?.backgroundColor = .orange
                self.beaconspotLabel.textColor = .orange
                self.lblBeaconReport.textColor = .white
                self.lblBeaconDetails.textColor = .white
                self.beaconlocateLabel.textColor = .black
            }
        }
        lblBeaconDetails.text = "Beacon Details:\nMajor = " + proximityMessage
    }
    
    /*
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
    } */

    
    // MARK: - Button
    
}
