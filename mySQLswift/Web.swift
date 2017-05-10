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

class Web: UIViewController, SFSafariViewControllerDelegate, WKUIDelegate {
    
    private var webView: WKWebView
    var url: URL?
    
    let siteNames = ["CNN", "Drudge", "cnet", "Appcoda", "Cult of Mac"]
    let siteAddresses = ["http://www.cnn.com",
                      "http://www.Drudgereport.com",
                      "http://www.cnet.com",
                      "http://www.appcoda.com/tutorials/",
                      "http://www.cultofmac.com/category/news/"]
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var recentPostsButton: UIBarButtonItem!
    @IBOutlet weak var safari: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
    }
    
    var detailItem: AnyObject? {
        didSet {
            self.configureWeb()
        }
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
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(backButtonPressed))
        navigationItem.rightBarButtonItems = [actionButton]
        
        self.segControl? = UISegmentedControl(items: siteNames)
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        recentPostsButton.isEnabled = false
        
        webView.allowsBackForwardNavigationGestures = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        setupConstraints()
        configureWeb()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .gray
        //navigationController?.hidesBarsOnSwipe = true
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)

        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.hidesBarsOnSwipe = false
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureWeb() {
        
        if let detail: AnyObject = detailItem {
            webView.load(URLRequest(url:URL(string: detail as! String)!))
        } else {
            webView.load(URLRequest(url:URL(string: siteAddresses[0])!))
        }
    }
    
    func setupConstraints() {

        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        [webView.topAnchor.constraint(equalTo: view.topAnchor),
         webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
         webView.leftAnchor.constraint(equalTo: view.leftAnchor),
         webView.rightAnchor.constraint(equalTo: view.rightAnchor)].forEach  {
            anchor in
            anchor.isActive = true
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "loading") {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //progressView.setProgress(0.0, animated: false)
    }
    
//---------------------------------------------------------------
    
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
    
    @IBAction func didPressButton(_ sender: AnyObject) {
        
        let safariVC = SFSafariViewController(url:URL(string: siteAddresses[0])!, entersReaderIfAvailable: true)
        safariVC.delegate = self
        self.present(safariVC, animated: true)
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
        default:
            break
        }
    }
    /*
    //fix kept producing Error Messages
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    } */

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - NavigationController Hidden
    
    func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state)
        }, completion: nil)
    }
    
}
// MARK: - WKScriptMessageHandler
extension Web: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        print(message.webView as Any)
    }
}
// MARK: - WKNavigationDelegate
extension Web: WKNavigationDelegate {
    
    private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        
        let hostname = (navigationAction.request as NSURLRequest).url?.host?.lowercased()
        if navigationAction.navigationType == .linkActivated && hostname!.contains(siteAddresses[0]) {
            //if navigationAction.navigationType == .linkActivated && !(navigationAction.request as NSURLRequest).url!.host!.lowercased().hasPrefix(siteAddresses[1]) {
            UIApplication.shared.open(navigationAction.request.url!)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
