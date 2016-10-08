//
//  YouTubeController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/17/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//
/*
import UIKit

class YouTubeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tblVideos: UITableView!
    
    @IBOutlet weak var segDisplayedContent: UISegmentedControl!
    
    @IBOutlet weak var viewWait: UIView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    
    var apiKey = "AIzaSyB11hJ5EOIBKeaeRPeRXK5eEA0pYMndcVw"
    
    var desiredChannelsArray = ["lotpb", "Apple", "Google", "Microsoft", "HOWARDTV", "VeaSoftware", "CodeWithChris", "SergeyKargopolov", "Lifehacker", "JimmyKimmelLive", "latenight"]
    
    var channelIndex = 0
    
    var channelsDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var selectedVideoIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblVideos.delegate = self
        tblVideos.dataSource = self
        txtSearch.delegate = self
        
        getChannelDetails(false)
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
        }
        else {
            return videosArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath)
            
            let channelTitleLabel = cell.viewWithTag(10) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
            let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
            
            let channelDetails = channelsDataArray[indexPath.row]
            channelTitleLabel.text = channelDetails["title"] as? String
            channelDescriptionLabel.text = channelDetails["description"] as? String
            thumbnailImageView.image = UIImage(data: try! Data(contentsOf: URL(string: (channelDetails["thumbnail"] as? String)!)!))
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellVideo", for: indexPath)
            
            let videoTitle = cell.viewWithTag(10) as! UILabel
            let videoThumbnail = cell.viewWithTag(11) as! UIImageView
            
            let videoDetails = videosArray[indexPath.row]
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
            // In this case the channels are the displayed content.
            // The videos of the selected channel should be fetched and displayed.
            
            // Switch the segmented control to "Videos".
            segDisplayedContent.selectedSegmentIndex = 1
            
            // Show the activity indicator.
            viewWait.isHidden = false
            
            // Remove all existing video details from the videosArray array.
            videosArray.removeAll(keepingCapacity: false)
            
            // Fetch the video details for the tapped channel.
            getVideosForChannelAtIndex(indexPath.row)
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
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(textField.text)&type=\(type)&key=\(apiKey)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // Create a NSURL object based on the above string.
        let targetURL = URL(string: urlString)
        
        // Get the results.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary object.
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all search result items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Loop through all search results and keep just the necessary data.
                    for i in 0 ..< items.count {
                        let snippetDict = items[i]["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Gather the proper data depending on whether we're searching for channels or for videos.
                        if self.segDisplayedContent.selectedSegmentIndex == 0 {
                            // Keep the channel ID.
                            self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
                        }
                        else {
                            // Create a new dictionary to store the video details.
                            var videoDetailsDict = Dictionary<NSObject, AnyObject>()
                            videoDetailsDict["title"] = snippetDict["title"]
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                            
                            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                            self.videosArray.append(videoDetailsDict)
                            
                            // Reload the tableview.
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
                print("Error while loading channel videos: \(error)")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
        
        
        return true
    }
    
    
    // MARK: Custom method implementation
    
    func performGetRequest(_ targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data, (response ).statusCode, error)
            })
        })
        
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
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                
                do {
                    // Convert the JSON data to a dictionary.
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items: AnyObject! = resultsDict["items"] as AnyObject!
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
                    
                    // Get the snippet dictionary that contains the desired data.
                    let snippetDict = firstItemDict["snippet"] as! Dictionary<NSObject, AnyObject>
                    
                    // Create a new dictionary to store only the values we care about.
                    var desiredValuesDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                    desiredValuesDict["title"] = snippetDict["title"]
                    desiredValuesDict["description"] = snippetDict["description"]
                    desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                    
                    // Save the channel's uploaded videos playlist ID.
                    desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<NSObject, AnyObject>)["relatedPlaylists"] as! Dictionary<NSObject, AnyObject>)["uploads"]
                    
                    
                    // Append the desiredValuesDict dictionary to the following array.
                    self.channelsDataArray.append(desiredValuesDict)
                    
                    
                    // Reload the tableview.
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
                print("Error while loading channel details: \(error)")
            }
        })
    }
    
    
    func getVideosForChannelAtIndex(_ index: Int!) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        
        // Form the request URL string.
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)&maxResults=\(25)"
        
        // Create a NSURL object based on the above string.
        let targetURL = URL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // Convert the JSON data into a dictionary.
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        var desiredPlaylistItemDataDict = Dictionary<NSObject, AnyObject>()
                        
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(desiredPlaylistItemDataDict)
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(error)")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
    }
} */
