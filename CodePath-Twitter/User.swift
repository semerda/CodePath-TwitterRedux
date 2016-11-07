//
//  User.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/27/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var screenName: String?
    var profileUrl: URL?
    var tagline: String?
    // Extended
    var location: String?
    var url: String?
    var followingCount: Int = 0
    var followersCount: Int = 0
    
    var profileBackgroundUrl: URL?
    
    var dictionary: NSDictionary

    // Deserialization: taking a dictionary and populating your properties based on that data
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString { // Compares if nil else sets it
            profileUrl = URL(string: profileUrlString)
        }
        
        tagline = dictionary["description"] as? String
        
        location = dictionary["location"] as? String
        
        let urlString = dictionary["url"] as? String
        if let urlString = urlString { // Compares if nil else sets it
            url = urlString
        }
        
        followingCount = (dictionary["friends_count"] as? Int) ?? 0
        followersCount = (dictionary["followers_count"] as? Int) ?? 0
        
        let profileBackgroundUrlString = dictionary["profile_background_image_url_https"] as? String
        if let profileBackgroundUrlString = profileBackgroundUrlString { // Compares if nil else sets it
            profileBackgroundUrl = URL(string: profileBackgroundUrlString)
        }
    }
    
    static let userDidLogoutNotification = "UserDidLogout"
    
    static var _currentUser: User?
    
    // This is a "Stored property" - space allocated for them vs.
    // Computer property - no storage associated yet
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                // TODO: Store user details in Keychain vs NSDefaults?
                let defaults = UserDefaults.standard
                
                let userData = defaults.object(forKey: "currentUserData") as? NSData
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                    
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary, options: [])
                
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.set(nil, forKey: "currentUserData")
                defaults.removeObject(forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
    
    // MARK: - Helpers
    
    func getScreenName() -> String {
        return String("@\(screenName!)")
    }
    
}
