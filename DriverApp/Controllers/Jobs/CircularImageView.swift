//
//  CircularImageView.swift
//  DriverApp
//
//  Created by Sarthak Gupta on 23/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class CircularImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.width / 2
    }
}
