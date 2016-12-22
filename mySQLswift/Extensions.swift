//
//  Constants.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 2/9/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

// MARK:, // TODO: and // FIXME:

//import Foundation
import UIKit

    enum Config {
        static let NewsLead = "Company to expand to a new web advertising directive this week."
        static let NewsCust = "Check out or new line of fabulous windows and siding."
        static let NewsVend = "Peter Balsamo Appointed to United's Board of Directors."
        static let NewsEmploy = "Health benifits cancelled immediately, ineffect starting today."
        static let BaseUrl = "http://lotpb.github.io/UnitedWebPage/index.html"
    }

    enum Color {
        static let BlueColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
        static let DGrayColor = UIColor(white:0.45, alpha:1.0)
        static let LGrayColor = UIColor(white:0.90, alpha:1.0)
        static let DGreenColor = UIColor(red:0.16, green:0.54, blue:0.13, alpha: 1.0)
        
        enum Blog {
            static let navColor = UIColor.red
            static let borderbtnColor = UIColor.lightGray.cgColor
            static let buttonColor = UIColor.red
            static let weblinkText = Color.BlueColor
            static let emaillinkText = UIColor.red
            static let phonelinkText = UIColor.green
        }
        enum Lead {
            static let navColor = UIColor.black
            static let labelColor = DGrayColor
            static let labelColor1 = UIColor.red
            static let buttonColor = UIColor.red
        }
        
        enum Cust {
            static let navColor = UIColor.black //UIColor(red: 0.21, green: 0.60, blue: 0.86, alpha: 1.0)
            static let labelColor = DGrayColor //UIColor(red: 0.20, green: 0.29, blue: 0.37, alpha: 1.0)
            static let labelColor1 = BlueColor //UIColor(red: 0.20, green: 0.29, blue: 0.37, alpha: 1.0)
            static let buttonColor = BlueColor
        }
        
        enum Vend {
            static let navColor = UIColor.black
            static let labelColor = UIColor(red: 0.56, green: 0.45, blue: 0.62, alpha: 1.0)
            //static let labelColor1 = UIColor(red: 0.10, green: 0.03, blue: 0.21, alpha: 1.0)
            static let buttonColor = UIColor(red: 0.56, green: 0.45, blue: 0.62, alpha: 1.0)
        }
        
        enum Employ {
            static let navColor = UIColor.black
            static let labelColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
            //static let labelColor1 = UIColor(red: 0.31, green: 0.23, blue: 0.17, alpha: 1.0)
            static let buttonColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
        }
        
        enum News {
            static let navColor = UIColor.rgb(red: 230, green: 32, blue: 31)
            static let buttonColor = BlueColor
        }
        
        enum Stat {
            static let navColor = UIColor.red
            //static let buttonColor = BlueColor
        }
        
        enum Snap {
            static let tablebackColor = UIColor.black
            static let backColor = UIColor(white:0.25, alpha:1.0)
            static let textColor = UIColor.white
            static let textColor1 = UIColor.lightGray
            static let lineColor = UIColor.darkGray

            //static let buttonColor = BlueColor
        }
        
        enum Table {
            static let navColor = UIColor.black
            static let labelColor = UIColor(red: 0.28, green: 0.50, blue: 0.49, alpha: 1.0)
            //static let labelColor = UIColor(red: 0.65, green: 0.49, blue: 0.35, alpha: 1.0)
        }
    }

    /*
    UIFontTextStyleTitle1 UIFontTextStyleTitle2 UIFontTextStyleTitle3
    UIFontTextStyleHeadline UIFontTextStyleSubheadline UIFontTextStyleBody
    UIFontTextStyleFootnote UIFontTextStyleCaption1 UIFontTextStyleCaption2
    */

    struct Font {
        static let navlabel = UIFont(name: "HelveticaNeue-Thin", size: 25.0)
        static let headtitle = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        static let Edittitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        static let Weathertitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
        //buttonFontSize,  labelFontSize, systemFontSize
        
        static let celltitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        static let celltitlePad = UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
        static let cellsubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        static let celllabel1 = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        static let celllabel2 = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        static let cellreply = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        static let celllike = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        
        struct Blog {
            static let celltitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
            static let cellsubtitle = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
            static let celldate = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
            static let cellLabel = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
            static let cellsubject = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        }
        
        struct News {
            static let newstitlePad = UIFont.systemFont(ofSize: 26, weight: UIFontWeightRegular)
            static let newssourcePad = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
            static let newslabel1Pad = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
            static let newslabel2Pad = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
            
            static let newstitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            static let newssource = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            static let newslabel1 = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold)
            static let newslabel2 = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        }
        
        struct Snapshot {
            static let celltitlePad = UIFont.systemFont(ofSize: 26, weight: UIFontWeightLight)
            static let cellsubtitlePad = UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular)
            static let celllabelPad = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            
            static let celltitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
            static let cellsubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
            static let cellLabel = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
            
        }
        
        struct Stat {
            static let celltitlePad = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
 
        }
        
        struct Detail {
            static let ipadname = UIFont.systemFont(ofSize: 30, weight: UIFontWeightLight)
            static let ipaddate = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            static let ipadaddress = UIFont.systemFont(ofSize: 26, weight: UIFontWeightLight)
            static let ipadAmount = UIFont.systemFont(ofSize: 60, weight: UIFontWeightRegular)
            
            static let textname = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
            static let textdate = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
            static let textaddress = UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
            static let textAmount = UIFont.systemFont(ofSize: 30, weight: UIFontWeightRegular)
            
            static let Vtextname = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
            static let Vtextdate = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
            static let VtextAmount = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
            
            static let celltitlePad = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
            static let cellsubtitlePad = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            static let celltitle = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
            static let cellsubtitle = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
            
            static let ipadnewstitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
            static let ipadnewssubtitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
            static let ipadnewsdetail = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            
            static let newstitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
            static let newssubtitle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            static let newsdetail = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
            
            static let textbutton = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        }
    }


// MARK: - RemoveWhiteSpace  //EditData

public extension String {
    
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
}


// MARK: - AlertController

public extension UIViewController {
    
    func simpleAlert (title:String, message:String) {
 
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//--------------youtube------------

extension UIColor { //youtube red
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

//declared in CollectionViewCell
let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        
        imageUrlString = urlString
        let url = URL(string: urlString)
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageToCache = UIImage(data: data!)
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            })
            
        }).resume()
    }
}

//declared in search
func requestSuggestionsURL(text: String) -> URL {
    let netText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet())!
    let url = URL.init(string: "https://api.bing.com/osjson.aspx?query=\(netText)")!
    return url
}

//------------------------------------

//not used - valid email
extension String {
    var isValidEmailAddress: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let linkDetector = try? NSDataDetector(types: types.rawValue)
        let range = NSRange(location: 0, length: self.characters.count)
        let result = linkDetector?.firstMatch(in: self, options: .reportCompletion, range: range)
        let scheme = result?.url?.scheme ?? ""
        return scheme == "mailto" && result?.range.length == self.characters.count
    }
    
    // for a login screen...
//    let text = emailTextField.text ?? ""
//    let valid = text.isValidEmailAddress
//    
//    // to see differences...
//    let goodEmail = “foo@bar.com”.isValidEmailAddress // true
//    let badEmail = "foo bar@baz.com".isValidEmailAddress // false

}

//----------------------------

