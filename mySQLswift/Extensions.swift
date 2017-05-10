//
//  Constants.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 2/9/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

// MARK:, // TODO: and // FIXME:
import UIKit

var searchController: UISearchController!

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
        static let youtubeRed = UIColor.rgb(red: 230, green: 32, blue: 31)
        static let twitterBlue = UIColor.rgb(red: 61, green: 167, blue: 244)
        static let twitterText = UIColor(red:0.54, green:0.60, blue:0.65, alpha: 1.0)
        static let twitterline = UIColor.rgb(red: 230, green: 230, blue: 230)
        static let facebookBlue = UIColor.rgb(red: 0, green: 137, blue: 249)
        static let goldColor = UIColor(red:0.76, green:0.57, blue:0.27, alpha: 1.0)
        
        enum Header {
            static let headtextColor = Color.goldColor
        }
        
        enum Blog {
            static let navColor = Color.twitterBlue
            //static let borderbtnColor = Color.LGrayColor.cgColor
            static let borderColor = Color.goldColor
            static let buttonColor = Color.twitterBlue
            static let weblinkText = Color.twitterBlue
            static let emaillinkText = UIColor.red
            static let phonelinkText = UIColor.green
        }
        enum Lead {
            static let navColor = UIColor.black
            static let labelColor = Color.DGrayColor
            static let labelColor1 = UIColor.red
            static let buttonColor = UIColor.red
        }
        
        enum Cust {
            static let navColor = UIColor.black
            static let labelColor = Color.DGrayColor
            static let labelColor1 = Color.BlueColor
            static let buttonColor = Color.BlueColor
        }
        
        enum Vend {
            static let navColor = UIColor.black
            static let labelColor = UIColor(red: 0.56, green: 0.45, blue: 0.62, alpha: 1.0)
            static let buttonColor = UIColor(red: 0.56, green: 0.45, blue: 0.62, alpha: 1.0)
        }
        
        enum Employ {
            static let navColor = UIColor.black
            static let labelColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
            static let buttonColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
        }
        
        enum News {
            static let navColor = Color.youtubeRed
            static let buttonColor = Color.BlueColor
        }
        
        enum Stat {
            static let navColor = UIColor.red
        }
        
        enum Snap {
            static let tablebackColor = UIColor.black
            static let collectbackColor = UIColor(white:0.25, alpha:1.0)
            static let textColor = UIColor.white
            static let textColor1 = UIColor.lightGray
            static let lineColor = UIColor.darkGray
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
   //buttonFontSize,  labelFontSize, systemFontSize
    */

    struct Font {
        
        static let celltitle60r = UIFont.systemFont(ofSize: 60)
        
        static let celltitle36r = UIFont.systemFont(ofSize: 36)
        
        static let celltitle30r = UIFont.systemFont(ofSize: 30)
        static let celltitle30l = UIFont.systemFont(ofSize: 30, weight: UIFontWeightLight)
        
        static let navlabel = UIFont(name: "HelveticaNeue-Thin", size: 25.0)
        
        static let celltitle26r = UIFont.systemFont(ofSize: 26)
        static let celltitle26l = UIFont.systemFont(ofSize: 26, weight: UIFontWeightLight)
        
        static let celltitle24l = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        
        static let celltitle22m = UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
        static let celltitle22r = UIFont.systemFont(ofSize: 22)
        static let celltitle22l = UIFont.systemFont(ofSize: 22, weight: UIFontWeightLight)
        
        static let celltitle20b = UIFont.boldSystemFont(ofSize: 20)
        static let celltitle20m = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        static let celltitle20r = UIFont.systemFont(ofSize: 20)
        static let celltitle20l = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        
        static let celltitle18b = UIFont.boldSystemFont(ofSize: 18)
        static let celltitle18m = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        static let celltitle18r = UIFont.systemFont(ofSize: 18)
        static let celltitle18l = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        
        static let celltitle16b = UIFont.boldSystemFont(ofSize: 16)
        static let celltitle16r = UIFont.systemFont(ofSize: 16)
        static let celltitle16l = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
        
        static let celltitle14m = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        static let celltitle14r = UIFont.systemFont(ofSize: 14)
        static let celltitle14l = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        
        static let celltitle12b = UIFont.boldSystemFont(ofSize: 12)
        static let celltitle12r = UIFont.systemFont(ofSize: 12)
        static let celltitle12l = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        
        struct Blog {
            
            static let celltitlePad = Font.celltitle22m
            static let cellsubtitlePad = Font.celltitle22r
            static let celldatePad = Font.celltitle18l
            
            static let celltitle = celltitle18b
            static let celldate = Font.celltitle16r
            static let cellLabel = celltitle18b
            static let cellsubject = Font.celltitle20l
        }
        
        struct BlogEdit {
            static let replytitlePad = celltitle18b
            static let replysubtitlePad = Font.celltitle18l
            
            static let replytitle = Font.celltitle16b
            static let replysubtitle = Font.celltitle16l
        }
        
        struct News {
            static let newstitlePad = celltitle26r
            static let newssourcePad = Font.celltitle20r
            static let newslabel1Pad = celltitle18b
            static let newslabel2Pad = Font.celltitle18r
            
            static let newstitle = Font.celltitle18r
            static let newssource = Font.celltitle16l
            static let newslabel1 = celltitle16b
            static let newslabel2 = Font.celltitle14l
        }
        
        struct Snapshot {
            static let celltitlePad = celltitle26l
            static let cellsubtitlePad = celltitle22r
            static let celllabelPad = Font.celltitle18r
            static let cellLabel = celltitle14r
        }
        
        struct Stat {
            static let celltitlePad = celltitle20m
        }
        
        struct Detail {
            static let ipadname = celltitle30l
            static let ipadAmount = celltitle60r
            static let ipaddate = Font.celltitle18r
            static let ipadaddress = celltitle26l
            
            static let textname = celltitle24l
            static let textdate = Font.celltitle16r
            static let textaddress = Font.celltitle20r
            static let textAmount = celltitle30r
            
            static let Vtextname = Font.celltitle18l
            static let Vtextdate = Font.celltitle12r
            static let VtextAmount = celltitle20m
            
            static let celltitlePad = celltitle16b
            static let cellsubtitlePad = Font.celltitle16l
            static let celltitle = celltitle12b
            static let cellsubtitle = Font.celltitle12l
            
            static let ipadnewstitle = celltitle20b
            static let ipadnewssubtitle = Font.celltitle18l
            static let ipadnewsdetail = Font.celltitle18r
            
            static let newstitle = celltitle18b
            static let newssubtitle = Font.celltitle16l
            static let newsdetail = Font.celltitle16r
            
            static let textbutton = Font.celltitle18r
        }
    }

// MARK: - PlayVC, NavVC

enum stateOfVC {
    case minimized
    case fullScreen
    case hidden
}

enum Direction {
    case up
    case left
    case none
}


// MARK: - all RemoveWhiteSpace  //BlogEdit

public extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
// MARK: - begin and ends RemoveWhiteSpace  //EditData

public extension String {
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

// MARK: - AlertController

public extension UIViewController {
    
    func simpleAlert(title:String?, message:String?) { //withTitle:
 
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
}

//--------------News youtube------------

extension UIColor { //youtube red
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

// UIImage with downloadable content
extension UIImage {
    class  func contentOfURL(link: String) -> UIImage {
        let url = URL.init(string: link)!
        var image = UIImage()
        do {
            let data = try Data.init(contentsOf: url)
            image = UIImage.init(data: data)!
        } catch _ {
            print("error downloading images")
        }
        return image
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

// MARK: - Scroll to top TableView
extension UITableView {
    func scrollToTop(animated: Bool) {
        setContentOffset(.zero, animated: animated)
    }
}


// MARK: - detect a URL in a String using NSDataDetector
extension NSRange {
    //NSRange rather than a Swift string range.
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
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
        
        URLSession.shared.dataTask(with: url!, completionHandler: { [weak self] (data, response, error) in
            if error != nil {
                return
            }

            DispatchQueue.main.async(execute: {
                let imageToCache = UIImage(data: data!)
                if self?.imageUrlString == urlString {
                    self?.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            })
        }).resume()
    }
}

//declared in News search
func requestSuggestionsURL(text: String) -> URL {
    let netText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet())!
    let url = URL.init(string: "https://api.bing.com/osjson.aspx?query=\(netText)")!
    return url
}

//------------------------------------

public extension UISearchBarDelegate {
    
    func searchButton(_ sender: AnyObject) {
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.showsBookmarkButton = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = true
    }
}

//valid email
public extension String {
    
    var isValidEmailAddress: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let linkDetector = try? NSDataDetector(types: types.rawValue)
        let range = NSRange(location: 0, length: self.characters.count)
        let result = linkDetector?.firstMatch(in: self, options: .reportCompletion, range: range)
        let scheme = result?.url?.scheme ?? ""
        return scheme == "mailto" && result?.range.length == self.characters.count
    }
}
//hide TabBar
extension UITabBarController {
    
    func hideTabBarAnimated(hide:Bool) {
        UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            if hide {
                self.tabBar.transform = CGAffineTransform(translationX: 0, y: 50)
            } else {
                self.tabBar.transform = CGAffineTransform.identity
            }
        })
    }
}


