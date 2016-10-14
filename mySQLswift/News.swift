//
//  News.swift
//  TheLight
//
//  Created by Peter Balsamo on 7/12/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit


class News: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SearchDelegate {
    
    let cellId = "cellId"
    let trendingCellId = "trendingCellId"
    let subscriptionCellId = "subscriptionCellId"
    let accountCellId = "accountId"
    
    let titles = ["Home", "Trending", "Subscriptions", "Account"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel

        setupCollectionView()
        setupNavBarButtons()
        setupMenuBar()
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(News.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self)
        navigationController?.hidesBarsOnSwipe = false //fix statbar hidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        //self.navigationController?.navigationItem.hidesBackButton = true
        //self.navigationItem.hidesBackButton = true
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = Color.News.navColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCollectionView() {
        
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        self.collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView?.register(TrendingCell.self, forCellWithReuseIdentifier: trendingCellId)
        self.collectionView?.register(SubscriptionCell.self, forCellWithReuseIdentifier: subscriptionCellId)
        self.collectionView?.register(AccountCell.self, forCellWithReuseIdentifier: accountCellId)
        
      //self.collectionView?.register(AccountCollectionViewController.self, forCellWithReuseIdentifier: accountCellId)
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(50,0,0,0)
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50,0,0,0)
        self.collectionView?.backgroundColor = .clear
        //added below
        self.view.addSubview(self.collectionView)
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.isDirectionalLockEnabled = true
        self.collectionView?.bounces = false
        self.collectionView?.showsHorizontalScrollIndicator = false
        
    }
    
    func setupNavBarButtons() {
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(newButton))
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(handleSearch))
        
        navigationItem.rightBarButtonItems = [moreButton,addButton,searchButton]
    }
    
    // MARK: - NavigationController Hidden
    func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
    }

    
    // MARK: - collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 1 {
            identifier = trendingCellId
        } else if indexPath.item == 2 {
            identifier = subscriptionCellId
        } else if indexPath.item == 3 {
            identifier = accountCellId
        } else {
            identifier = cellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) //as! CollectionViewCell

        return cell
    }
    
    
    // MARK: - Button
    
    func newButton(sender: AnyObject) {
        
        self.performSegue(withIdentifier: "uploadSegue", sender: self)
    }

    
    // MARK: - youtube Action Menu
//-------------------------------------------------
    
    lazy var search: Search = {
        let se = Search.init(frame: UIScreen.main.bounds)
        se.delegate = self
        return se
    }()
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    func handleMore() {
        //show menu
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = .white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.homeController = self
        return mb
    }()
    
    func setupMenuBar() {
        
        //navigationController?.hidesBarsOnSwipe = true
        
        let redView = UIView()
        redView.backgroundColor = UIColor.rgb(red: 230, green: 32, blue: 31)
        view.addSubview(redView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: redView)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: redView)
        
        view.addSubview(menuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        setTitleForIndex(index: Int(index))
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        
        let indexPath = IndexPath(item: menuIndex, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        
        setTitleForIndex(index: menuIndex)
    }
    
    func setTitleForIndex(index: Int) {
        
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "\(titles[index])"
        }
    }
    
    func handleSearch() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.search)
            self.search.animate()
        }
        //scrollToMenuIndex(menuIndex: 2)
    }
    
    func hideSearchView(status : Bool){
        if status == true {
            self.search.removeFromSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }


//-------------------------------------------------
    

    // MARK: - Segues
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
            self.performSegue(withIdentifier: "newsdetailSeque", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newsdetailSeque"
        {

            
        }
    } */

}
//-----------------------end------------------------------
