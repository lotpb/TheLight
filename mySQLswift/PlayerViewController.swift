//
//  PlayerViewController.swift
//  YTDemo
//
//  Created by Gabriel Theodoropoulos on 27/6/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: YTPlayerView!
    
    var videoID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //playerView.load(videoId: videoID)
        //playerView.load(videoId: videoID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
