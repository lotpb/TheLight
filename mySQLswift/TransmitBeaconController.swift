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
    var beaconRegion: CLBeaconRegion!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    var dataDictionary = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnAction.layer.cornerRadius = btnAction.frame.size.width / 2
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(TransmitBeaconController.handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
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
            if bluetoothPeripheralManager.state == .poweredOn {
                let major: CLBeaconMajorValue = UInt16(Int(txtMajor.text!)!)
                let minor: CLBeaconMinorValue = UInt16(Int(txtMinor.text!)!)
                beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "com.TheLight.beacon")
                
                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : AnyObject])
                
                btnAction.setTitle("Stop", for: UIControlState())
                lblStatus.text = "Broadcasting..."
                txtMajor.isEnabled = false
                txtMinor.isEnabled = false
                
                isBroadcasting = true
            }
        }
        else {
            bluetoothPeripheralManager.stopAdvertising()
            
            btnAction.setTitle("Start", for: UIControlState())
            lblStatus.text = "Stopped"
            
            txtMajor.isEnabled = true
            txtMinor.isEnabled = true
            
            isBroadcasting = false
        }
    }
    
    
    // MARK: CBPeripheralManagerDelegate method implementation
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        /*
        var statusMessage = ""
        
        switch peripheral.state {
        case CBPeripheralManagerState.poweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case CBPeripheralManagerState.poweredOff:
            if isBroadcasting {
                switchBroadcastingState(sender: self)
            }
            statusMessage = "Bluetooth Status: Turned Off"
            
        case CBPeripheralManagerState.resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case CBPeripheralManagerState.unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case CBPeripheralManagerState.unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        lblBTStatus.text = statusMessage */
    }
    
}
