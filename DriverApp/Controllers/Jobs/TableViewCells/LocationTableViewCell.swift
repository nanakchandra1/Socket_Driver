//
//  PickUpTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/21/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    @IBOutlet weak var addMoreLocationBtn: UIButton!
    @IBOutlet weak var editLocationBtn: UIButton!
    @IBOutlet weak var deleteLocationBtn: UIButton!
    
    
    // MARK: Table View Cell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dotView.layer.cornerRadius = IsIPad ? 5:3.5
        self.dotView.backgroundColor = UIColor(red: 215/255, green: 45/255, blue: 53/255, alpha: 1)
        
        self.locationAddressLabel.sizeToFit()
    }
    
    // MARK: Private Methods
    func populate(atIndex index: Int, withNumberOfLocations locations: Int, withLocationAddress address: String?) {
        
        if (address != "Choose your Drop Off") {
        
            
        } else {
           
        }
                
        if locations < 2 {
            
            self.locationTypeLabel.text = "DROP"
            
        } else {
            
            self.locationTypeLabel.text = "DROP"
        }
        
        self.locationAddressLabel.text = address
    }
    
    
}
