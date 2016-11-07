//
//  ProfileViewController.swift
//  CodePath-Twitter
//
//  Created by Ernest on 11/04/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class ProfileViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var user: User? = nil
    
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var header: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerBlurImageView: UIImageView!
    var blurredHeaderImageView: UIImageView?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tagLineLabel: ActiveLabel!
    @IBOutlet weak var tagLinePageControl: UIPageControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var urlLabel: ActiveLabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Automatically resizing rows (iOS 8+)
        // http://guides.codepath.com/ios/Table-View-Guide#automatically-resizing-rows-ios-8
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "twitter-compose"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(composeTweet(_:)))
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.view.backgroundColor = UIColor.clear
        
        // Update UI
        user = user == nil ? User.currentUser : user // if nothing passed in then it must be operators profile
        print("user: \(user)")
        
        avatarImage.setImageWith((user?.profileUrl!)!)
        
        headerLabel.text = user?.name!
        nameLabel.text = user?.name!
        screenNameLabel.text = user?.getScreenName()
        
        tagLineLabel.text = user?.tagline!
        tagLineLabel.numberOfLines = 3
        tagLineLabel.enabledTypes = [.mention, .hashtag, .url]
        tagLineLabel.textColor = .black
        tagLineLabel.handleHashtagTap { hashtag in
            print("Tapped hashtag: \(hashtag) -- TODO: Search using this Hashtag")
            // TODO: Add search using this hashtag
        }
        tagLineLabel.handleURLTap({ (url: URL) in
            print("Tapped URL: \(url)")
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        })
        tagLineLabel.sizeToFit()
        
        locationLabel.text = ((user?.location!)!)
        urlLabel.text = ((user?.url!)!)
        
        followingLabel.text = String("\((user?.followingCount)!) FOLLOWING")
        followersLabel.text = String("\((user?.followersCount)!) FOLLOWERS")
        
        // Fetch user tweets
        loadData(screenName: (user?.screenName!)!)
        
        // Gestures
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(onScreenEdgePanGesture))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }
    
    func loadData(screenName: String) {
        print("loadData.screenName: \(screenName)")
        
        TwitterClient.sharedInstance.userTimeline(screenName: screenName, success: { (tweets: [Tweet]) -> () in
            
            self.tweets = tweets
            self.tableView.reloadData()
            
        }, failure: { (error: Error) -> () in
            print("error: \(error.localizedDescription)")
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Header - Image
        headerImageView = UIImageView(frame: header.bounds)
        //headerImageView?.image = UIImage(named: "kraken-pb-eyes-colored") // TODO: Load from Real Twitter Account?
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: header.bounds)
        //headerBlurImageView?.image = UIImage(named: "kraken-pb-eyes-colored")?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
        
        // Header image
        //print("user!.profileBackgroundUrl! = \(user!.profileBackgroundUrl!)")
        if let profileBackgroundUrlTmp = user?.profileBackgroundUrl! {
            //print("profileBackgroundUrlTmp = \(profileBackgroundUrlTmp)")
            headerImageView.setImageWith(profileBackgroundUrlTmp)
            headerBlurImageView.setImageWith(profileBackgroundUrlTmp)
            
            headerBlurImageView.frame = self.view.bounds
            headerBlurImageView.blurImage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func onLogoutButton() {
        let alert = UIAlertController(title: "Logout?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            TwitterClient.sharedInstance.logout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func composeTweet(_ sender: Any) {
        self.performSegue(withIdentifier: "ComposeTweetSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TweetDetailSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! TweetDetailTableViewController
            
            // Pass the tweet through
            let indexPath = sender as! IndexPath
            destinationViewController.tweet = tweets[indexPath.row]
        }
        
    }
    
    // MARK: - Table view data source & delegates
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
        let data = self.tweets[indexPath.row]
        print("data[\(indexPath.row)]: \(data)")
        
        cell.loadProfileImage(imageUrl: data.user!.profileUrl!)
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
    
    // MARK: - ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // Pull down
        if offset < 0 {
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }
        else { // Scroll up / down
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                if avatarImage.layer.zPosition < header.layer.zPosition {
                    header.layer.zPosition = 0
                }
            } else {
                if avatarImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        header.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
    }
    
    // MARK: - Gestures for slide out menu
    
    @IBAction func onScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .recognized {
            print("Screen edge swiped!")
            self.menuView.isHidden = false
            
            UIView.animate(withDuration: 1.4, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 6, animations: {
                // Add the transformation in this block
                // self.container is your view that you want to animate
                self.menuView.transform = CGAffineTransform(translationX: 190, y: 0)
            }, completion: nil)
        }
    }
    
    @IBAction func menuClose() {
        closeMenu()
    }
    
    func closeMenu() {
        UIView.animate(withDuration: 1.4, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 6, animations: {
            // Add the transformation in this block
            // self.container is your view that you want to animate
            self.menuView.transform = CGAffineTransform(translationX: -190, y: 0)
        }, completion: {
            (value: Bool) in
            self.menuView.isHidden = true
        })
    }
    
    @IBAction func onMenuHome() {
        closeMenu()
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func onMenuMentions() {
        closeMenu()
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func onMenuMe() {
        closeMenu()
    }
    
    // MARK: - Page Control
    
    @IBAction func changeDescrption() {
        print("tagLinePageControl.currentPage = \(tagLinePageControl.currentPage)")
        UIView.transition(with: tagLineLabel,
                          duration: 0.25,
                          options: [.transitionFlipFromLeft],
                          animations: {
                            if self.tagLinePageControl.currentPage == 0 {
                                self.tagLineLabel.text = self.user?.tagline!
                            } else {
                                self.tagLineLabel.text = "The Answer to life is 0011010000110010 - Visit http://www.ernestsemerda.com/ and learn more"
                            }
        }, completion: nil)
    }

}
