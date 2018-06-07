
//
//  RequestRidePopUpViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/21/16.
//  Copyright © 2016 AppInventiv. All rights reserved.


import UIKit
import CoreLocation
import MFSideMenu
import GoogleMaps
import SwiftyJSON


protocol RelodeTripDetailDataDelegate {
    func reloadeTripData()
}


enum ShowPopUp {
    case request,payment,rating,changeDestination, pickUpRequest
}


enum PaymentType {
    
    case cash, card
    
}

protocol LocationChangeDelegate : class {
    
    func didChangeLocation()
}


class RequestRidePopUpViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var requestPopUpBgView: UIView!
    @IBOutlet weak var tripModeBtn: UIButton!
    @IBOutlet weak var userRequestingImageView: UIImageView!
    @IBOutlet weak var userRequestingNameLabel: UILabel!
    
    @IBOutlet weak var pickDropTableView: UITableView!
    
    
    // payment view
    @IBOutlet weak var paymentBgView: UIView!
    @IBOutlet weak var fareLbl: UILabel!
    @IBOutlet weak var ammountLbl: UILabel!
    @IBOutlet weak var ammountTypeLbl: UILabel!
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var floatingRatingView: FloatRatingView!
    @IBOutlet weak var sendratingBtn: UIButton!
    
    // rating view
    
    @IBOutlet weak var ratingBgView: UIView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    // change destination view
    
    @IBOutlet weak var changeDestinationBgView: UIView!
    @IBOutlet weak var changeDestinationHeaderLbl: UILabel!
    @IBOutlet weak var newDropMsgLbl: UILabel!
    @IBOutlet weak var newDropLocLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var aditionalFareLbl: UILabel!
    @IBOutlet weak var changeDestiRejectBtn: UIButton!
    @IBOutlet weak var changeDestiAcceptBtn: UIButton!
    
    // pickuprequest
    @IBOutlet weak var pickupRequestHeaderLbl: UIView!
    @IBOutlet weak var pickupRequestPopupView: UIView!
    @IBOutlet weak var pickUpLocLbl: UILabel!
    @IBOutlet weak var pickUpAddressLbl: UILabel!
    @IBOutlet weak var dropLbl: UILabel!
    @IBOutlet weak var dropOffAddressLbl: UILabel!
    @IBOutlet weak var startTripBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var amountLbl: UILabel!
    
    
    
    @IBOutlet weak var tripDetailLabel: UILabel!
    @IBOutlet weak var tripModeLabel: UILabel!
    
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    
    
    var locationManager = CLLocationManager()
    var userInfo: ChangeDropModel!
    var address = ""
    var requst_date = ""
    var currentLoc: CLLocation?
    var selectedPopUp = ShowPopUp.request
    var paymentType = PaymentType.cash
    var index : IndexPath!
    var delegate:RelodeTripDetailDataDelegate!
    var seatAvailable:Int = 0
    
    var jobDetails : JobDetailsModel!
    var pickUpRequestDetail: PickupRequestModel!
    weak var changeLocationDelegate : LocationChangeDelegate?
    
    //MARK:- View life cycles
    //MARK:- ================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.acceptButton.setTitle(ACCEPT.localized, for: .normal)
        self.rejectButton.setTitle(REJECT.localized, for: .normal)
        self.rejectBtn.setTitle(REJECT.localized, for: .normal)
        
        self.locationManager.delegate = self
        initiateView()
        //        self.mapView.myLocationEnabled = true
        //        self.mapView.settings.compassButton = true
        //        self.mapView.settings.myLocationButton = true
        self.tripModeBtn.layer.borderWidth = 1
        self.tripModeBtn.layer.borderColor = UIColor(red: 219/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.tripModeBtn.layer.cornerRadius = 3
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    
    
    //MARK:- private methods
    //MARK:- ================================================================
    
    
    func initiateView(){
        
        
        if self.selectedPopUp == .request{
            self.pickDropTableView.dataSource = self
            self.pickDropTableView.delegate = self
            self.setRequestPopUpData()
            
        }else if self.selectedPopUp == .payment || CurrentUser.ridestate == RideStateString.payment{
            
            self.setPaymentData()
            
        }else if self.selectedPopUp == .changeDestination{
            self.setChangeDestinationData()
        }else if self.selectedPopUp == .rating || CurrentUser.ridestate == RideStateString.rating{
            self.setRatingData()
        }
        else{
            self.setRequestPickUpData()
        }
        
    }
    
    
    
    func setRequestPopUpData(){
        
        self.requestPopUpBgView.isHidden = false
        self.paymentBgView.isHidden = true
        self.ratingBgView.isHidden = true
        self.changeDestinationBgView.isHidden = true
        self.pickupRequestPopupView.isHidden = true
        self.userRequestingImageView.layer.cornerRadius = 60 / 2
        self.userRequestingImageView.layer.borderWidth = 2
        self.userRequestingImageView.layer.borderColor = UIColor(red: 219/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.userRequestingImageView.clipsToBounds = true
        
        if let name = self.jobDetails.user_name{
            
            self.userRequestingNameLabel.text = name.uppercased()
        }
        
        if let ride_id = self.jobDetails.ride_id{
            
            driverSharedInstance.ride_id = ride_id
        }
        
        if let image = self.jobDetails.image{
            
            let imageUrlStr = "http://52.76.76.250/uploads/users/"+image
            if let imageUrl = URL(string: imageUrlStr){
                self.userRequestingImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
        
        self.address = self.jobDetails.dropAddress
        
        if let timestamp = self.jobDetails.timeStamp{
            
            self.requst_date = covert_UTC_to_Local_WithTime(timestamp)
        }
        
        self.pickDropTableView.reloadData()
        
    }
    
    
    func setPaymentData(){
        
        self.requestPopUpBgView.isHidden = true
        self.paymentBgView.isHidden = false
        self.ratingBgView.isHidden = true
        self.changeDestinationBgView.isHidden = true
        self.pickupRequestPopupView.isHidden = true
        
        
        self.ammountLbl.text = "$" + self.jobDetails.p_amount
        
        if self.paymentType == .cash{
            
            self.ammountTypeLbl.text = CASH_AMOUNT.localized
            
            self.proceedBtn.setTitle(AMOUNT_RECEIVED.localized, for: UIControlState())
            
        }else{
            
            self.ammountTypeLbl.text = PAYMENT_RECEIVED.localized
            
            self.proceedBtn.setTitle(PROCEED.localized, for: UIControlState())
        }
    }
    
    
    func setRatingData(){
        
        self.floatingRatingView.rating = 0
        self.requestPopUpBgView.isHidden = true
        self.paymentBgView.isHidden = true
        self.ratingBgView.isHidden = false
        self.changeDestinationBgView.isHidden = true
        self.pickupRequestPopupView.isHidden = true
        
        self.userImage.layer.cornerRadius = self.userImage.bounds.height / 2
        self.userImage.layer.masksToBounds = true
        self.userImage.layer.borderColor = UIColor(red: 219/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.userImage.layer.borderWidth = 3
        
        if let image = self.jobDetails.image{
            var imageUrlStr = ""
            //            if CurrentUser.ridestate == RequestType.pickup{
            //                 imageUrlStr = imgUrl+image
            //
            //            }else{
            imageUrlStr = "http://52.76.76.250" + image
            //            }
            if let imageUrl = URL(string: imageUrlStr){
                
                self.userImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
    }
    
    
    
    func setChangeDestinationData(){
        
        
        GMSServices.provideAPIKey(sharedAppdelegate.googleMapsApiKey)
        self.requestPopUpBgView.isHidden = true
        self.paymentBgView.isHidden = true
        self.ratingBgView.isHidden = true
        self.changeDestinationBgView.isHidden = false
        self.pickupRequestPopupView.isHidden = true
        
        guard let pos = self.userInfo.cd_position else{return}
        
        
        let d_pos = Int(pos)!
        if !self.userInfo.dropAddress.isEmpty{
            
            self.newDropLocLbl.text = self.userInfo.dropAddress
            let D_cord = CLLocationCoordinate2D(latitude: Double(self.userInfo.dropLat[d_pos])!, longitude: Double(self.userInfo.dropLong[d_pos])!)
            self.mapView.camera = GMSCameraPosition(target: D_cord, zoom: 15.5, bearing: 0, viewingAngle: 15)
            
            let marker = GMSMarker()
            marker.position = D_cord
            marker.icon = UIImage(named: "request_job_location_pin")
            marker.map = self.mapView
            
            //                }
            
        }
        
        self.aditionalFareLbl.text = ADDITIONAL_FARE_AMOUNT.localized
        self.amountLbl.text = "$0"
        
        self.changeDestinationOnResponse()
        
    }
    
    
    func changeDestinationOnResponse(){
        
        SocketServices.socketOnAcceptChangeLocation_res { (success, data) in
            
            if success{
                
                let result = data["result"]
                
                
                
                if result["cd_status"].stringValue == "2"{
                    
                    self.changeLocationDelegate?.didChangeLocation()
                    self.dismiss(animated: true, completion: nil)
                    //                    self.goToOnTripScreen(self.jobDetails)
                    
                } else if result["cd_status"].stringValue == "1" {
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    func setRequestPickUpData(){
        
        self.requestPopUpBgView.isHidden = true
        self.paymentBgView.isHidden = true
        self.ratingBgView.isHidden = true
        self.changeDestinationBgView.isHidden = true
        self.pickupRequestPopupView.isHidden = false
        
        self.dropOffAddressLbl.text = self.pickUpRequestDetail.dropAddress
        
        self.pickUpAddressLbl.text = self.pickUpRequestDetail.pickupAddress
        
    }
    
    
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
    
    //MARK:- IBActions
    //MARK:- ===================================================================
    
    
    @IBAction func rejectBtnTapped(_ sender: UIButton) {
        
        //        self.reject_Serive_Call("reject")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func acceptBtnTapped(_ sender: UIButton) {
        
        
        self.accept_Serive_Call("accept")
    }
    
    
    
    @IBAction func startTripbtnTapped(_ sender: UIButton) {
        
        self.pickup_accept_reject_Serive_Call()
        
    }
    
    @IBAction func pickUpRejactbtnTapped(_ sender: UIButton) {
        
        self.pickup_accept_reject_Serive_Call()
        
    }
    
    
    
    @IBAction func proceedBtnTapped(_ sender: UIButton) {
        self.setRatingData()
        
    }
    
    
    
    @IBAction func rejectChangeDestinationTapped(_ sender: UIButton) {
        
        self.accept_change_ChangeLocation("reject")
        
        
    }
    
    
    @IBAction func acceptChangeDestinationTapped(_ sender: UIButton) {
        
        self.accept_change_ChangeLocation("accept")
        
    }
    
    
    
    @IBAction func sendRatingTapped(_ sender: UIButton) {
        
        if self.floatingRatingView.rating == 0{
            
            showToastWithMessage(RatingParameters.ratingAlert)
            
        }else{
            var filtered = [IndexPath]()
            var params = JSONDictionary()
            showLoader()
            params["action"] = "user" as AnyObject
            params["rating"] = self.floatingRatingView.rating as AnyObject
            params["ride_id"] = (CurrentUser.ride_id ?? "") as AnyObject
            //        if driverSharedInstance.pickupDriverDetail.isEmpty{
            //            params["ride_id"] = driverSharedInstance.ride_id as AnyObject
            //        }else{
            //            if let ride_id = driverSharedInstance.pickupDriverDetail[index.row]["_id"] as? String{
            //                params["ride_id"] = ride_id as AnyObject
            //            }
            //        }
            printlnDebug(params)
            
            ServiceClass.rateApi(params, completionHandler: { (data) in
                
                hideLoader()
                
                if let code = data["statusCode"].int, code == 200{
                    
                    leavePickup()
                    
                }
            })
            
//            ServiceClass.rateApi(params) { (success: JSONDictionary) in
//                
//                printlnDebug(success)
//                
//                hideLoader()
//                
//                leavePickup()
//                
//                //            if CurrentUser.ridestate?.lowercased() == RequestType.valet{
//                //
//                //                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ride_State)
//                //                driverSharedInstance.ride_id = ""
//                //                leavePickup()
//                //
//                //            }else{
//                //
//                //                driverSharedInstance.pickupDriverDetail.remove(at: self.index.row)
//                //
//                //                if !driverSharedInstance.pickupDriverDetail.isEmpty{
//                //
//                //                    filtered = driverSharedInstance.selectedIndexPath.filter({$0 != self.index})
//                //                    driverSharedInstance.selectedIndexPath = filtered
//                //
//                //                    self.delegate.reloadeTripData()
//                //                    self.dismiss(animated: true, completion: nil)
//                //                    driverSharedInstance.ride_id = ""
//                //                    
//                //                    
//                //                }else{
//                //                    
//                //                    UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ride_State)
//                //                    driverSharedInstance.ride_id = ""
//                //                    
//                //                    leavePickup()
//                //                }
//                //            }
//                
//            }
        }
    }
    
}


//MARK:- Goto viewcontrollers
//MARK:- ===================================================================

extension RequestRidePopUpViewController {
    
    
    func goToOnTripScreen(_ info: JobDetailsModel){
        
        
        let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnTripVC") as! OnTripVC
        
        obj.tripDetail = self.jobDetails
        let navController = UINavigationController(rootViewController: obj)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
}


//MARK:- Call webservices methods
// MARK: ===================================================================


extension RequestRidePopUpViewController {
    
    
    
    func accept_Serive_Call(_ action: String){
        
        var params = [String: AnyObject]()
        
        if let ride_uid = self.jobDetails.ride_id{
            params["ride_id"] = ride_uid as AnyObject
        }
        
        if self.currentLoc != nil{
            params["current_lat"] = self.currentLoc?.coordinate.latitude as AnyObject
            params["current_lon"] = self.currentLoc?.coordinate.longitude as AnyObject
        }
        
        SocketServices.socketEmitAcceptRide(params: params)
        
        SocketServices.socketOnAcceptRide_res { (success, data) in
            
            if success{
            
                let result = data["result"]
                
                self.jobDetails = JobDetailsModel.init(with: result)
                
                
                let tripDetailVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "TripDetailViewController") as! TripDetailViewController
                UserDefaults.save(RequestType.valet as AnyObject, forKey: NSUserDefaultKey.ride_State)
                UserDefaults.save(RequestType.valet as AnyObject, forKey: NSUserDefaultKey.R_TYPE)
                
                tripDetailVC.tripDetail = self.jobDetails
                let navController = UINavigationController(rootViewController: tripDetailVC)
                navController.isNavigationBarHidden = true
                navController.automaticallyAdjustsScrollViewInsets=false
                
                mfSideMenuContainerViewController.centerViewController = navController

            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func accept_change_ChangeLocation(_ action: String){
        
        var params = JSONDictionary()
        
//        if let rideId = self.userInfo.ride_id{
//            
            params["ride_id"] = (CurrentUser.ride_id ?? "") as AnyObject
//
//        }
        if let d_id = CurrentUser.user_id{
            
            params["driver_id"] = d_id as AnyObject
            
        }
        if let drop = self.userInfo.dropTable{
            params["drop_locations"] = drop as AnyObject 
        }
        
        
        params["estimated_distance"] = "10" as AnyObject
        params["estimated_time"] = "10" as AnyObject
        params["cur_total_fare"] = "33" as AnyObject
        params["action"] = action as AnyObject
        
        if action == "accept"{
            params["cd_status"] = "2" as AnyObject
            
        }else{
            params["cd_status"] = "3" as AnyObject
        }
        printlnDebug(params)
        
        SocketServices.socketEmitAcceptChangeLocation(params: params)
    }
    
    
    
    
    func pickup_accept_reject_Serive_Call(){
        
        var params = [String:Any]()
        
        
            params["ride_id"] = self.pickUpRequestDetail.ride_id
        
        if self.currentLoc != nil{
            
            params["current_lat"] = self.currentLoc?.coordinate.latitude
            params["current_lon"] = self.currentLoc?.coordinate.longitude
            
        }
        
//        if let d_id = CurrentUser.user_id , let name = CurrentUser.full_name, let contact = CurrentUser.mobile, let uid = CurrentUser.uid{
//            
//            params["driver_id"] = d_id as AnyObject
//            params["driver_name"] = name as AnyObject
//            params["driver_contact"] = contact as AnyObject
//            params["driver_uid"] = uid as AnyObject
//            
//        }
//        
//        if let img = CurrentUser.user_image{
//            
//            params["driver_image"] = img as AnyObject
//        }
        
        
        if let seats = CurrentUser.seating{
            
            params["seats_available"] = seats - 1
            self.seatAvailable = seats - 1

//            if action == "accept"{
//                
//                params["seats_available"] = (Int(seats)! - 1) as AnyObject
//                self.seatAvailable = "\(Int(seats)! - 1)"
//                
//            }else{
//                
//                params["seats_available"] = seats as AnyObject
//                self.seatAvailable  = seats
//                
//            }
        }
        
        printlnDebug(params)

        showLoader()
        
        SocketServices.pickup_RideRequest_Accept(params: params)
        
        SocketServices.pickup_RideRequest_Accept_res { (success, json) in
            
            printlnDebug(json)
            
        }
//        pickupActionApi(params) { (success) in
//            printlnDebug(success)
//            UserDefaults.save(self.seatAvailable as AnyObject, forKey: NSUserDefaultKey.SEATING)
//            if action == "accept"{
//                hideLoader()
//                
//                UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.ride_State)
//                UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.R_TYPE)
//                UserDefaults.save(DriverType.pickup_driver as AnyObject, forKey: NSUserDefaultKey.D_TYPE)
//                
//                let tripDetailVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "PickUpTripDetail") as! PickUpTripDetail
//                tripDetailVC.tripDetail = success
//                if let result = success["result"] as? JSONDictionaryArray{
//                    driverSharedInstance.pickupDriverDetail = result
//                }
//                printlnDebug(driverSharedInstance.pickupDriverDetail)
//                let navController = UINavigationController(rootViewController: tripDetailVC)
//                navController.isNavigationBarHidden = true
//                navController.automaticallyAdjustsScrollViewInsets=false
//                mfSideMenuContainerViewController.centerViewController = navController
//            }
//            else{
//                hideLoader()
//                
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//        
//        self.dismiss(animated: true, completion: nil)
    }
    
}




// MARK:- Table View DataSource and Delegate Life Cycle Methods
// MARK: ===================================================================


extension RequestRidePopUpViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row != 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickDropCell", for: indexPath) as! PickDropCell
            
            if indexPath.row == 0{
                if let pick = self.jobDetails.pickupAddress{
                    cell.locationTypeLabel.text = PICK.localized
                    cell.locationAddressLabel.text = pick
                }
            }
            else{
                cell.locationTypeLabel.text = DROP.localized
                
                cell.locationAddressLabel.text = self.jobDetails.dropAddress
            }
            // cell.populateCell(withLocation: "209, Pandan Gardens, Singapore, 609339")
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestSummaryCell", for: indexPath) as! RequestSummaryCell
            
            if let fare = self.jobDetails.total_fare{
                cell.fareLbl.text = FAIR.localized + "$" + fare
            }
            
            if let type = self.jobDetails.vehicleType{
                cell.vehicleTypeLbl.text = VEHICLE_TYPE_POPUP.localized + type.capitalized
            }
            if let no = self.jobDetails.vehicleNo{
                cell.vehicleNoLbl.text = VEHICLE_NO_POPUP.localized + no.capitalized
            }
            if let model = self.jobDetails.vehicleModel{
                cell.vehicleModelLbl.text = VEHICLE_MODEL_POPUP.localized + model.capitalized
            }

            if let p_mode = self.jobDetails.p_mode, p_mode.lowercased() == "cash" {
                cell.paymentModeLbl.text = PAYMENT_TYPE_POPUP.localized + p_mode.capitalized
            } else {
            
                cell.paymentModeLbl.text = PAYMENT_TYPE_POPUP.localized + CARD.localized.capitalized

            }

            cell.dateLbl.text = DATE_POPUP.localized + self.requst_date
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            
            if let pick = self.jobDetails.pickupAddress{
                
                let pick = pick.boundingRect(with: CGSize(width: screenWidth-40-(screenWidth / 5), height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 13)!], context: nil)
                let height = pick.height + 60
                printlnDebug(height)
                return height
            }
        }
        else if indexPath.row == 1{
            
            let pick = self.address.boundingRect(with: CGSize(width: screenWidth-40-(screenWidth / 4), height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 13)!], context: nil)
            let height = pick.height + 60
            printlnDebug(height)
            return height
            
        }
        
        return 200
    }
}


extension RequestRidePopUpViewController: CLLocationManagerDelegate{
    
    // location manager delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLoc = manager.location
    }
    
    
    
}



// MARK:
// MARK: PickDrop Table View Cell

class PickDropCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    // MARK: Table View Cell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Private Methods
    func populateCell(withLocation address: String) {
        
        self.locationTypeLabel.text = PICK.localized.uppercased()
        self.locationAddressLabel.text = address
    }
}


class RequestSummaryCell: UITableViewCell{
    
    
    @IBOutlet weak var fareLbl: UILabel!
    @IBOutlet weak var vehicleTypeLbl: UILabel!
    @IBOutlet weak var vehicleNoLbl: UILabel!
    @IBOutlet weak var vehicleModelLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var paymentModeLbl: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
            self.fareLbl.text = FAIR.localized
            self.vehicleTypeLbl.text = VEHICLE_TYPE_POPUP.localized
            self.vehicleNoLbl.text = VEHICLE_NO_POPUP.localized
            self.vehicleModelLbl.text = VEHICLE_MODEL_POPUP.localized
            self.dateLbl.text = DATE_POPUP.localized
            self.summaryLabel.text = SUMMARY.localized.uppercased()
    }
    
}
