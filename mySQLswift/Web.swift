//
//  Web.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/9/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class Web: UIViewController, SFSafariViewControllerDelegate, WKNavigationDelegate {
    
    private var webView: WKWebView
    var url: URL?
    
    let siteNames: Array<String> = ["CNN", "Drudge", "cnet", "Appcoda", "Cult of Mac", "Twits"]
    let siteAddresses: Array<String> = ["http://www.cnn.com",
                      "http://www.Drudgereport.com",
                      "http://www.cnet.com",
                      "http://www.appcoda.com/tutorials/",
                      "http://www.cultofmac.com/category/news/",
                      "http://stocktwits.com/The_Stock_Whisperer"]
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var recentPostsButton: UIBarButtonItem!
    @IBOutlet weak var safari: UIBarButtonItem!
    @IBOutlet weak var segControl: UISegmentedControl!

    
    required init?(coder aDecoder: NSCoder) {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView
        self.splitViewController?.maximumPrimaryColumnWidth = 300
        self.splitViewController!.preferredDisplayMode = .primaryHidden
        //fix - remove bottom bar
        self.extendedLayoutIncludesOpaqueBars = true
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        self.segControl? = UISegmentedControl(items: siteNames)
        
        view.insertSubview(webView, belowSubview: progressView)
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        recentPostsButton.isEnabled = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        //webView.addObserver(self, forKeyPath: "title", options: .New, context: nil) //removes title on tabBar
        //webView.load(URLRequest(url:URL(string: siteAddresses[0])!))
        
        self.configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        //changes segmented color
        self.navigationController?.navigationBar.tintColor = .white
        //self.navigationController?.navigationBar.barTintColor = Color.Lead.navColor
        //webView.load(URLRequest(url:URL(string: siteAddresses[0])!))
        //self.configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: AnyObject? {
        didSet {
            //print(detailItem!)
            self.configureView()
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonPressed(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        let request = URLRequest(url:webView.url!)
        webView.load(request)
    }
    

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if (keyPath == "title") {
            title = webView.title
        }
    } 
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
   
    private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if (navigationAction.navigationType == WKNavigationType.linkActivated && !(navigationAction.request as NSURLRequest).url!.host!.lowercased().hasPrefix(siteAddresses[1])) {
            
            UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    
//---------------------------------------------------------------
    
    
    @IBAction func didPressButton(_ sender: AnyObject) {
        
        let safariVC = SFSafariViewController(url:URL(string: siteAddresses[0])!, entersReaderIfAvailable: true) // Set to false if not interested in using reader
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    
    @IBAction func WebTypeChanged(_ sender : UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
             url = URL(string: siteAddresses[0])!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 1:
             url = URL(string: siteAddresses[1])!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 2:
             url = URL(string: siteAddresses[2])!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 3:
            url = URL(string: siteAddresses[3])!
            let request = URLRequest(url: url!)
            webView.load(request)
        case 4:
            url = URL(string: siteAddresses[4])!
            let request = URLRequest(url: url!)
            webView.load(request)
        case 5:
            url = URL(string: siteAddresses[5])!
            let request = URLRequest(url: url!)
            webView.load(request)
        default:
            break
        }
    }
    
    func configureView() {
        
        if let detail = self.detailItem {
            
            webView.load(URLRequest(url:URL(string: detail as! String)!))
            /*
            url = URL(string: detail as String)
            let request = URLRequest(url: url!)
            webView.load(request) */
        } else {
       
           webView.load(URLRequest(url:URL(string: siteAddresses[0])!)) 
        }

        //webView.load(URLRequest(url: URL(string: detailItem as! String)!))
    }
 
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
