//
//  ComposeTweetViewController.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/28/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit
import QuartzCore

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    // Delegate for TweetsViewController
    // Declare as weak to avoid memory cycles
    var delegate: WriteTweetBackDelegate?
    
    var tweet: Tweet? = nil
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var composeTweetTextView: UITextView!
    
    var charCountLabel: UILabel!
    var tweetItButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        composeTweetTextView.delegate = self

        // Do any additional setup after loading the view.
        
        // UI setup
        TwitterClient.sharedInstance.currentAccount(success: { (user: User) in
            // code
            self.userProfileImageView.setImageWith(user.profileUrl!)
            self.userProfileImageView.layer.cornerRadius = 6
        }, failure: { (error: Error) in
            print("error: \(error)")
        })
        
        // Buttons above keyboard
        charCountLabel = UILabel(frame: CGRect(0, 0, 30, 36))
        charCountLabel.tag = 1102
        charCountLabel.text = "140"
        charCountLabel.font = UIFont(name: "OpenSans", size:13)
        charCountLabel.textColor = UIColor.lightGray
        
        tweetItButton = UIButton(frame: CGRect(0, 0, 80, 36))
        tweetItButton.tag = 1101
        tweetItButton.backgroundColor = UIColor(netHex:0x63a9e8)
        if (tweet == nil) {
            tweetItButton.setTitle("Tweet", for: UIControlState.normal)
            //tweetItButton.titleLabel?.font = UIFont(name: "OpenSans", size:10)
            tweetItButton.addTarget(self, action:#selector(submitTweet), for: .touchUpInside)
        } else {
            tweetItButton.setTitle("Reply", for: UIControlState.normal)
            //tweetItButton.titleLabel?.font = UIFont(name: "OpenSans", size:10)
            tweetItButton.addTarget(self, action:#selector(replyTweet), for: .touchUpInside)
        }
        tweetItButton.layer.cornerRadius = 3.0
        tweetItButton.isEnabled = false
        
        let numberToolbar = UIToolbar(frame: CGRect(0, 0, self.view.frame.size.width, 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelCompose)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.init(customView: charCountLabel),
            UIBarButtonItem.init(customView: tweetItButton)
        ]
        numberToolbar.sizeToFit()
        composeTweetTextView.inputAccessoryView = numberToolbar
        composeTweetTextView.textColor = UIColor.lightGray
        
        // Must be replying to author - @handle needed in reply to reply
        if (tweet != nil) {
            composeTweetTextView.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func closeCompose(_ sender: Any) {
        composeTweetTextView.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelCompose(_ sender: Any) {
        composeTweetTextView.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTweet(_ sender: Any) {
        let escapedString = composeTweetTextView.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) as String!
        
        // Will add new Tweet to main Tweets list and refresh table without calling the API to do this
        //var newTweet: Tweet = Tweet.init(dictionary: Dictionary() as NSDictionary)
        
        let newTweet: Tweet = Tweet.init(dictionary: ["text": escapedString ?? ""] as [String : Any] as NSDictionary)
        delegate?.addNewTweet(newTweet: newTweet)
        
        TwitterClient.sharedInstance.updateStatus(status: escapedString!,
                                                  inReplyToStatusId: (tweet != nil) ? (tweet?.identifier)! : 0,
                                                  success: { (response: NSDictionary) in
            // code
            print("updateStatus.response: \(response)")
            
            self.dismiss(animated: true, completion: nil)
        }, failure: { (error: Error) in
            print("updateStatus.error: \(error)")
            
            let alertController = UIAlertController(title: "Something went wrong :(", message: error.localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // handle response here.
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
        })
    }
    
    @IBAction func replyTweet(_ sender: Any) {
        print("replyTweet")
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charLimit = 140
        let charsCount = (textView.text?.utf16.count)! + text.utf16.count - range.length
        
        print("textView.charsCount: \(charsCount)")
        
        charCountLabel.text = String("\(charLimit - charsCount)")
        if charCountLabel.text == "0" {
            tweetItButton.isEnabled = false
            tweetItButton.backgroundColor = UIColor.lightGray
            
            charCountLabel.textColor = UIColor.red
        } else {
            tweetItButton.isEnabled = true
            tweetItButton.backgroundColor = UIColor(netHex:0x63a9e8)
            
            charCountLabel.textColor = UIColor.lightGray
        }
        
        return charsCount < charLimit // To just allow up to 140 characters
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Must be replying to author - @handle needed in reply to reply
        if (tweet != nil) {
            composeTweetTextView.text = String("\(tweet!.user!.getScreenName()) ")
        } else {
            composeTweetTextView.text = ""
        }
        composeTweetTextView.textColor = UIColor.black
    }

}
