//
//  TweetTableViewCell.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/27/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    //@IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameScreenNameLabel: ActiveLabel!
    
    @IBOutlet weak var textTextView: ActiveLabel!
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setStatus(statusText: String) {
        textTextView.text = statusText
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
    }
    
    func loadProfileImage(imageUrl: URL) {
        // Fading in an Image Loaded from the Network
        // https://guides.codepath.com/ios/Working-with-UIImageView#fading-in-an-image-loaded-from-the-network
        let imageRequest = NSURLRequest(url: imageUrl)
        self.userProfileImageView?.setImageWith(
            imageRequest as URLRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    self.userProfileImageView?.alpha = 0.0
                    self.userProfileImageView?.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.userProfileImageView?.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    self.userProfileImageView?.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                print("Image failed with error = \(error)")
                // do something for the failure condition
                self.userProfileImageView?.image = UIImage.init(named: "kraken-failure")
        })
    }
    
    func imageTapped(img: AnyObject)
    {
        
    }
    
    /*
    func setScreenName(screenName: String) {
        self.screenNameLabel.text = String("@\(screenName)")
    }
     */
    
    func setNameScreenName(nameScreenName: String) {
        nameScreenNameLabel.text = nameScreenName
        nameScreenNameLabel.numberOfLines = 0
        nameScreenNameLabel.enabledTypes = [.mention, .hashtag, .url]
        nameScreenNameLabel.textColor = .black
        nameScreenNameLabel.handleMentionTap({ (handle: String) in
            print("Tapped handle: \(handle) -- TODO: Go to User Profile")
            // TODO: Go to User Profile
        })
    }
}
