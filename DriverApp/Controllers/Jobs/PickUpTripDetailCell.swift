//
//  PickUpTripDetailCell.swift
//  DriverApp
//
//  Created by Appinventiv on 14/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class PickUpTripDetailCell: UITableViewCell {

    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userContactNo: UIButton!
    @IBOutlet weak var rideState: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var fromCircleView: UIView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var fromLocationTypeLabel: UILabel!
    @IBOutlet weak var toCircleView: UIView!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var toLocationTypeLabel: UILabel!
    @IBOutlet weak var startNavigationBtn: UIButton!
    @IBOutlet weak var startTripViewTop: NSLayoutConstraint!
    @IBOutlet weak var startNaavHeight: NSLayoutConstraint!

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
        self.userImg.layer.borderColor = RATING_PARMS_COLOR.cgColor
        self.userImg.layer.masksToBounds = true
        self.startBtn.layer.cornerRadius = 3
        self.cancelBtn.layer.cornerRadius = 3
        self.startNavigationBtn.layer.cornerRadius = 3


    }
    
    func showCompleteTripBtn(_ isShow : Bool){
        if !isShow{
        self.cancelBtn.setTitle("COMPLETE TRIP", for: UIControlState())
        self.startBtn.setTitle("NAVIGATE", for: UIControlState())
            self.rideState.text = "On Ride"
            self.startTripViewTop.constant = 23
            self.startNaavHeight.constant = 0
        }else{
            self.cancelBtn.setTitle("START TRIP", for: UIControlState())
            self.startBtn.setTitle("CANCEL TRIP", for: UIControlState())
            self.rideState.text = "Arriving Now"
            self.startTripViewTop.constant = 8
            self.startNaavHeight.constant = 30

        }

    }
    
    func populate(at index: Int, with fromAddress: String, with toAddress: String) {
        
        self.fromCircleView.layer.cornerRadius = self.fromCircleView.bounds.height / 2
        self.toCircleView.layer.cornerRadius = self.toCircleView.bounds.height / 2

        self.fromAddressLabel.text = fromAddress
        self.toAddressLabel.text = toAddress

        
        }
}
