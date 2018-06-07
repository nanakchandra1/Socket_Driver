//
//  BookingConfirmationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class BookingConfirmationViewController: UIViewController {
    
    // IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var bookingTimeBtn: UIButton!
    @IBOutlet weak var congratulationsLabel: UILabel!
    @IBOutlet weak var bookingIdLabel: UILabel!
    @IBOutlet weak var estimatedTimelLabel: UILabel!
    @IBOutlet weak var driverDetailView: UIView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverMobileNumberLabel: UILabel!

    @IBOutlet weak var verticalSpaceBetweenDriverNameLabelAndDriverDetailView: NSLayoutConstraint!
    
    @IBOutlet weak var cancelBookingButton: UIButton!
    
    @IBOutlet weak var termsOfCancelBookingTitle: UILabel!
    @IBOutlet weak var termsofCancelLabel1: UILabel!
    @IBOutlet weak var termsOfCancelLabel2: UILabel!
    
    
    var tripDetail = JSONDictionary()
    var ride_id:String!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.driverImageView.layer.cornerRadius = self.driverImageView.frame.size.height/2
        
        if IsIPhone {
            self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant = 10 + self.driverImageView.frame.size.height/2
            self.driverDetailView.frame.size.height = self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant + 51
            
        } else if IsIPad{
            
            self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant = 15 + self.driverImageView.frame.size.height/2
            self.driverDetailView.frame.size.height = self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant + 91
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:- Private Methods
    //MARK:- =================================================

    
    func initialSetup() {
        
        self.congratulationsLabel.text = CONGRATULATIONS.localized
        self.termsOfCancelBookingTitle.text = TERMS_OF_CANCELLATION.localized
        self.termsofCancelLabel1.text = TERMS_OF_CANCELLATION_LINE_1.localized
        self.termsOfCancelLabel2.text = TERMS_OF_CANCELLATION_LINE_2.localized
        self.estimatedTimelLabel.text = ESTIMATED_TIME_ARRIVAL.localized
        
        self.bookingTimeBtn.layer.borderColor = UIColor.white.cgColor
        self.bookingTimeBtn.layer.borderWidth = 1
        self.bookingTimeBtn.layer.cornerRadius = 3
        self.bookingTimeBtn.clipsToBounds = true
        
        self.driverImageView.layer.borderColor = UIColor(red: 214/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.driverImageView.layer.borderWidth = 2
        self.driverImageView.clipsToBounds = true
        self.bookingIdLabel.text = YOUR_BOOKING_ID.localized + self.ride_id
        
        if let driver_detail = self.tripDetail["driver_detail"] as? JSONDictionary, let name = driver_detail["name"] as? String, let mobile = driver_detail["contact"]  as? String, let img = driver_detail["image"] as? String{
        
            self.driverNameLabel.text = name
            self.driverMobileNumberLabel.text = mobile
            
                let imageUrlStr = "http://52.76.76.250/"+img
                if let imageUrl = URL(string: imageUrlStr){
                    self.driverImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
                }
            
        }
        
        delay(10) {
            self.hideContentController(self)
        }
        
    }
    
    func hideContentController(_ content: UIViewController) {
        content.willMove(toParentViewController: nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }

    
    // MARK: IBActions
    //MARK:- =================================================

    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBookingBtnTapped(_ sender: UIButton) {
        
        var params = JSONDictionary()
        params["ride_id"]        = self.ride_id as AnyObject

        params["action"]        = "cancel" as AnyObject
        params["cancelled_by"]  = "user" as AnyObject
        params["reason"]        = "I want to cancel" as AnyObject

        rideActionApi(params) { (success) in
            printlnDebug(success)
            hideLoader()
        }
        
    }

}
