//
//  Tweet.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/27/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var identifier: Int = 0
    
    var user: User?
    
    var text: String?
    var timestamp: NSDate? = Date() as NSDate
    
    var isRetweeted: Bool = false
    var retweetedStatusIsEmpty: Bool = true
    var retweetedStatusId: String = ""
    var isFavorited: Bool = false
    
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    
    // Deserialization: taking a dictionary and populating your properties based on that data
    init(dictionary: NSDictionary) {
        identifier = (dictionary["id"] as? Int) ?? 0
        
        text = dictionary["text"] as? String
        
        if dictionary["created_at"] != nil {
            let timestampString = dictionary["created_at"] as? String
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MM d HH:mm:ss Z y"
            if let timestampString = timestampString { // Compares if nil else sets it
                timestamp = formatter.date(from: timestampString) as NSDate?
            }
        }
        
        // current_user used to push existing user into the Model Tweet
        if dictionary["user"] == nil {
            user = User.currentUser
        } else {
            isRetweeted = (dictionary["retweeted"] as? Bool)!
            if let retweetedStatusDict = dictionary["retweeted_status"] as? NSDictionary {
                retweetedStatusIsEmpty = false
                retweetedStatusId = retweetedStatusDict["id_str"] as! String
            }
            isFavorited = (dictionary["favorited"] as? Bool)!
            
            retweetCount = (dictionary["retweet_count"] as? Int) ?? 0 // If this doesnt exist then set it to 0 since nil on Int is invalid
            favoriteCount = (dictionary["favourite_count"] as? Int) ?? 0
            
            user = User.init(dictionary: dictionary.value(forKey: "user") as! NSDictionary)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]() // empty array
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            
            tweets.append(tweet)
        }
        
        return tweets
    }
    
    // MARK: - Helpers
    
    func getTimeAgo() -> String {
        return String("\(Date().offset(from: timestamp! as Date))")
    }
    
    func getDateTimeShort() -> String {
        // eg. "December 25, 2016 at 7:00:00 AM"
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .medium
        
        let dateString = formatter.string(from: timestamp as! Date)
        
        return dateString
    }
    
    func getRetweets(incrementBy: Int) -> String {
        let newRetweetCount: Int = retweetCount + incrementBy
        let plural: String = newRetweetCount > 1 ? "S" : ""
        return String("\(newRetweetCount) RETWEET\(plural)")
    }
    
    func getLikes(incrementBy: Int) -> String {
        let newLikeCount: Int = favoriteCount + incrementBy
        let plural: String = newLikeCount > 1 ? "S" : ""
        return String("\(newLikeCount) LIKE\(plural)")
    }

}
