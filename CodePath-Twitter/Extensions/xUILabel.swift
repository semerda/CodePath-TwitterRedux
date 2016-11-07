//
//  xButton.swift
//  CodePath-Twitter
//
//  Created by Ernest on 10/29/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

extension UILabel {
    
    func bounce() {
        // Spring Bounce the UILabel to give it notice
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1.0,
                       delay: 0.5,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: .curveLinear,
                       animations: {
                        self.transform = CGAffineTransform.identity
        },
                       completion: nil
        )
    }
    
}
