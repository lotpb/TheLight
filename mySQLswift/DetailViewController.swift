//
//  DetailViewController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/8/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import ReplayKit
//import AVFoundation
import UIKit
import CoreLocation
import iAd //added iAd
import CoreSpotlight //added CoreSpotlight
import CoreBluetooth
import MobileCoreServices //added CoreSpotlight

class DetailViewController: UIViewController, RPPreviewViewControllerDelegate, AVSpeechSynthesizerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, RPScreenRecorderDelegate {
    
    let headtitle = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    let textviewText = "Chadi sucks in Basketball, he has no picks and certainly has no rolls"
    
    @IBOutlet weak var languagePick: UIPickerView?
    let languageList = ["Hindi", "Russian", "Greek", "United States", "United Kingdom", "Italy", "Israel", "Arabic", "China", "French", "German"]
    let languageCodeList = ["hi-IN", "ru-RU", "el-GR", "en-US", "en-GB", "it-IT", "he-IL", "ar-SA", "zh-CN", "fr-FR", "de-DE"]
    var langNum : Int!
    //var langRate : Float!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak private var startRecordingButton: UIButton!
    @IBOutlet weak private var stopRecordingButton: UIButton!
    @IBOutlet weak private var processingView: UIActivityIndicatorView!
    private let recorder = RPScreenRecorder.shared()
    
    private var locationManager = CLLocationManager()
    private let identifier = "com.TheLight" //added CoreSpotlight
    private let domainIdentifier = "com.lotpb.github.io/UnitedWebPage/index.html"
    private var activity: NSUserActivity!
    
    @IBOutlet weak var latitudeText: UILabel!
    @IBOutlet weak var longitudeText: UILabel!
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var lightoff: UIButton!
    
    @IBOutlet weak var volume: UITextField?
    @IBOutlet weak var pitch: UITextField?
    @IBOutlet weak var ratetext: UITextField?
    @IBOutlet weak var subject: UITextView?

    //var defaults = NSUserDefaults.standardUserDefaults()
    
    //below has nothing
    var detailItem: AnyObject? { //dont delete for splitview
        didSet {
            // Update the view.
            //self.configureView()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleButton.setTitle("TheLight - Detail", for: UIControlState())
        } else {
            titleButton.setTitle("Detail", for: UIControlState())
        }
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        let searchButton = UIBarButtonItem(title: "Light", style: .plain, target: self, action: #selector(lightcamera))
        navigationItem.rightBarButtonItems = [searchButton]
        
        // MARK: - locationManager

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        recorder.delegate = self
        processingView.isHidden = true
        buttonEnabledControl(recorder.isRecording)

        
        let myLabel:UILabel = UILabel(frame: CGRect(x: 20, y: 135, width: 60, height: 60))
        myLabel.backgroundColor = .orange
        myLabel.textColor = .white
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.layer.masksToBounds = true
        myLabel.text = "Speak"
        myLabel.font = Font.Stat.celltitlePad
        myLabel.layer.cornerRadius = 30.0
        myLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(speak))
        myLabel.addGestureRecognizer(tap)
        self.scrollView.addSubview(myLabel)
        
        self.subject!.text = textviewText
        
        langNum = 4
        languagePick!.selectRow(langNum, inComponent: 0, animated: true)
        //langRate = 0.4
        //ratetext!.text = langRate as String
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.volume?.font = Font.Weathertitle
            self.pitch?.font = Font.Weathertitle
            self.ratetext?.font = Font.Weathertitle
            self.subject?.font = Font.Edittitle
        } else {
            self.volume?.font = Font.headtitle
            self.pitch?.font = Font.headtitle
            self.ratetext?.font = Font.headtitle
            self.subject?.font = Font.headtitle
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - CoreSpotlight
    
    @IBAction func AddItemToCoreSpotlight(_ sender: AnyObject) {
        
        let activityType = String(format: "%@.%@", identifier, domainIdentifier)
        activity = NSUserActivity(activityType: activityType)
        activity.title = "TheLight"
        activity.keywords = Set<String>(arrayLiteral: "window", "door", "siding", "roof")
        activity.isEligibleForSearch = true
        activity.becomeCurrent()
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = "TheLight"
        attributeSet.contentDescription = "CoreSpotLight tutorial"
        attributeSet.keywords = ["window", "door", "siding", "roof"]
        //let image = UIImage(named: "m7")!
        //let data = UIImagePNGRepresentation(image)
        //attributeSet.thumbnailData = data
        
        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { (error: Error?) -> Void in
            if let error =  error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed")
            }
        }
    }
    
    @IBAction func RemoveItemFromCoreSpotlight(_ sender: AnyObject) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier])
            { (error: Error?) -> Void in
                if let error = error {
                    print("Remove error: \(error.localizedDescription)")
                } else {
                    print("Search item successfully removed")
                }
        }
    }
    
    
    // MARK: - ScreenRecorderDelegate
    
    // called after stopping the recording
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWithError error: Error, previewViewController: RPPreviewViewController?) {
        NSLog("Stop recording")
    }
    
    // called when the recorder availability has changed
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        let availability = screenRecorder.isAvailable
        NSLog("Availablility: \(availability)")
    }
    
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        NSLog("Preview finish")
        
        DispatchQueue.main.async { [unowned previewController] in
            // close preview window
            previewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func startRecordingButtonTapped(_ sender: AnyObject) {
        
        processingView.isHidden = false

        recorder.startRecording{ [unowned self] (error) in
            DispatchQueue.main.async { [unowned self] in
                self.processingView.isHidden = true
            }
            
            if let error = error {
                NSLog("Failed start recording: \(error.localizedDescription)")
                return
            }
            
            NSLog("Start recording")
            self.buttonEnabledControl(true)
        }
    }
    
    @IBAction func stopRecordingButtonTapped(_ sender: AnyObject) {
        processingView.isHidden = false
        
        // end recording
        recorder.stopRecording(handler: { [unowned self] (previewViewController, error) in
            DispatchQueue.main.async { [unowned self] in
                self.processingView.isHidden = true
            }
            
            self.buttonEnabledControl(false)
            
            if let error = error {
                NSLog("Failed stop recording: \(error.localizedDescription)")
                return
            }
            
            NSLog("Stop recording")
            previewViewController?.previewControllerDelegate = self
            
            DispatchQueue.main.async { [unowned self] in
                // show preview window
                self.present(previewViewController!, animated: true)
            }
            })
    }
    
    private func buttonEnabledControl(_ isRecording: Bool) {
        DispatchQueue.main.async { [unowned self] in
            let enebledColor = UIColor(red: 0.0, green: 122.0/255.0, blue:1.0, alpha: 1.0)
            let disabledColor = UIColor.lightGray
            
            if !self.recorder.isAvailable {
                self.startRecordingButton.isEnabled = false
                self.startRecordingButton.backgroundColor = disabledColor
                self.stopRecordingButton.isEnabled = false
                self.stopRecordingButton.backgroundColor = disabledColor
                
                return
            }
            
            self.startRecordingButton.isEnabled = !isRecording
            self.startRecordingButton.backgroundColor = isRecording ? disabledColor : enebledColor
            self.stopRecordingButton.isEnabled = isRecording
            self.stopRecordingButton.backgroundColor = isRecording ? enebledColor : disabledColor
        }
    }


    // MARK: - camera light

    func lightcamera() {
        toggleTorch(on: true)

    }
    
    @IBAction func lightoff(_ sender: AnyObject) {
        toggleTorch(on: false)
        
    }
    
    func toggleTorch(on: Bool) {
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            self.simpleAlert(title: "Alert!", message: "Torch is not available")
        }
    }
    
    
    // MARK: - speech
    
    @IBAction func speech(_ sender: AnyObject) {
        
        //"The words of King Solomon the wisest of men. for i found one righteous man in a thousand and not one righteous woman"
        //"Hello world!!! my name is Peter Balsamo")
        //"Hello world!!! It's time too kiss the feet of Peter Balsamo"
        let utterance = AVSpeechUtterance(string: "The words of King Solomon the wisest of men. for i found one righteous man in a thousand and not one righteous woman")
        utterance.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        utterance.rate = 0.3
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    
    // MARK: - Speak red text
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: characterRange)
        subject!.attributedText = mutableAttributedString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        subject!.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
    @IBAction func speak(_ sender: AnyObject) {
        let string = subject!.text
        let utterance = AVSpeechUtterance(string: string!)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCodeList[langNum])
        utterance.rate = 0.4 //langRate
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }
    
    // MARK:  Pickerview
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return languageList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return languageList[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        langNum = row
    }
    
    // MARK: - Button
    
    
    // MARK: - locationManager
    
    
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.first {
 
            latitudeText!.text = String(format: "Lat: %.4f",
                location.coordinate.latitude)
            longitudeText!.text = String(format: "Lon: %.4f",
                location.coordinate.longitude)
            
        }
    }
    
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
 
    
}

