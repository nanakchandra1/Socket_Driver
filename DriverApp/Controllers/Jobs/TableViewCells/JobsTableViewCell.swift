//
//  JobsTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/14/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class JobsTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var slantView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var jobTypeLabel: UILabel!
    @IBOutlet weak var rideFareBtn: UILabel!
    @IBOutlet weak var tripDateLbl: UILabel!
    @IBOutlet weak var rideTimeLbl: UILabel!
    @IBOutlet weak var rideDistanceLbl: UILabel!
    
    
    
    // MARK: TableViewCell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        
        self.slantView.addSlope(withColor: UIColor(red: 132/255, green: 132/255, blue: 132/255, alpha: 1), ofWidth: 18, ofHeight: 18)
        
        self.userImageView.layer.cornerRadius = 45 / 2
        self.userImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func populateData(_ tripDetail: JSONDictionary){
    
        
        
        if let date = tripDetail["start_time"] as? String{
            
            self.tripDateLbl.text = covert_UTC_to_Local(date)
            
        }
        
        if let time = tripDetail["start_time"] as? String{
            
            self.rideTimeLbl.text = covert_UTC_to_LocalTime(time)
            
        }

        if let fare = tripDetail["p_amount"]{
            self.rideFareBtn.text = "$\(fare)"
            
        }
        
        if let dist = tripDetail["estimated_distance"]{
            self.rideDistanceLbl.text = "\(dist) km"
        }
        
        if let type = tripDetail["type"]{
            self.jobTypeLabel.text = "\(type.uppercased)"
        }

        
        if let user_Img =  tripDetail["user_image"] as? String{
        
            let imageUrlStr = "http://52.76.76.250/uploads/users/"+user_Img
            
            if let imageUrl = URL(string: imageUrlStr){
                self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
    }
    
}
