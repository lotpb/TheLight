//
//  News.swift
//  TheLight
//
//  Created by Peter Balsamo on 7/12/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit


class News: UICollectionViewController, UICollectionViewDelegateFlowLayout, SearchDelegate {
    
    let cellId = "cellId"
    let trendingCellId = "trendingCellId"
    let subscriptionCellId = "subscriptionCellId"
    let accountCellId = "accountId"
    
    let titles = ["Home", "Trending", "Subscriptions", "Account"]
    
    var searchController: UISearchController!
    var resultsController: UITableViewController!
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "  Home"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.navigationBar.isTranslucent = false

        self.titleLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: self.view.frame.height)
        navigationItem.titleView = self.titleLabel

        setupCollectionView()
        setupMenuBar()
        setupNavigationButtons() 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(News.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        setupNewsNavigationItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        collectionView?.backgroundColor = .white
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(TrendingCell.self, forCellWithReuseIdentifier: trendingCellId)
        collectionView?.register(SubscriptionCell.self, forCellWithReuseIdentifier: subscriptionCellId)
        collectionView?.register(AccountCell.self, forCellWithReuseIdentifier: accountCellId)
        
        collectionView?.contentInset = UIEdgeInsetsMake(50,0,0,0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50,0,0,0)
        
        //added below
        self.view.addSubview(collectionView!)
        collectionView?.isPagingEnabled = true
        collectionView?.isDirectionalLockEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    func setupNavigationButtons() {
        
        let moreButton = UIBarButtonItem(image:#imageLiteral(resourceName: "nav_more_icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleMore))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(newButton))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(handleSearch))
        navigationItem.rightBarButtonItems = [moreButton,searchButton,addButton]
    }
    
    // MARK: - NavigationController Hidden
    
    func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
    }
    
    
    // MARK: - collectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
        
        let redView = UIView()
        if UI_USER_INTERFACE_IDIOM() == .pad {
            redView.backgroundColor = .black
        } else {
            redView.backgroundColor = UIColor.rgb(red: 230, green: 32, blue: 31)
        }
        view.addSubview(redView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: redView)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: redView)
        
        view.addSubview(menuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
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
    }
    
    
    func hideSearchView(status : Bool){
        if status == true {
            self.search.removeFromSuperview()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    //--------------end youtube Menu-------------------
    
    //handle Landscape and Portrait Orientation
    /* //code crashes on startup
     override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
     //super.willTransition(to: newCollection, with: coordinator)
     
     collectionView.collectionViewLayout.invalidateLayout()
     
     let indexPath = IndexPath(item: 0, section: 0)
     //scroll to indexPath after the rotation is going
     DispatchQueue.main.async {
     self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
     self.collectionView.reloadData()
     }
     } */
    
}

//-----------------------end------------------------------
