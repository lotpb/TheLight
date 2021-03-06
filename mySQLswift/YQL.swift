//
//  YQL.swift
//  YQLSwift
//
//  Created by Jake Lee on 1/25/15.
//  Copyright (c) 2015 JHL. All rights reserved.
//

import Foundation

struct YQL {
    
    // Yahoo finance query string
    private static let prefix:NSString = "http://query.yahooapis.com/v1/public/yql?&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=&q="
    
    static func query(statement:String) -> NSDictionary? {
        
        // update query to contain symbol of stock to search on
        let escapedStatement = statement.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let query = "\(prefix)\(escapedStatement!)"
        
        var results:NSDictionary? = nil
        var jsonError:NSError? = nil
        var jsonDataError:NSError? = nil
        
        let jsonData: Data?
        do {
            jsonData = try Data(contentsOf: URL(string: query)!, options: NSData.ReadingOptions.mappedIfSafe)
        } catch let error as NSError {
            jsonError = error
            jsonData = nil
        }
        
        if jsonData != nil {
            
            do {
                results = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
            }
            catch let error as NSError {
                results = nil
                jsonDataError = error
            }
        }
        if jsonError != nil || jsonDataError != nil{
            NSLog( "ERROR while fetching/deserializing YQL data. Message \(jsonError!)" )
        }
        return results
    }
    
}
