//
//  LoginViewController.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/26/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gifManager = SwiftyGifManager(memoryLimit:20)
        self.loginImageView.setGifImage(UIImage(gifName: "owl-in-snow"), manager: gifManager)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(sender: AnyObject) {
        let client = TwitterClient.sharedInstance
        client.login(success: { () -> () in
            // TODO: segue in
            print("I've logged in!")
            self.performSegue(withIdentifier: "HomeTimelineSegue", sender: nil)
            }, failure: { (error: Error) -> () in
                print("error: \(error.localizedDescription)")
        })
    }

}
