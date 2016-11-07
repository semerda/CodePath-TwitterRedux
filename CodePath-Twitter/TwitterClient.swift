//
//  TwitterClient.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/27/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!,
                                              consumerKey: "Coagf8bM9fGx0xVuIEh8zb4x4",
                                              consumerSecret: "8Kp5rIkiaGTmtxBsCh6bdoxcdVIHa6vFkhywkhCvsqMFXf5VwO")!
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    
    func login(success: @escaping ()->(), failure: @escaping (Error)->()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "https://api.twitter.com/oauth/request_token",
                          method: "GET",
                          callbackURL: URL(string: "twitterdemo://oauth"),
                          scope: nil,
                          success: { (requestToken: BDBOAuth1Credential?) -> Void in
                            let token = requestToken?.token!
                            print("requestToken: \(token!)")
                            
                            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token!)")
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url!)
                            }
                            
            }, failure: { (error: Error?) -> Void in
                print("error: \(error?.localizedDescription)")
                
                self.loginFailure?(error!)
        })
    }
    
    func logout() {
        User.currentUser = nil
        
        deauthorize()
        
        // User.userDidLogoutNotification is located in User object -- this way we don't mess up naming it anywhere else
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token",
                         method: "POST",
                         requestToken: requestToken,
                         success: { (accessToken: BDBOAuth1Credential?) -> Void in
                            print("I got the access token!");
                            
                            self.currentAccount(success: { (user: User) in
                                User.currentUser = user
                                self.loginSuccess?()
                            }, failure: { (error: Error) in
                                self.loginFailure?(error)
                            })
                            
                            /*
                            homeTimeline(success: { (tweets: [Tweet]) -> () in
                                for tweet in tweets {
                                    print(tweet.text)
                                }
                                }, failure: { (error: Error) -> () in
                                    print(error.localizedDescription)
                            })
                            */
                            //client.currentAccount()
                            
        }) { (error: Error?) -> Void in
            print("error: \(error?.localizedDescription)")
            
            self.loginFailure?(error!)
        }
    }
    
    func homeTimeline(maxId: Int, success: @escaping ([Tweet])->(), failure: @escaping (Error)->()) {
        // https://dev.twitter.com/rest/reference/get/statuses/home_timeline
        // Handle infinity scroll
        var url = "1.1/statuses/home_timeline.json"
        if maxId > 0 {
            url = String("\(url)?max_id=\(maxId)")
        }
        get(url, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("homeTimeline.response: \(response)")
            
            let tweetDictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetDictionaries)
            //for tweet in tweets {
            //    print("\(tweet.text!)")
            //}
            
            success(tweets)
            
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
        })
    }
    
    func mentionsTimeline(maxId: Int, success: @escaping ([Tweet])->(), failure: @escaping (Error)->()) {
        // https://dev.twitter.com/rest/reference/get/statuses/mentions_timeline
        // Handle infinity scroll
        var url = "1.1/statuses/mentions_timeline.json"
        if maxId > 0 {
            url = String("\(url)?max_id=\(maxId)")
        }
        get(url, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("mentionsTimeline.response: \(response)")
            
            let tweetDictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetDictionaries)
            //for tweet in tweets {
            //    print("\(tweet.text!)")
            //}
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) ->()) {
        // https://dev.twitter.com/rest/reference/get/account/verify_credentials
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("currentAccount.response: \(response)")
            
            let userDictionary = response as! NSDictionary
            print("userDictionary: \(userDictionary)")
            
            let user = User(dictionary: userDictionary)
            success(user)
            
            print("name: \(user.name)")
            print("screen_name: \(user.screenName)")
            print("profile_image_url_https: \(user.profileUrl)")
            print("description: \(user.description)")
            
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
        })
    }
    
    func updateStatus(status: String, inReplyToStatusId: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) ->()) {
        // https://dev.twitter.com/rest/reference/post/statuses/update
        
        // Only when replying we push status id of the tweet (note it must also include orig author @handle in the tweet)
        var parameters: Dictionary<String, Any>! = Dictionary()
        if inReplyToStatusId != 0 {
            parameters["in_reply_to_status_id"] = inReplyToStatusId
        }
        
        post("1.1/statuses/update.json?status=\(status)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("updateStatus.response: \(response)")
            
            success(response as! NSDictionary)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func statusRetweet(statusId: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) ->()) {
        // https://dev.twitter.com/rest/reference/post/statuses/retweet/id
        post("1.1/statuses/retweet/\(statusId).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("statusRetweet.response: \(response)")
            
            success(response as! NSDictionary)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func statusUnRetweet(originalTweetId: String, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) ->()) {
        // https://courses.codepath.com/courses/intro_to_ios/pages/unretweeting
        
        let url: String = "1.1/statuses/show/\(originalTweetId).json?include_my_retweet=1"
        print("statusUnRetweet.url: \(url)")
        get(url, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("originalTweetId.response: \(response)")
            
            let responseDict = response as! NSDictionary
            let retweetId = responseDict["id_str"] as! String
            
            let url2: String = "1.1/statuses/destroy/\(retweetId).json"
            print("statusUnRetweet.url2: \(url2)")
            self.post(url2, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
                print("retweet_id.response: \(response)")
                
                success(response as! NSDictionary)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
            })
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func statusFavorite(statusId: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) ->()) {
        // https://dev.twitter.com/rest/reference/post/statuses/retweet/id
        post("1.1/favorites/create.json?id=\(statusId)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("statusFavorite.response: \(response)")
            
            success(response as! NSDictionary)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func statusUnFavorite(statusId: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) ->()) {
        // https://dev.twitter.com/rest/reference/post/statuses/retweet/id
        post("1.1/favorites/destroy.json?id=\(statusId)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("statusUnFavorite.response: \(response)")
            
            success(response as! NSDictionary)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func userTimeline(screenName: String, success: @escaping ([Tweet])->(), failure: @escaping (Error)->()) {
        // https://dev.twitter.com/rest/reference/get/statuses/user_timeline
        var url = "1.1/statuses/user_timeline.json"
        if screenName.characters.count > 0 {
            url = String("\(url)?screen_name=\(screenName)")
        }
        get(url, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("userTimeline.response: \(response)")
            
            let tweetDictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetDictionaries)
            //for tweet in tweets {
            //    print("\(tweet.text!)")
            //}
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
}
