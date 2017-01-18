//
//  HomeDatasourceController+navbar.swift
//  TwitterLBTA
//
//  Created by Brian Voong on 1/14/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

extension BlogEditController {
    
    func setupEditNavigationBarItems() {
        setupRemainingNavItems()
    }
    
    private func setupRemainingNavItems() {
        
        UIApplication.shared.statusBarStyle = .default
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "title_icon"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleImageView
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        //navigationController?.navigationBar.isTranslucent = false
        
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = Color.twitterBlue
        //tabBarController?.tabBar.isTranslucent = false
    }
}

extension Blog {
    
    func exitNavigationBarItems() {
        exitRemainingNavItems()
    }
    
    func setupNavigationBarItems() {
        setupLeftNavItem()
        setupRightNavItems()
        setupRemainingNavItems()
    }
    
    private func setupRemainingNavItems() {
        
        UIApplication.shared.statusBarStyle = .default
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "title_icon"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleImageView
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        //navigationController?.navigationBar.isTranslucent = false
        
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = Color.twitterBlue
        //tabBarController?.tabBar.isTranslucent = false
    }
    
    private func exitRemainingNavItems() {
        
        UIApplication.shared.statusBarStyle = .lightContent

        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .gray
        navigationController?.navigationBar.backgroundColor = .black
        
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = .white
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
