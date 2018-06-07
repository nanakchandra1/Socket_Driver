//
//  JobDetailVC.swift
//  DriverApp
//
//  Created by Sarthak Gupta on 22/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps

class JobDetailVC: UIViewController {

    //MARK:- IBOutles
    //MARK:- ==============================================
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var jobDetailTblV: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cancelRideHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImgV: CircularImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    var isPreviousJob = true
    @IBOutlet weak var rateAndTotalViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateingView: FloatRatingView!
    @IBOutlet weak var rideFareLbl: UILabel!
 
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var tripTotalLabel: UILabel!
    @IBOutlet weak var cancelRideButton: UIButton!
    
    
    //MARK:- Properties
    //MARK:- ==============================================

    var rating: String!
 
    
    //MARK:- View life cycle
    //MARK:- ==============================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.rateLabel.text = RATE.localized
        self.tripTotalLabel.text = TRIP_TOTAL.localized
        self.cancelRideButton.setTitle(CANCEL_RIDE.localized, for: .normal)
        self.rateingView.rating = 0
        self.rateingView.editable = false
        self.profileImgV.layer.borderWidth = 2
        self.profileImgV.layer.masksToBounds = true
        self.profileImgV.layer.borderColor = RED_BUTTON_COLOR.cgColor
        self.jobDetailTblV.register(UINib(nibName: "JobDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "jobDetailCell")
        self.jobDetailTblV.delegate = self
        self.jobDetailTblV.dataSource = self
        if self.isPreviousJob {
            self.cancelRideHeightConstraint.constant = 0
            self.titleLbl.text = PREVIOUS_JOB.localized.capitalized
        }else{
            self.rateAndTotalViewHeightConstraint.constant = 0
            self.titleLbl.text = UPCOMING_TRIPS.localized.capitalized
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let user_Img =  driverSharedInstance.rideDetail["user_image"] as? String, let name = driverSharedInstance.rideDetail["user_name"] as? String{
            
            let imageUrlStr = "http://52.76.76.250/uploads/users/" + user_Img
            
            if let imageUrl = URL(string: imageUrlStr){
                self.profileImgV.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
            self.userNameLbl.text = name
        }
        
        if let rating = driverSharedInstance.rideDetail["user_rating"]{
            self.rateingView.rating = Float((rating as? Int)!)
        }
        
        if let fare = driverSharedInstance.rideDetail["p_amount"]{
            self.rideFareLbl.text = "  $\(fare)"
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension JobDetailVC: UITableViewDataSource ,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isPreviousJob{
                return 3
            }
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobDetailCell", for: indexPath) as! JobDetailTableViewCell
        cell.adjustCellSeprator(indexPath.row == 0, isLast: self.isPreviousJob ? indexPath.row == 2: indexPath.row == 1)
        if self.isPreviousJob {
            cell.loadPreviousJobDetails(indexPath, data: driverSharedInstance.rideDetail)
        }else{
            cell.loadUpcomingJobDetails(indexPath, data: driverSharedInstance.rideDetail)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76 * (screenWidth / 375)
    }
}
