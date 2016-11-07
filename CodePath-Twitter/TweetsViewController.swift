//
//  TweetsViewController.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/26/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

protocol WriteTweetBackDelegate {
    func addNewTweet(newTweet: Tweet)
}

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WriteTweetBackDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]! = []
    
    // Refresh Control -- if using TableViewController then this is not needed because it's already embedded into UITableView
    let refreshControl = UIRefreshControl()
    
    // Infinity Load
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var headTweetId: Int = 0
    
    var isHome: Bool = true
    var vcTitle: String = "Home"
    
    @IBOutlet weak var composeBarButton: UIBarButtonItem! {
        didSet {
            let icon = UIImage(named: "twitter-compose")
            let iconSize = CGRect(origin: CGPoint.zero, size: icon!.size)
            let iconButton = UIButton(frame: iconSize)
            iconButton.setBackgroundImage(icon, for: .normal)
            composeBarButton.customView = iconButton
            composeBarButton.customView!.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            UIView.animate(withDuration: 1.0,
                                       delay: 0.5,
                                       usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 10,
                                       options: .curveLinear,
                                       animations: {
                                        self.composeBarButton.customView!.transform = CGAffineTransform.identity
            },
                                       completion: nil
            )
            
            iconButton.addTarget(self, action: #selector(composeTweet(_:)), for: .touchUpInside)
        }
    }
    
    func tappedRightButton(){
        composeBarButton.customView!.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 6/5))
        UIView.animate(withDuration: 1.0) {
            self.composeBarButton.customView!.transform = CGAffineTransform.identity
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.backgroundColor = UIColor(netHex:0x63a9e8)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("isHome = \(isHome)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Automatically resizing rows (iOS 8+)
        // http://guides.codepath.com/ios/Table-View-Guide#automatically-resizing-rows-ios-8
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Adding Pull-to-Refresh
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#adding-pull-to-refresh
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "twitter-compose"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(composeTweet(_:)))
        
        // Set up Infinite Scroll loading indicator
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#adding-infinite-scroll
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        // Remove the separator inset
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#how-do-you-remove-the-separator-inset
        tableView.separatorInset = UIEdgeInsets.zero
        
        // A little trick for removing the cell separators
        tableView.tableFooterView = UIView()
        
        // Remove text for back arrow for each view controller that is pushing
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Always white elements in nav bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Nav heading title
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: vcTitle, attributes: [
            NSFontAttributeName : UIFont(name: "OpenSans", size: 18)!,
            NSForegroundColorAttributeName : UIColor.white
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        loadData(maxId: 0)
    }
    
    // protocol delegate to get data from compose vc
    func addNewTweet(newTweet: Tweet) {
        self.tweets.insert(newTweet, at: 0) // At the start of the list so it appears at the top of the Home timeline
        
        self.tableView.reloadData()
    }
    
    func loadData(maxId: Int) {
        print("loadData.maxId: \(maxId)")
        
        if isHome { // Home timeline
            TwitterClient.sharedInstance.homeTimeline(maxId: maxId, success: { (tweets: [Tweet]) -> () in
                
                self.tweets.append(contentsOf: tweets)
                //self.tweets = tweets
                self.headTweetId = (self.tweets.last?.identifier)!
                
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                self.refreshControl.endRefreshing()
                
                /*
                 for tweet in tweets {
                 print(tweet.text)
                 }
                 */
                
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
            }, failure: { (error: Error) -> () in
                print("error: \(error.localizedDescription)")
            })
        } else { // must be Mentions timeline
            TwitterClient.sharedInstance.mentionsTimeline(maxId: maxId, success: { (tweets: [Tweet]) -> () in
                
                self.tweets.append(contentsOf: tweets)
                //self.tweets = tweets
                self.headTweetId = (self.tweets.last?.identifier)!
                
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                self.refreshControl.endRefreshing()
                
                /*
                 for tweet in tweets {
                 print(tweet.text)
                 }
                 */
                
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
            }, failure: { (error: Error) -> () in
                print("error: \(error.localizedDescription)")
            })
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Load data from API
        loadData(maxId: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func composeTweet(_ sender: Any) {
        self.performSegue(withIdentifier: "ComposeTweetSegue", sender: self)
    }
    
    func viewUserProfile(sender: UITapGestureRecognizer) {
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        
        //finally, we print out the value
        print("viewUserProfile.indexPath = \(indexPath)")
        
        self.performSegue(withIdentifier: "ProfileDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TweetDetailSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! TweetDetailTableViewController
            
            // Pass the tweet through
            let indexPath = sender as! IndexPath
            destinationViewController.tweet = tweets[indexPath.row]
        }
        
        if segue.identifier == "ComposeTweetSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! ComposeTweetViewController
            
            // Pass the delegate through
            destinationViewController.delegate = self
        }

        if segue.identifier == "ProfileDetailSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! ProfileViewController
            
            // Pass the user through
            let indexPath = sender as! IndexPath
            let tweet: Tweet = tweets[indexPath.row]
            destinationViewController.user = tweet.user
        }
        
    }
    
    // MARK: - Table view data source & delegates
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
        let data = self.tweets[indexPath.row]
        print("data[\(indexPath.row)]: \(data)")
        
        cell.loadProfileImage(imageUrl: data.user!.profileUrl!)
        
        // Make tweet profile image clickable
        cell.userProfileImageView.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(TweetsViewController.viewUserProfile))
        cell.userProfileImageView.addGestureRecognizer(recognizer)
        
        //cell.nameLabel.text = data.user?.name
        //cell.setScreenName(screenName: data.user!.screenName!)
        cell.setNameScreenName(nameScreenName: String("\(data.user!.name!) @\(data.user!.screenName!)"))
        
        cell.setStatus(statusText: data.text!)
        cell.timestampLabel.text = String("\(Date().offset(from: data.timestamp! as Date))")
        
        cell.retweetCountLabel.text = String("\(data.retweetCount)")!
        cell.favoriteCountLabel.text = String("\(data.favoriteCount)")!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tweets.count: \(tweets.count)")
        
        return tweets.count // new school: posts.count ?? 0 vs. old school: (posts ? posts.count : 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // removes the highlight on cell when we come back
        
        self.performSegue(withIdentifier: "TweetDetailSegue", sender: indexPath)
    }
    
    // MARK: - Scroll view delegates
    
    // Add a loading view to your view controller
    // https://guides.codepath.com/ios/Table-View-Guide#add-a-loading-view-to-your-view-controller
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadData(maxId: headTweetId-20)
            }
        }
    }
}
