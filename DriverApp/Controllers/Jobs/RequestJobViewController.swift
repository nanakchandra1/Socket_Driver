//
//  RequestJobViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON

var normal_Timer = Timer()
var timerState = true

class RequestJobViewController: BaseViewController {
    
    
// MARK: IBOutlets and Variables
//MARK:- ======================================================================
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var pickupBtn: UIButton!
    @IBOutlet weak var valetBtn: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var requestAJobBtn: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var forValetBgView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var forPickupBgView: UIView!
    @IBOutlet weak var valetLbl: UILabel!
    @IBOutlet weak var pickupLbl: UILabel!
    @IBOutlet weak var pickupViewBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var setAvailabilityBtn: UIButton!
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    var locationManager:CLLocationManager!
    var currentLoc: CLLocation?
    var ride_id = ""
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var mapZoomTimer = Timer()
    var isShow = false
    var jobDetails = JobDetailsModel()
    
// MARK: View Controller Life Cycle Methods
// MARK:- ======================================================================

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.regainRideState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.regainRideState), name: .connetSocketNotificationName, object: nil)
        
        self.navigationTitleLabel.text = REQUEST_A_JOB.localized
        self.valetLbl.text = AVAILABLE_FOR_VALET.localized
        self.pickupLbl.text = AVAILABLE_FOR_PICKUP.localized
        self.setAvailabilityBtn.setTitle(SET_AVAILABILTY.localized.capitalized, for: .normal)
        self.requestAJobBtn.setTitle(REQUEST_A_JOB.localized, for: .normal)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.requestAJobBtn.isHidden = true
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 10
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        self.locationManager.delegate = self
        self.initialSetup()
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //gradientColor(self.gradientView)
        
        //self.setAvailabilityBtn.layer.cornerRadius = 3
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        show_GPS_prompt()
        
        self.pickupViewBottomConstant.constant = -screenHeight / 2
        self.setAvailabilityBtn.isHidden = false
        
        self.mapZoomTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.setMapZoomLevel), userInfo: nil, repeats: true)
        

        
//        if CurrentUser.ridestate != nil{
//            if CurrentUser.r_type == RequestType.pickup{
//                if CurrentUser.d_type == DriverType.pickup_driver{
//                    
//                    self.regainStateForPickUpDriver(RegainRideActionString.pickup_driver)
//                    
//                }else{
//                    self.regainState(RegainRideActionString.pickup_user)
//                }
//            }else{
//                self.regainState(RegainRideActionString.driver)
//            }
//        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //self.updateLocation()
        
//        if timerState {
//            
//            self.updateLocation()
//            
//            normal_Timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
//            
//            timerState = false
//        } else {
//            normal_Timer.invalidate()
//        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.mapZoomTimer.invalidate()
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
// MARK: IBActions
//MARK:- ======================================================================
    
    @IBAction func setAvailabilityBtnTapped(_ sender: UIButton) {
        
        self.pickupViewBottomConstant.constant = 8
        UIView.animate(withDuration: 0.5, animations: {
            self.setAvailabilityBtn.isHidden = true
            self.view.layoutIfNeeded()
            
        }) 
        
    }
    
    
    @IBAction func valetSwitchButtonTapped(_ sender: UIButton) {
        
        
        self.valetBtn.isSelected = !self.valetBtn.isSelected
        
        if !self.valetBtn.isSelected{
            
            setStatusAction("0" ,valet : "1" )
            
            self.pickupBtn.isSelected = true
            
        }else{
            
            if !self.pickupBtn.isSelected{
                
                setStatusAction("1" ,valet : "1" )
                
            }else{
                
                setStatusAction("0" ,valet : "0" )
            }
        }
    }
    
    @IBAction func pickupSwitchButtonTapped(_ sender: UIButton) {
        
        sender.isSelected = !self.pickupBtn.isSelected
        
        guard isNetworkAvailable() else{
            return
        }
        showLoader()
        
        guard let type = CurrentUser.type else {return}
        
        if type.count == 1{
            
            if type.first == "pickup"{
                let params = ["pickup":self.pickupBtn.isSelected ? "0":"1","valet":"0"] as JSONDictionary
                
                self.setStatus(with: params, sender: sender)
            }
            else{
                let params = ["pickup":"0","valet":self.pickupBtn.isSelected ? "0":"1"] as JSONDictionary
                
                
                self.setStatus(with: params, sender: sender)
            }
        }
        else if type.count == 2{
            
            if !self.pickupBtn.isSelected{
                
                setStatusAction("1" ,valet : "0" )
                
                self.valetBtn.isSelected = true
            }else{
                
                if !self.valetBtn.isSelected{
                    
                    setStatusAction("0" ,valet : "1" )
                    
                }else{
                    
                    setStatusAction("0" ,valet : "0" )
                }
            }
            
        }
    }
    
    
    
    
// MARK: Private Methods
//MARK:- ==========================================================
    
    
    func addGradient(){
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = self.gradientView.frame.size
        gradient.colors = [UIColor.clear.cgColor,UIColor.black.withAlphaComponent(1).cgColor] //Or any colors
        self.gradientView.layer.addSublayer(gradient)
        
    }
    
    func initialSetup() {
        
        self.navigationView.setMenuButton()
        
        self.socketOnRideRequest()
        self.socket_On_Pickup_Ride_Request()
        
        guard let onlinr_for = CurrentUser.online_for else{return}
        guard let type = CurrentUser.type else{return}
        
        if type.count == 1{
            if type.first?.lowercased() == "pickup"{
                self.forValetBgView.isHidden = true
                self.pickupLbl.text = AVAILABLE_FOR_PICKUP.localized
            }
            else{
                self.forValetBgView.isHidden = true
                self.pickupLbl.text = AVAILABLE_FOR_VALET.localized
            }
        }
        else{
            if onlinr_for == "1"{
                self.pickupBtn.isSelected = false
                self.valetBtn.isSelected = true
            }
            else if onlinr_for == "2"{
                self.pickupBtn.isSelected = true
                self.valetBtn.isSelected = false
            }
            else{
                self.pickupBtn.isSelected = true
                self.valetBtn.isSelected = true
            }
        }
        
        self.gradientView.isUserInteractionEnabled = false
        self.requestAJobBtn.layer.borderWidth = 1
        self.requestAJobBtn.layer.borderColor = UIColor.gray.cgColor
        self.requestAJobBtn.layer.cornerRadius = 3
        // Customising Image view
        self.userImageView.layer.borderWidth = 2
        self.userImageView.layer.borderColor = UIColor(red: 219/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.userImageView.clipsToBounds = true
        
        // self.mapView.delegate = self
        
        if let name = CurrentUser.full_name{
            self.userNameLabel.text = name
        }
        
        if let imageName = CurrentUser.user_image{
            
            let imageUrlStr = imgUrl+imageName
            print(imageUrlStr)
            
            if let imageUrl = URL(string: imageUrlStr){
                self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_placeholder"))
            }
        }
    }
    
    
    func show_Hide_availabilityBtn(){
    
        self.pickupViewBottomConstant.constant = -screenHeight / 2
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: { (true) in
                self.setAvailabilityBtn.isHidden = false
                
        })
        
    }
    
    func show_GPS_prompt(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                printlnDebug("No access")
                gotoGPSPopup()
            case .restricted, .denied:
                gotoGPSPopup()
                self.mapView.clear()
            case .authorizedAlways, .authorizedWhenInUse:
                printlnDebug("Access")
            }
        } else {
            gotoGPSPopup()
            self.mapView.clear()
        }
    }
    
    
    func displayContentController(_ content: UIViewController) {
        addChildViewController(content)
        self.view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    
    
    func regainStateForPickUpDriver(_ actionStr: String){
        
        var params = JSONDictionary()
        params["action"] = actionStr as AnyObject
        showLoader()
        regainRideStateAPI(params) { (infoData:JSONDictionary) in
            hideLoader()
            if let result = infoData["result"] as? JSONDictionaryArray{
                hideLoader()
                driverSharedInstance.pickupDriverDetail = result
                if !driverSharedInstance.pickupDriverDetail.isEmpty{
                    self.gotoPickUpTripDetail()
                }
            }
        }
    }
    
    func regainRideState(){
    
        if let rideId = CurrentUser.ride_id, !rideId.isEmpty{
            
            SocketServices.socketEmitRegainState(params: ["ride_id" : rideId as AnyObject])
            
            SocketServices.socketOnRegainState_res(completion: { (success, data) in
                
                if success{
                    
                    printlnDebug(data)
                    let result = data["result"]
                    
                    self.jobDetails = JobDetailsModel.init(with: result)
                    
                    switch self.jobDetails.status{
                        
                    case 1:
                        
                        self.goToTripDetailScreen(self.jobDetails)
                        
                    case 5:
                        
                        self.goToOnTripScreen(self.jobDetails)
                        
                    case 6:
//                        if self.jobDetails.user_rating > 0{
//                        
//                            gotoHomeVC()
//                            
//                        } else {
                            self.ShowPaymentPopUp(self.jobDetails)

//                        }
                    default:
                        break
                    }
                }
            })
        }
    }
    
    func setStatus(with params : JSONDictionary, sender : UIButton){
    
        ServiceClass.setStatusApi(params, completionHandler: { (success) in
       
            
            if !success{
                sender.isSelected = !sender.isSelected
            }
            else{
                self.show_Hide_availabilityBtn()
            }
        })

    }
}


//MARK:- Call webservices methods
//MARK:- ===================================================================

extension RequestJobViewController {
    
    //RequestRide_ON

    func socketOnRideRequest(){
    
        SocketServices.socketOnRideRequest { (success, data) in
            
            if success{
            
                let result = data["result"]
                
                self.jobDetails = JobDetailsModel.init(with: result)
                
                if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
                    if viewController != nil {
                        
                        let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestRidePopUpViewController") as! RequestRidePopUpViewController
                        popUp.jobDetails = self.jobDetails
                        popUp.modalPresentationStyle = .overCurrentContext
                        UserDefaults.save(self.jobDetails.ride_id as AnyObject, forKey: NSUserDefaultKey.ride_id)
                        viewController?.present(popUp, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    
    func socket_On_Pickup_Ride_Request(){
        
        
        SocketServices.socketOn_pickup_RideRequest{ (success, data) in
            
            if success{
                
                let result = data["result"]
                
                let pickuprequestDetail = PickupRequestModel(with: result)
                
                if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
                    if viewController != nil {
                        
                        let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestRidePopUpViewController") as! RequestRidePopUpViewController
                        
                        popUp.pickUpRequestDetail = pickuprequestDetail
                        popUp.selectedPopUp = .pickUpRequest
                        popUp.modalPresentationStyle = .overCurrentContext
                        
                        UserDefaults.save(pickuprequestDetail.ride_id as AnyObject, forKey: NSUserDefaultKey.ride_id)
                        
                        viewController?.present(popUp, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }


    // set availability

    func setStatusAction(_ pickup : String ,valet : String ){
        
        guard isNetworkAvailable() else{
            return
        }
        showLoader()
        
        let params = ["pickup":pickup,"valet":valet] as JSONDictionary
        
        ServiceClass.setStatusApi(params) { (success) in
            
            if !success{
                //                sender.selected = !sender.selected
            }else{
                self.show_Hide_availabilityBtn()
            }        }

    }
    
    
    func updateLocation() {
        
        if self.currentLoc != nil {
            
            let params: [String: AnyObject] = ["latitude": self.currentLoc!.coordinate.latitude as AnyObject, "longitude": self.currentLoc!.coordinate.longitude as AnyObject]
            
            updateLocationAPI(params)
        }
    }
}




//MARK:- Goto viewcontrollers
//MARK:- ===================================================================

extension RequestJobViewController {
    
    func gotoOnrideScreen(_ rideDetail: JobDetailsModel, navigationTitle: String){
        
//        UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.ride_State)
//        UserDefaults.save(state as AnyObject, forKey: NSUserDefaultKey.TRIP_STATE)
        
        
        let onRideVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnRideViewController") as! OnRideViewController
//        onRideVC.rideDetail = rideDetail
        onRideVC.ride_id = self.ride_id
//        onRideVC.status = status
        
        onRideVC.navigationTitleStr = navigationTitle
        let navController = UINavigationController(rootViewController: onRideVC)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets=false
        
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
    func gotoRatingVC(_ rideDetail: JSONDictionary,ride_id: String){
        
        sharedAppdelegate.stausTimer.invalidate()
        let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        obj.tripDetail = rideDetail
        obj.ride_id = ride_id
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
    func gotoOnrideScreen(_ rideDetail: JSONDictionary ,state: String, navigationTitle: String,ride_id: String){
        
        UserDefaults.save(state as AnyObject, forKey: NSUserDefaultKey.TRIP_STATE)
        
        let onRideVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnRideViewController") as! OnRideViewController
        onRideVC.rideDetail = rideDetail
        onRideVC.ride_id = ride_id
        if state.lowercased() == RideStateString.arrivalNow.lowercased(){
           onRideVC.vcState = .arrival
        }else{
            onRideVC.vcState = .onRide

        }
        onRideVC.navigationTitleStr = navigationTitle
        let navController = UINavigationController(rootViewController: onRideVC)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets=false
        
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
    
    func gotoPickUpTripDetail(){
        
        UserDefaults.save(RegainRideActionString.pickup_driver as AnyObject, forKey: NSUserDefaultKey.ride_State)
        UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.ride_State)

        let tripDetailVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "PickUpTripDetail") as! PickUpTripDetail
        let navController = UINavigationController(rootViewController: tripDetailVC)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets=false
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
    
    func goToTripDetailScreen(_ info: JobDetailsModel){
        
        let tripDetailVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "TripDetailViewController") as! TripDetailViewController
        UserDefaults.save(RideStateString.tripDetail as AnyObject, forKey: NSUserDefaultKey.ride_State)
        tripDetailVC.tripDetail = info
        let navController = UINavigationController(rootViewController: tripDetailVC)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        
        mfSideMenuContainerViewController.centerViewController = navController
        
        
    }
    
    
    
    
    func goToOnTripScreen(_ info: JobDetailsModel){
        
        let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnTripVC") as! OnTripVC
        
        UserDefaults.save(RequestType.valet as AnyObject, forKey: NSUserDefaultKey.ride_State)
        
        obj.tripDetail = info
        let navController = UINavigationController(rootViewController: obj)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
    
    
    func gotoGPSPopup(){
        
        if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController, viewController != nil {
            
            let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "LoactionPopUpVC") as! LoactionPopUpVC
            popUp.modalPresentationStyle = .overCurrentContext
            
            
            getMainQueue({
                viewController!.present(popUp, animated: true, completion: nil)
            })
        }
    }
    
    func ShowPaymentPopUp(_ result: JobDetailsModel){
        
        if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
            if viewController != nil {
                
                let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestRidePopUpViewController") as! RequestRidePopUpViewController
                popUp.modalPresentationStyle = .overCurrentContext
                
                if result.p_mode.lowercased() == "cash"{
                    popUp.paymentType = .cash
                }
                else{
                    popUp.paymentType = .card
                }
                
                popUp.selectedPopUp = .payment
                popUp.jobDetails = result
                //                    UserDefaults.save(RequestType.valet as AnyObject, forKey: NSUserDefaultKey.ride_State)
                
                getMainQueue({
                    viewController!.present(popUp, animated: true, completion: nil)
                })
            }
        }
        
    }
    
}



// MARK: CLLocation manager Delegate Life Cycle Methods
// MARK: ======================================================================

extension RequestJobViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.currentLoc = manager.location
        
        if self.zoomState == .zoomin{
            self.setMapZoomLevel()
            self.zoomState = .zoomout
        }
        
        self.updateLocation(location: manager.location!)
    }
    
    func updateLocation(location: CLLocation){
        
        var params = JSONDictionary()
        params["current_lat"] = location.coordinate.latitude as AnyObject
        params["current_lon"] = location.coordinate.longitude as AnyObject
        
        SocketServices.curr_updateLocationOnride(params: params)
        SocketServices.curr_update_Location_on_trip_res { (success, json) in
            printlnDebug(json)
        }
    }

    
    func setMapZoomLevel(){
        
        if self.currentLoc != nil {
            
            self.mapView.clear()
            self.mapView.camera = GMSCameraPosition(target: self.currentLoc!.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake((self.currentLoc!.coordinate.latitude), (self.currentLoc!.coordinate.longitude))
            marker.icon = UIImage(named: "ic_user_map_marker")
            marker.map = self.mapView
            
        }
    }
}

