//
//  TransmitBeaconController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth


class TransmitBeaconController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBTStatus: UILabel!
    @IBOutlet weak var txtMajor: UITextField!
    @IBOutlet weak var txtMinor: UITextField!
    
    let uuid = UUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    
    var dataDictionary = NSDictionary()
    var beaconRegion: CLBeaconRegion!
    
    
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
        
        btnAction.layer.cornerRadius = btnAction.frame.size.width / 2
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(TransmitBeaconController.handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Custom method implementation
    
    func handleSwipeGestureRecognizer(_ gestureRecognizer: UISwipeGestureRecognizer) {
        txtMajor.resignFirstResponder()
        txtMinor.resignFirstResponder()
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchBroadcastingState(sender: AnyObject) {
        if txtMajor.text == "" || txtMinor.text == "" {
            return
        }
        
        if txtMajor.isFirstResponder || txtMinor.isFirstResponder {
            return
        }
        
        
        if !isBroadcasting {
            
            if peripheralManager.state == .poweredOn {
                let major: CLBeaconMajorValue = UInt16(Int(txtMajor.text!)!)
                let minor: CLBeaconMinorValue = UInt16(Int(txtMinor.text!)!)

                localBeacon = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "com.TheLight.beacon")
                beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
                peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
                
                beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "com.TheLight.beacon")
                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                peripheralManager.startAdvertising(dataDictionary as? [String : AnyObject])
                
                btnAction.setTitle("Stop", for: UIControlState())
                lblStatus.text = "Broadcasting..."
                txtMajor.isEnabled = false
                txtMinor.isEnabled = false
                
                isBroadcasting = true
            }
        }
        else {
            peripheralManager.stopAdvertising()
            
            btnAction.setTitle("Start", for: UIControlState())
            lblStatus.text = "Stopped"
            
            txtMajor.isEnabled = true
            txtMinor.isEnabled = true
            
            isBroadcasting = false
        }
    }
    
    
    // MARK: CBPeripheralManagerDelegate method implementation
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var statusMessage = ""
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
            statusMessage = "Bluetooth Status: Turned On"
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
            statusMessage = "Bluetooth Status: Turned Off"
        }
        lblBTStatus.text = statusMessage
        
        
        /*
        var statusMessage = ""
        
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
            statusMessage = "Bluetooth Status: Turned On"

        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
            statusMessage = "Bluetooth Status: Turned Off"
        }
        
        lblBTStatus.text = statusMessage */
        
        /*
        var statusMessage = ""
        
        switch peripheral.state {
        case .poweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case .poweredOff:
            if isBroadcasting {
                switchBroadcastingState(sender: self)
            }
            statusMessage = "Bluetooth Status: Turned Off"
            
        case .resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case .unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case .unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        lblBTStatus.text = statusMessage */
    }
    
    // MARK: - Button
    
    func goHome() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
    }
    
}
