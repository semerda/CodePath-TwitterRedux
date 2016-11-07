//
//  AvatarImageView.swift
//  codepath-tumblrfeed
//
//  Created by Ernest on 11/04/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class AvatarImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3.0
        
        self.backgroundColor = UIColor.white
    }
    
}
