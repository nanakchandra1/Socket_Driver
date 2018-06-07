//
//  JobDetailTableViewCell.swift
//  DriverApp
//
//  Created by Sarthak Gupta on 22/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class JobDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomSepratorV: UIView!
    @IBOutlet weak var bottomSepratorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleSepratorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleSepratorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleSepratorBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var valueLabel1: UILabel!
    @IBOutlet weak var parameterLabel1: UILabel!
    
    @IBOutlet weak var valueLabel2: UILabel!
    @IBOutlet weak var parameterLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.middleSepratorWidthConstraint.constant = 0.5
        
        self.bottomSepratorHeightConstraint.constant = 0.5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        
    }
    
    func adjustCellSeprator(_ isFirst:Bool, isLast: Bool) {
        
        self.middleSepratorBottomConstraint.constant = 0
        self.middleSepratorTopConstraint.constant = 0
        self.bottomSepratorV.isHidden = false
        if isFirst {
            self.middleSepratorTopConstraint.constant = 8
        }
        if isLast {
            self.middleSepratorBottomConstraint.constant = 8
            self.bottomSepratorV.isHidden = true
        }
        
    }
    
    
    func loadPreviousJobDetails(_ indexPath: IndexPath, data:[String: AnyObject]){
        switch indexPath.row {
        case 0:
            self.parameterLabel1.text = "PAYMENT MODE"
            
            if let p_mode = data["p_mode"] as? String {
                if p_mode == PaymentMode.card{
                    self.valueLabel1.text = PaymentMode.card.uppercased()
                }else{
                    self.valueLabel1.text = PaymentMode.cash.uppercased()
                }
            }
            self.parameterLabel2.text = "VEHICAL TYPE"
            
            if let v_type = data["vehicle_type"] as? String{
            
                self.valueLabel2.text = v_type.uppercased()

            }

//            if let userDetail = data["user_detail"] as? JSONDictionary, let vehicle = userDetail["vehicle"] as? JSONDictionary, let type =  vehicle["type"] as? String{
//                if type.lowercaseString == VehicleType.car.lowercaseString{
//                    self.valueLabel2.text = VehicleType.car.uppercaseString
//                }else{
//                    self.valueLabel2.text = VehicleType.bike.uppercaseString
//                }
//            }
        case 1:
            self.parameterLabel1.text = "DATE & TIME"
            
            if let date = data["start_time"] as? String{
                self.valueLabel1.text = covert_UTC_to_Local_WithTime(date)

            }
            self.parameterLabel2.text = "TRIP DISTANCE"
            
            if let dist = data["estimated_distance"]{
                self.valueLabel2.text = "\(dist) KM"

            }
        case 2:
            self.parameterLabel1.text = "TRIP DURATION"
            
            if let duration = data["estimated_time"]{
                self.valueLabel1.text = "\(duration) MIN"
            }
            self.parameterLabel2.text = "TRIP TYPE"
            
            if let tripType = data["type"] as? String{
                self.valueLabel2.text = tripType.uppercased()

            }
        default:
            return
        }
    }
    
    func loadUpcomingJobDetails(_ indexPath: IndexPath, data:[String: AnyObject]?){
        switch indexPath.row {
        case 0:
            self.parameterLabel1.text = "FARE AMOUNT"
            self.valueLabel1.text = "$200"
            self.parameterLabel2.text = "PAYMENT MODE"
            self.valueLabel2.text = "CASH"
        case 1:
            self.parameterLabel1.text = "VEHICAL TYPE"
            self.valueLabel1.text = "CAR"
            self.parameterLabel2.text = "DATE & TIME"
            self.valueLabel2.text = "12-25-2015\n09:00 PM"
        default:
            return
        }
    }
    
    
}
