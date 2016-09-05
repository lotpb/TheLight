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
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var recentPostsButton: UIBarButtonItem!
    @IBOutlet weak var safari: UIBarButtonItem!
  
    required init?(coder aDecoder: NSCoder) {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        //webView.addObserver(self, forKeyPath: "title", options: .New, context: nil) //removes title on tabBar

        webView.load(URLRequest(url:URL(string:"http://www.cnn.com")!))
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        recentPostsButton.isEnabled = false 
        
}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<()>?) {
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
   
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if (navigationAction.navigationType == WKNavigationType.linkActivated && !(navigationAction.request as NSURLRequest).url!.host!.lowercased().hasPrefix("www.drudgereport.com")) {
            UIApplication.shared.openURL(navigationAction.request.url!)
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    
//---------------------------------------------------------------
    
    
    @IBAction func didPressButton(_ sender: AnyObject) {
        
        let safariVC = SFSafariViewController(url:URL(string: "http://www.cnn.com")!, entersReaderIfAvailable: true) // Set to false if not interested in using reader
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    
    @IBAction func WebTypeChanged(_ sender : UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
             url = URL(string:"http://www.cnn.com")!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 1:
             url = URL(string:"http://www.Drudgereport.com")!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 2:
             url = URL(string:"http://www.cnet.com")!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 3:
            url = URL(string:"http://lotpb.github.io/UnitedWebPage/index.html")!
            let request = URLRequest(url: url!)
            webView.load(request)
        case 4:
            url = URL(string:"http://finance.yahoo.com/mb/UPL/")!
            let request = URLRequest(url: url!)
            webView.load(request)
        case 5:
            url = URL(string:"http://stocktwits.com/The_Stock_Whisperer")!
            let request = URLRequest(url: url!)
            webView.load(request)
        default:
            break
        }
    }

    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}