//
//  Constants.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 2/9/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

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
        //static let MGrayColor = UIColor(white:0.25, alpha:1.0)
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
            static let navColor = UIColor.black //UIColor(red: 0.01, green: 0.48, blue: 1.0, alpha: 1.0)
            static let labelColor = DGrayColor
            static let labelColor1 = UIColor.red //DGrayColor
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
        static let navlabel = UIFont.systemFont(ofSize: 25, weight: UIFontWeightMedium)
        static let headtitle = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        static let Edittitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        static let Weathertitle = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        //buttonFontSize,  labelFontSize, systemFontSize
        
        static let celltitle = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        static let cellsubtitle = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
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
            static let newstitle = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            static let newssource = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            static let newslabel1 = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold)
            static let newslabel2 = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        }
        
        struct Snapshot {
            static let celltitle = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        }
    }


// MARK: - RemoveWhiteSpace

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

//-----------youtube---------

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

//-----------youtube---------

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        
        imageUrlString = urlString
        let url = URL(string: urlString)
        image = nil
        
        //check cache for image first
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        //otherwise fire off a new download
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageToCache = UIImage(data: data!)
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
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

/*
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
} */
 
//----------------------------

