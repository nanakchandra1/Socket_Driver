//
//  PickUpTripDetailCell.swift
//  DriverApp
//
//  Created by Appinventiv on 14/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class RideHistoryDetailCell: UITableViewCell {

    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var fromCircleView: UIView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var fromLocationTypeLabel: UILabel!
    @IBOutlet weak var toCircleView: UIView!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var toLocationTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: =========
    // MARK: Private Methods
    
    func setUpView(){
    
        self.fromCircleView.layer.cornerRadius = 4
        self.toCircleView.layer.cornerRadius = 4
        self.userImg.layer.cornerRadius = self.userImg.bounds.height / 2
        self.userImg.layer.borderWidth = 3
        self.userImg.layer.borderColor = UIColor.white.cgColor
        self.userImg.layer.masksToBounds = true

    }
    
    
    func populate(at index: Int, with fromAddress: String, with toAddress: String) {
        
        self.fromCircleView.layer.cornerRadius = self.fromCircleView.bounds.height / 2
        self.toCircleView.layer.cornerRadius = self.toCircleView.bounds.height / 2

        self.fromAddressLabel.text = fromAddress
        self.toAddressLabel.text = toAddress

        
        }
}
