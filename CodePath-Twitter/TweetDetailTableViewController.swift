//
//  TweetDetailTableViewController.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/28/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController {

    var tweet: Tweet? = nil
    var tweetRetweeted: Bool = false
    var tweetFavorited: Bool = false
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var textTextView: ActiveLabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton! {
        didSet {
            // Onload bounce buttons
            replyButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 1.0,
                           delay: 0.5,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 10,
                           options: .curveLinear,
                           animations: {
                            self.replyButton.transform = CGAffineTransform.identity
            },
                           completion: nil
            )
        }
    }
    
    @IBOutlet weak var retweetButton: UIButton! {
            didSet {
                let delayInSeconds = 0.3
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    // Onload bounce buttons
                    self.retweetButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                    UIView.animate(withDuration: 1.0,
                                   delay: 0.5,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 10,
                                   options: .curveLinear,
                                   animations: {
                                    self.retweetButton.transform = CGAffineTransform.identity
                    },
                                   completion: nil
                    )
                }
                
                //retweetButton.addTarget(self, action: #selector(tappedRightButton), for: .touchUpInside)
            }
    }
    
    func tappedRightButton() {
        /*
         // Zoom down and up
         retweetButton.transform = CGAffineTransform(scaleX: 0, y: 0)
         UIView.animate(withDuration: 1.0,
         delay: 0.5,
         usingSpringWithDamping: 0.5,
         initialSpringVelocity: 10,
         options: .curveLinear,
         animations: {
         self.retweetButton.transform = CGAffineTransform.identity
         },
         completion: nil
         )
         */
        
        /*
         // Spin around
         retweetButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 6/5))
         UIView.animate(withDuration: 1.0) {
         self.retweetButton.transform = CGAffineTransform.identity
         }
         */
    }

    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            let delayInSeconds = 0.6
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                // Onload bounce buttons
                self.favoriteButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                UIView.animate(withDuration: 1.0,
                               delay: 0.5,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 10,
                               options: .curveLinear,
                               animations: {
                                self.favoriteButton.transform = CGAffineTransform.identity
                },
                               completion: nil
                )
            }
        }
    }
    
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View
        tableView.dataSource = self
        tableView.delegate = self
        
        // Remove the separator inset
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#how-do-you-remove-the-separator-inset
        tableView.separatorInset = UIEdgeInsets.zero
        
        // A little trick for removing the cell separators
        tableView.tableFooterView = UIView()
        
        print("tweet: \(tweet)")

        // Do any additional setup after loading the view.
        
        // Nav heading title
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: "Tweet", attributes: [
            NSFontAttributeName : UIFont(name: "OpenSans", size: 18)!,
            NSForegroundColorAttributeName : UIColor.white
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        // Update UI
        userProfileImageView.setImageWith(tweet!.user!.profileUrl!)
        
        nameLabel.text = tweet?.user?.name
        screenNameLabel.text = tweet?.user?.getScreenName()
        
        textTextView.text = tweet?.text!
        textTextView.numberOfLines = 0
        textTextView.enabledTypes = [.mention, .hashtag, .url]
        textTextView.textColor = .black
        textTextView.handleHashtagTap { hashtag in
            print("Tapped hashtag: \(hashtag) -- TODO: Search using this Hashtag")
            // TODO: Add search using this hashtag
        }
        textTextView.handleURLTap({ (url: URL) in
            print("Tapped URL: \(url)")
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        })
        textTextView.sizeToFit()
        
        timestampLabel.text = tweet?.getDateTimeShort()
        
        retweetCountLabel.text = tweet?.getRetweets(incrementBy: 0)
        favoriteCountLabel.text = tweet?.getLikes(incrementBy: 0)
        
        tweetRetweeted = (tweet?.isRetweeted)!
        tweetFavorited = (tweet?.isFavorited)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Action

    @IBAction func statusReply(_ sender: UIButton) {
        print("statusFavorite")
        
        self.performSegue(withIdentifier: "ComposeTweetSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeTweetSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! ComposeTweetViewController
            
            // Pass data in to act on it
            destinationViewController.tweet = tweet
        }
    }
    
    @IBAction func statusRetweet(_ sender: UIButton) {
        print("statusRetweet")
        
        if tweet?.isRetweeted == true || tweetRetweeted == true {
            sender.bounceAndChange(imageName:"twitter-retweet")
            retweetCountLabel.text = tweet?.getRetweets(incrementBy: 0)
            retweetCountLabel.bounce()
            
            statusUnRetweet()
            
            tweetRetweeted = false
        } else {
            sender.bounceAndChange(imageName:"twitter-retweet-selected")
            retweetCountLabel.text = tweet?.getRetweets(incrementBy: 1)
            retweetCountLabel.bounce()
            
            TwitterClient.sharedInstance.statusRetweet(statusId: (tweet?.identifier)!, success: { (response: NSDictionary) in
                print("TweetDetailTableViewController.statusRetweet: \(response)")
            }, failure: { (error: Error) in
                print("error: \(error)")
            })
            
            tweetRetweeted = true
        }
    }
    
    func statusUnRetweet() {
        print("statusUnRetweet")
        
        var originalTweetIdStr = ""
        if tweet?.retweetedStatusIsEmpty == true {
            originalTweetIdStr = String("\(tweet?.identifier)!")
        } else {
            originalTweetIdStr = (tweet?.retweetedStatusId)!
        }
        
        TwitterClient.sharedInstance.statusUnRetweet(originalTweetId: originalTweetIdStr, success: { (response: NSDictionary) in
            print("TweetDetailTableViewController.statusUnRetweet: \(response)")
        }, failure: { (error: Error) in
            print("error: \(error)")
        })
    }
    
    @IBAction func statusFavorite(_ sender: UIButton) {
        print("statusFavorite")
        
        if tweetFavorited == true {
            sender.bounceAndChange(imageName:"twitter-favorite")
            favoriteCountLabel.text = tweet?.getLikes(incrementBy: 0)
            favoriteCountLabel.bounce()
            
            TwitterClient.sharedInstance.statusUnFavorite(statusId: (tweet?.identifier)!, success: { (response: NSDictionary) in
                print("TweetDetailTableViewController.statusUnFavorite: \(response)")
            }, failure: { (error: Error) in
                print("error: \(error)")
            })
            
            tweetFavorited = false
        } else {
            sender.bounceAndChange(imageName:"twitter-favorite-selected")
            favoriteCountLabel.text = tweet?.getLikes(incrementBy: 1)
            favoriteCountLabel.bounce()
            
            TwitterClient.sharedInstance.statusFavorite(statusId: (tweet?.identifier)!, success: { (response: NSDictionary) in
                print("TweetDetailTableViewController.statusFavorite: \(response)")
            }, failure: { (error: Error) in
                print("error: \(error)")
            })
            
            tweetFavorited = true
        }
    }

}
