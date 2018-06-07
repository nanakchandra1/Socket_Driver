//
//  PickDropSectionHeaderCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/26/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class PickDropSectionHeaderCell: UITableViewCell {

    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!
        
    // MARK: ==================================
    // MARK: TableViewCell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = (IsIPad ? 46:30)/2
        self.userImageView.layer.borderWidth = 1.5
        self.userImageView.layer.borderColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1).cgColor
    }
    
    // MARK: =========
    // MARK: Private Methods
}
