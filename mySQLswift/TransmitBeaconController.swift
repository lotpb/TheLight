//
//  TransmitBeaconController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/19/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
//import QuartzCore
import CoreLocation
import CoreBluetooth


class TransmitBeaconController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var txtMajor: UITextField!
    @IBOutlet weak var txtMinor: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBTStatus: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var beaconBroadlabel: UILabel!
    
    var localBeaconUUID = "F34A1A1F-500F-48FB-AFAA-9584D641D7B1"
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    
    var dataDictionary = NSDictionary()
    var beaconRegion: CLBeaconRegion!
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight - Transmit Beacon", for: .normal)
        } else {
            button.setTitle("Transmit Beacon", for: .normal)
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
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.lblStatus?.font = Font.Snapshot.celltitlePad
            self.txtMajor?.font = Font.Snapshot.celltitlePad
            self.txtMinor?.font = Font.Snapshot.celltitlePad
            self.majorLabel?.font = Font.Snapshot.celltitlePad
            self.minorLabel?.font = Font.Snapshot.celltitlePad
            self.beaconBroadlabel?.font = Font.Snapshot.celltitlePad
            self.lblBTStatus?.font = Font.celltitle18l
        } else {
            
        }
        
        btnAction.layer.cornerRadius = btnAction.frame.size.width/2
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(TransmitBeaconController.handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        self.navigationItem.titleView = self.titleButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
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

            let localBeaconMajor: CLBeaconMajorValue = UInt16(Int(txtMajor.text!)!)
            let localBeaconMinor: CLBeaconMinorValue = UInt16(Int(txtMinor.text!)!)
            let uuid = UUID(uuidString: localBeaconUUID)!
            localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "com.TheLight.beacon")
            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
            
            btnAction.setTitle("Stop", for: .normal)
            lblStatus.text = "Broadcasting..."
            txtMajor.isEnabled = false
            txtMinor.isEnabled = false
            isBroadcasting = true
            self.view.backgroundColor = .lightGray

        } else {
            
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
            
            btnAction.setTitle("Start", for: .normal)
            lblStatus.text = "Stopped"
            txtMajor.isEnabled = true
            txtMinor.isEnabled = true
            isBroadcasting = false
            self.view.backgroundColor = .white
        } 
    }
    
    
    // MARK: CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var statusMessage = ""
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
            statusMessage = "Bluetooth Status: Turned On"
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
            statusMessage = "Bluetooth Status: Turned Off"
        } else if peripheral.state == .unsupported {
            statusMessage = "Bluetooth Status: Not Supported"
        }
        lblBTStatus.text = statusMessage
    }
    
    
}
