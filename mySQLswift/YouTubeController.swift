//
//  YouTubeController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/17/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit

class YouTubeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tblVideos: UITableView!
    @IBOutlet weak var segDisplayedContent: UISegmentedControl!
    @IBOutlet weak var viewWait: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    var apiKey = "AIzaSyB11hJ5EOIBKeaeRPeRXK5eEA0pYMndcVw"
    
    var desiredChannelsArray = ["lotpb", "Apple", "Google", "Microsoft", "HOWARDTV", "VeaSoftware", "CodeWithChris", "SergeyKargopolov", "Lifehacker", "JimmyKimmelLive", "latenight"]
    
    var channelIndex = 0
    var channelsDataArray: Array<Dictionary<String, AnyObject>> = []
    var videosArray: Array<Dictionary<String, AnyObject>> = []
    var selectedVideoIndex: Int!
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight - YouTube", for: .normal)
        } else {
            button.setTitle("YouTube", for: .normal)
        }
        button.setTitle("Leads", for: .normal)
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        tblVideos.delegate = self
        tblVideos.dataSource = self
        txtSearch.delegate = self
        
        getChannelDetails(false)
        self.segDisplayedContent.apportionsSegmentWidthsByContent = true
        self.navigationItem.titleView = self.titleButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "idSeguePlayer" {
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.videoID = videosArray[selectedVideoIndex]["videoID"] as! String
        } 
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func changeContent(_ sender: AnyObject) {
        tblVideos.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    
    // MARK: UITableView method implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            return channelsDataArray.count
        } else {
            return videosArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell!
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath)
            
            let channelTitleLabel = cell.viewWithTag(10) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
            let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                channelDescriptionLabel.font = Font.Snapshot.cellLabel
            }
            
            let channelDetails = channelsDataArray[indexPath.row] as NSDictionary
            channelTitleLabel.text = channelDetails["title"] as? String
            channelDescriptionLabel.text = channelDetails["description"] as? String
            thumbnailImageView.image = UIImage(data: try! Data(contentsOf: URL(string: (channelDetails["thumbnail"] as? String)!)!))
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellVideo", for: indexPath)
            
            let videoTitle = cell.viewWithTag(10) as! UILabel
            let videoThumbnail = cell.viewWithTag(11) as! UIImageView
            
            let videoDetails = videosArray[indexPath.row] as NSDictionary
            videoTitle.text = videoDetails["title"] as? String
            videoThumbnail.image = UIImage(data: try! Data(contentsOf: URL(string: (videoDetails["thumbnail"] as? String)!)!))
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            
            segDisplayedContent.selectedSegmentIndex = 1
            viewWait.isHidden = false
            videosArray.removeAll(keepingCapacity: false)
            getVideosForChannelAtIndex(index: indexPath.row)
        }
        else {
            selectedVideoIndex = indexPath.row
            performSegue(withIdentifier: "idSeguePlayer", sender: self)
        }
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        viewWait.isHidden = false
        
        // Specify the search type (channel, video).
        var type = "channel"
        if segDisplayedContent.selectedSegmentIndex == 1 {
            type = "video"
            videosArray.removeAll(keepingCapacity: false)
        }
        
        // Form the request URL string.
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(String(describing: textField.text))&type=\(type)&key=\(apiKey)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // Create a NSURL object based on the above string.
        let targetURL = URL(string: urlString)
        
        // Get the results.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error)  in
            if HTTPStatusCode == 200, error == nil {
                // Convert the JSON data to a dictionary object.
                do {
  
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    
                    // Get all search result items ("items" array).
                   let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    // Loop through all search results and keep just the necessary data.
                    for i in 0 ..< items.count {
                        let snippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        // Gather the proper data depending on whether we're searching for channels or for videos.
                        if self.segDisplayedContent.selectedSegmentIndex == 0 {
                            // Keep the channel ID.
                            self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
                        }
                        else {
                            // Create a new dictionary to store the video details.
                            var videoDetailsDict = Dictionary<String, AnyObject>()
                            videoDetailsDict["title"] = snippetDict["title"]
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<String, AnyObject>)["videoId"]
                            
                            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                            self.videosArray.append(videoDetailsDict as [String : AnyObject])
   
                            self.tblVideos.reloadData()
                        }
                    }
                } catch {
                    print(error)
                }
                
                // Call the getChannelDetails(…) function to fetch the channels.
                if self.segDisplayedContent.selectedSegmentIndex == 0 {
                    self.getChannelDetails(true)
                }
                
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error crap while loading channel videos: \(String(describing: error))")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
        
        return true
    }
    
    
    // MARK: Custom method implementation
    
    func performGetRequest(_ targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: NSError?) -> Void) {
        
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request) { data, response, error in DispatchQueue.main.async { completion(data, (response as! HTTPURLResponse).statusCode, error as NSError?) } }
        
        task.resume()
        
    }

    
    func getChannelDetails(_ useChannelIDParam: Bool) {
        
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        else {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        
        let targetURL = URL(string: urlString)
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error)  in
            if HTTPStatusCode == 200, error == nil {
                
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>

                    let items: AnyObject! = resultsDict["items"] as AnyObject!
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<String, AnyObject>

                    let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
 
                    var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                    desiredValuesDict["title"] = snippetDict["title"]
                    desiredValuesDict["description"] = snippetDict["description"]
                    desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]

                    desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]

                    self.channelsDataArray.append(desiredValuesDict as [String : AnyObject])

                    self.tblVideos.reloadData()
                    
                    // Load the next channel data (if exist).
                    self.channelIndex += 1
                    if self.channelIndex < self.desiredChannelsArray.count {
                        self.getChannelDetails(useChannelIDParam)
                    }
                    else {
                        self.viewWait.isHidden = true
                    }
                } catch {
                    print(error)
                }
                
            } else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(String(describing: error))")
            }
        })
    }
    
    func getVideosForChannelAtIndex(index: Int!) {
        //added &maxResults=10 to get 10 videos in statement below
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=20&playlistId=\(playlistID)&key=\(apiKey)"
        
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL as URL!, completion: { (data, HTTPStatusCode, error)  in
            if HTTPStatusCode == 200, error == nil {
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
    
                    let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                        
                        self.videosArray.append(desiredPlaylistItemDataDict )
                        
                        self.tblVideos.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(String(describing: error))")
            }
            self.viewWait.isHidden = true
        })
    }

}
