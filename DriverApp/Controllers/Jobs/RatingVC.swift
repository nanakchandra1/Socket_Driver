//
//  RatingVC.swift
//  DriverApp
//
//  Created by Appinventiv on 17/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SDWebImage
import MFSideMenu


class RatingVC: UIViewController {
    
    //MARK:- IBOutletes
    //MARK:- ==================================================================

    @IBOutlet weak var paymentLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var ratingParamLbl: UILabel!
    @IBOutlet weak var sendRatingBtn: UIButton!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    @IBOutlet weak var fourthBtn: UIButton!
    @IBOutlet weak var fifthBtn: UIButton!
    @IBOutlet weak var sixthBtn: UIButton!
    @IBOutlet weak var parameterQuesLbl: UILabel!

    
    //MARK:- Properties
    //MARK:- ==================================================================

    
    var tripDetail = JSONDictionary()
    var ratingParams = [String]()
    var ride_id:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstBtn.setTitle(CLEANLINESS.localized, for: .normal)
        self.secondBtn.setTitle(S_PICKUP.localized.uppercased(), for: .normal)
        self.thirdBtn.setTitle(SERVICE.localized, for: .normal)
        self.fourthBtn.setTitle(NAVIGATION.localized, for: .normal)
        self.fifthBtn.setTitle(DRIVING.localized, for: .normal)
        self.sixthBtn.setTitle(OTHER.localized, for: .normal)
        
        printlnDebug(self.tripDetail)
        self.ratingParamLbl.text = ""
        self.parameterQuesLbl.text = ""
        self.floatRatingView.delegate = self
        self.userImgView.layer.cornerRadius = self.userImgView.bounds.height / 2
        self.userImgView.layer.masksToBounds = true
        self.setUpInitialView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- IBActions
    //MARK:- ==================================================================

    
    @IBAction func firstBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
        
    }
    
    @IBAction func secondBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
    }
    
    @IBAction func thirdBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
        
    }
    
    @IBAction func fourthBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
        
    }
    @IBAction func fifthbtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
        
    }
    
    @IBAction func sixthBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
        
    }
    
    @IBAction func sendRatingTapped(_ sender: UIButton) {
        
        if self.floatRatingView.rating != 0{
            var ratingParam = ""
            var params = JSONDictionary()
            
            params["action"] = "user" as AnyObject
            params["rating"] = self.floatRatingView.rating as AnyObject
            params["ride_id"] = self.ride_id as AnyObject
            
            if !self.ratingParams.isEmpty{
                
                for res in self.ratingParams{
                    if ratingParam == ""{
                        ratingParam = ratingParam + res
                    }
                    else{
                        ratingParam = ratingParam + "," + res
                    }
                }
                params["rating_params"] = ratingParam as AnyObject
                
            }
            showLoader()
            
            ServiceClass.rateApi(params, completionHandler: { (data) in
                
                printlnDebug(data)
                hideLoader()
                
                if let code = data["statusCode"].int, code == 200{
                
                    leavePickup()

                }
                
            })
            
        } else {
            showToastWithMessage(RatingParameters.ratingAlert)
        }
    }
    
    
//MARK:- Methods
//MARK:- ==================================================================
    
    func setUpInitialView(){
        
        if let driverDtail = self.tripDetail["driver_detail"] as? JSONDictionary, let img = driverDtail["image"] as? String{
            let imageUrlStr = imgUrl+img
            if let imageUrl = URL(string: imageUrlStr){
                self.userImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
        if let date = self.tripDetail["date_created"] as? String{
            self.dateLbl.text = covert_UTC_to_Local_WithTime(date)
        }
        if let amount = self.tripDetail["p_amount"]{
            self.paymentLbl.text = LAST_RIDE_FARE.localized + "$\(amount)"
            
        }
    
    }
    
    
    func setRatingParametersColor(_ sender: UIButton){
        
        var filtered = [String]()
        if sender.isSelected{
            sender.backgroundColor = UIColor(red: 216 / 255, green: 9 / 255, blue: 83 / 255, alpha: 1)
            self.ratingParams.append((sender.titleLabel?.text)!)
        }
        else{
            sender.backgroundColor = UIColor.white
            filtered = self.ratingParams.filter({$0 != sender.titleLabel!.text})
            self.ratingParams = filtered
        }
    }
    
}


//MARK:- FloatingRateView Delegate
//MARK:- ==================================================================


extension RatingVC: FloatRatingViewDelegate{
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
        if rating == 1{
            self.ratingParamLbl.text = RatingParameters.terrible
            self.parameterQuesLbl.text = RatingDescription.rate1
        }else if rating == 2{
            self.ratingParamLbl.text = RatingParameters.bad
            self.parameterQuesLbl.text = RatingDescription.rate2
            
        }else if rating == 3{
            self.ratingParamLbl.text = RatingParameters.ok
            self.parameterQuesLbl.text = RatingDescription.rate3
            
        }else if rating == 4{
            self.ratingParamLbl.text = RatingParameters.good
            self.parameterQuesLbl.text = RatingDescription.rate4
            
        }else if rating == 5{
            self.ratingParamLbl.text = RatingParameters.excellent
            self.parameterQuesLbl.text = RatingDescription.rate5
        }
    }
}
