//
//  CodeGenController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/28/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class CodeGenController: UIViewController {
    
    let fonttitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var profilePick: UIImageView!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var qrcodeImage: CIImage!
    var defaults = UserDefaults.standard


    override func viewDidLoad() {
        super.viewDidLoad()

        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("Membership Card", for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goHome))
        }
        
        let query:PFQuery = PFUser.query()!
        query.whereKey("username",  equalTo:defaults.string(forKey: "usernameKey")!)
        query.limit = 1
        query.cachePolicy = PFCachePolicy.cacheThenNetwork
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if error == nil {
                if let imageFile = object!.object(forKey: "imageFile") as? PFFile {
                    imageFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                        self.profilePick?.image = UIImage(data: imageData!)
                    }
                }
            }
        }
        
        self.textField!.font = fonttitle
        self.textField!.text = defaults.string(forKey: "usernameKey")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func performButtonAction(_ sender: AnyObject) {
        if qrcodeImage == nil {
            if textField.text == "" {
                return
            }
            
            let data = textField.text!.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator") //CIPDF417BarcodeGenerator
            
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter!.outputImage
            
            textField.resignFirstResponder()
            
            btnAction.setTitle("Clear", for: UIControlState())
            
            displayQRCodeImage()
        }
        else {
            imgQRCode.image = nil
            qrcodeImage = nil
            btnAction.setTitle("Generate", for: UIControlState())
        }
        
        textField.isEnabled = !textField.isEnabled
        slider.isHidden = !slider.isHidden
    }
    
    
    @IBAction func changeImageViewScale(_ sender: AnyObject) {
        imgQRCode.transform = CGAffineTransform(scaleX: CGFloat(slider.value), y: CGFloat(slider.value))
    }
    
    
    // MARK: Custom method implementation
    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }
    
    // MARK: - generateQRCodeFromString
    
    func generateQRCodeFromString(_ string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    //let image = generateQRCodeFromString("Hacking with Swift is the best iOS coding tutorial I've ever read!")
    
    // MARK: - generatePDF417BarcodeFromString
    
    func generatePDF417BarcodeFromString(_ string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIPDF417BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    //let userimage = generatePDF417BarcodeFromString("Hacking with Swift")
    
    // MARK: - Button
    
    func goHome() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
    }

}
