//
//  HomeDatasourceController+navbar.swift
//  TwitterLBTA
//
//  Created by Brian Voong on 1/14/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit


extension Blog {
    
    func setupNavigationBarItems() {
        setupLeftNavItem()
        setupRightNavItems()
    }
    
    private func setupLeftNavItem() {
        let followButton = UIButton(type: .system)
        followButton.setImage(#imageLiteral(resourceName: "follow").withRenderingMode(.alwaysOriginal), for: .normal)
        followButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: followButton)
    }
    
    private func setupRightNavItems() {
        let searchButton = UIButton(type: .system)
        searchButton.setImage(#imageLiteral(resourceName: "search").withRenderingMode(.alwaysOriginal), for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let composeButton = UIButton(type: .system)
        composeButton.setImage(#imageLiteral(resourceName: "compose").withRenderingMode(.alwaysOriginal), for: .normal)
        composeButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: composeButton), UIBarButtonItem(customView: searchButton)]
    }
}

public extension UIViewController {
    
    func setupTwitterNavigationBarItems() {
        setupTwitterNavItems()
    }
    
    func setupNewsNavigationItems() {
        setupNewsNavigationBarItems()
    }
    
    func setMainNavItems() {
        
        UIApplication.shared.statusBarStyle = .lightContent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .black
        }
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .gray
        navigationController?.navigationBar.backgroundColor = .black
        //navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = .white
    }
    
    private func setupNewsNavigationBarItems() {
        
        UIApplication.shared.statusBarStyle = .lightContent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                statusBar.backgroundColor = .black
                navigationController?.navigationBar.barTintColor = .black
            } else {
                statusBar.backgroundColor = Color.News.navColor
                navigationController?.navigationBar.barTintColor = Color.News.navColor
            }
        }
        
        //navigationController?.navigationBar.barTintColor = Color.News.navColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = .white
    }
    
    private func setupTwitterNavItems() {
        
        UIApplication.shared.statusBarStyle = .default
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .white
        }
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "title_icon"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Color.twitterBlue
        navigationController?.navigationBar.backgroundColor = .white
        
        let separatorLineView1 = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
        separatorLineView1.backgroundColor = Color.twitterline
        view.addSubview(separatorLineView1)
        
        //remove navbar line
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = Color.twitterBlue
    }
}
