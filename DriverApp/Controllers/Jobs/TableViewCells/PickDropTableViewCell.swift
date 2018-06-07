//
//  PickDropTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/25/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

// MARK: =====
// MARK: Enums
enum CellType {
    
    case onRide
    case preBooking
}

class PickDropTableViewCell: UITableViewCell {
    
    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationTypeLabel: UILabel!
    
    // MARK: =========
    // MARK: Constants
    
    // MARK: =========
    // MARK: Variables
    
    // MARK: ==================================
    // MARK: TableViewCell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()

        self.circleView.layer.cornerRadius = (IsIPad ? 5.5:4)
    }
    
    // MARK: =========
    // MARK: Private Methods
    func populate(at index: Int, with address: String, with cellType: CellType = .onRide) {
        
        if index == 0 {
            self.locationTypeLabel.text = "From:"
        } else {
            self.locationTypeLabel.text = "To:"
        }
        self.addressLabel.text = address
        self.addressLabel.sizeToFit()
        
        if cellType == .onRide {
            
            self.contentView.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
            self.addressLabel.textColor = UIColor(colorLiteralRed: 105/255.0, green: 105/255.0, blue: 105/255.0, alpha: 1)
            self.locationTypeLabel.textColor = UIColor(colorLiteralRed: 105/255.0, green: 105/255.0, blue: 105/255.0, alpha: 1)
                    
        } else if cellType == .preBooking {
            
            self.contentView.backgroundColor = UIColor(colorLiteralRed: 47/255.0, green: 47/255.0, blue: 47/255.0, alpha: 1)
            self.addressLabel.textColor = UIColor(colorLiteralRed: 130/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1)
            self.locationTypeLabel.textColor = UIColor(colorLiteralRed: 130/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1)
        }
    }
}
