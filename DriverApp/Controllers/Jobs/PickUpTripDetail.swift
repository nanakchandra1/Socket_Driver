//
//  TripDetailViewController.swift
//  CustomSlider
//
//  Created by Aakash Srivastav on 10/26/16.
//  Copyright © 2016 AppInventiv. All rights reserved.

import UIKit
import GoogleMaps

enum RiderDetailShowHide{
    case show, hide
}

class PickUpTripDetail: UIViewController,RelodeTripDetailDataDelegate {
    
    // MARK: ========
    // MARK: IBOulets
    
    @IBOutlet weak var navigtionView: UIView!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var rideDetailview: UIView!
    @IBOutlet weak var rideDetailLbl: UILabel!
    @IBOutlet weak var remainingDropsTableView: UITableView!
    @IBOutlet weak var remainingDropsTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ridedetailbottomConstraint:
    NSLayoutConstraint!
    @IBOutlet weak var stopAcceptReqstBtn: UIButton!
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var stopAcceptingRequestLabel: UILabel!
    
    
    
    
    // MARK: =========
    // MARK: Variables
    lazy var locationManager = CLLocationManager()
    var remainingDropLocations = 3
    var remainingTableViewRowHeight: CGFloat = (IsIPad ? 70:30)
    var tripDetail = [String: AnyObject]()
    var pick_drop_Loc = [String: String]()
    var dropLoc = [String]()
    var currentLoc = [String: String]()
    var detailShowHide = RiderDetailShowHide.hide
    var cameraMap:Zoom_in_Zoom_Out = .zoomin
    var status = ""
    var driver_current_loc: CLLocationCoordinate2D?
    var pickupTripDetail = [PickupRequestModel]()
    
    
    // MARK: =================================
    // MARK: ViewController Life Cycle Methods
    override func viewDidLoad() {
        
        self.navigationTitleLabel.text = TRIP_DETAILS.localized
        self.stopAcceptingRequestLabel.text = STOP_ACCEPTING_REQUEST.localized
        self.rideDetailLbl.text = RIDER_DETAILS.localized
        
        super.viewDidLoad()
        self.addSwipeGesture(toView: self.rideDetailview)
        
        printlnDebug(driverSharedInstance.pickupDriverDetail)
        self.navigtionView.setMenuButton()
        //hideDropTable()
        
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        UserDefaults.save(DriverType.pickup_driver as AnyObject, forKey: NSUserDefaultKey.D_TYPE)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
    }
    
    
    
    // MARK: IBActions
    //MARK:- ==========================================================
    
    
    
    
    @IBAction func stopAcceptingRequestTapped(_ sender: UIButton) {
        
        
        var params = JSONDictionary()
        
        if CurrentUser.stop_accepting == Status.zero{
            params["status"] = Status.one as AnyObject
            
        }else{
            params["status"] = Status.zero as AnyObject
            
        }
        showLoader()
        stopAcceptingAPI(params, SuccessBlock: { (result: Bool) in
            hideLoader()
            if CurrentUser.stop_accepting == Status.zero{
                UserDefaults.save(Status.one as AnyObject, forKey: NSUserDefaultKey.STOP_ACCEPTING)
                self.stopAcceptReqstBtn.setImage(UIImage(named: "settings_on_btn"), for: UIControlState())
                
            }else{
                UserDefaults.save(Status.zero as AnyObject, forKey: NSUserDefaultKey.STOP_ACCEPTING)
                self.stopAcceptReqstBtn.setImage(UIImage(named: "settings_off_btn"), for: UIControlState())
                
            }
        }) { (error: NSError) in
            hideLoader()
        }
    }
    
    
    // MARK: ===============
    // MARK: Private Methods
    
    func initialSetup() {
        
        self.remainingDropsTableView.dataSource = self
        self.remainingDropsTableView.delegate = self
        self.remainingDropsTableView.register(UINib(nibName: "PickUpTripDetailCell" ,bundle: nil), forCellReuseIdentifier: "PickUpTripDetailCell")
        self.updateMarker()
        hideLoader()
        
    }
    
    
    func updateMarker(){
        
        self.googleMapView.clear()
        printlnDebug(self.driver_current_loc)
        if self.driver_current_loc != nil{
                let marker = GMSMarker()
                    self.googleMapView.camera = GMSCameraPosition(target: self.driver_current_loc!, zoom: 14, bearing: 0, viewingAngle: 15)
                    marker.position = self.driver_current_loc!
                    marker.icon = UIImage(named: "ic_user_map_marker")
                    marker.map = self.googleMapView
                    self.view.layoutIfNeeded()
        }
        for res in driverSharedInstance.pickupDriverDetail{
        
            if let status = res["status"] as? String  {
                
                if status == Status.five{
                    if let drop = res["drop"] as? JSONDictionaryArray{
                        
                        for res in drop{
                            
                            if let lat = res["latitude"],let lon = res["longitude"]{
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2DMake(Double("\(lat)")!, Double("\(lon)")!)
                                marker.icon = UIImage(named: "request_job_location_pin")
                                marker.map = self.googleMapView
                            }
                        }
                    }
                }
            }
        }
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
                    self.remainingDropsTableView.reloadData()
                    self.updateMarker()
                }else{
                    leavePickup()
                }
            }
        }
    }
    
    
    func addSwipeGesture(toView view: UIView) {
        
        let downSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(viewDidSwipe(_:)))
        let upSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(viewDidSwipe(_:)))
        
        downSwipeGestureRecogniser.direction = .down
        upSwipeGestureRecogniser.direction = .up
        view.addGestureRecognizer(downSwipeGestureRecogniser)
        view.addGestureRecognizer(upSwipeGestureRecogniser)
    }
    
    
    func viewDidSwipe(_ swipe: UISwipeGestureRecognizer) {
        
        if swipe.direction == .up && self.detailShowHide == .hide {
            
            self.openRideView()
            
        } else if swipe.direction == .down && self.detailShowHide == .show {
            
            self.closeRideView()
        }
    }
    
    func openRideView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            
            self.detailShowHide = .show
            self.ridedetailbottomConstraint.constant = UIScreen.main.bounds.height - CGFloat(64 + 50)
            self.remainingDropsTableViewBottomConstraint.constant = 0
            
            self.view.layoutIfNeeded()
            self.remainingDropsTableView.reloadData()
            
            }, completion: { (didComplete: Bool) in
                
        })
    }
    
    
    func closeRideView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.detailShowHide = .hide
            self.ridedetailbottomConstraint.constant = 0
            self.remainingDropsTableViewBottomConstraint.constant = -227
            self.view.layoutIfNeeded()
            
            }, completion: { (didComplete: Bool) in
                
        })
    }
    
    
    func cancelBtnTapped(_ sender: UIButton){
        
        if let indexPath = sender.tableViewIndexPath(self.remainingDropsTableView){
            let data = driverSharedInstance.pickupDriverDetail[indexPath.row]
            _ = data["status"] as? String ?? ""
            if sender.titleLabel?.text == "COMPLETE TRIP"{
            //if status == Status.five{
                self.completeTrip(indexPath)
            }else{
                self.startTrip(indexPath)
            }
        }
    }
    
    
    
    func startBtnTapped(_ sender: UIButton){
        
        if let indexPath =   sender.tableViewIndexPath(self.remainingDropsTableView){
            if driverSharedInstance.selectedIndexPath.contains(indexPath){
                self.chooseMap(indexPath)
            }else{
                let alert = UIAlertController(title: "", message: alertMessageTrip, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                    self.cancelTrip(indexPath: indexPath)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func startNaviBtnTapped(_ sender: UIButton){
    
        if let indexPath =   sender.tableViewIndexPath(self.remainingDropsTableView){
            let data = driverSharedInstance.pickupDriverDetail[indexPath.row]
            printlnDebug(data)
            self.chooseMap(indexPath)
        }
    }
    
    
    func cancelTrip(indexPath: IndexPath){

        var params = JSONDictionary()
        
        params["action"] = "cancel" as AnyObject
        params["cancelled_by"] = "driver" as AnyObject
        params["reason"] =  "I want to cancel" as AnyObject
        if let id = driverSharedInstance.pickupDriverDetail[indexPath.row]["_id"] as? String{
            
            params["ride_id"] = id as AnyObject
            
        }
        
        showLoader()
        rideActionApi(params) { (result: JSONDictionary) in
            hideLoader()
            
            self.regainStateForPickUpDriver(RegainRideActionString.pickup_driver)
//            driverSharedInstance.pickupDriverDetail.removeAtIndex(indexPath.row)
//            if driverSharedInstance.pickupDriverDetail.count == 0{
//                leavePickup()
//            }else{
//                self.remainingDropsTableView.reloadData()
//            }
        }
        
    }
    
    func startTrip(_ indexPath: IndexPath){
        
        var params = [String: AnyObject]()
        showLoader()
        if let id = driverSharedInstance.pickupDriverDetail[indexPath.row]["_id"] as? String{
            params["ride_id"] = id as AnyObject
        }
        
        params["actual_distance"] = "10" as AnyObject
        params["actual_time"] = "10" as AnyObject
        params["current_lat"] = locationManager.location?.coordinate.latitude as AnyObject
        params["current_lon"] = locationManager.location?.coordinate.longitude as AnyObject
        
        printlnDebug(params)
        startPickTripApi(params) { (result:  [String : AnyObject]) in
            
//            printlnDebug(driverSharedInstance.pickupDriverDetail)
//            printlnDebug(result)
            self.regainStateForPickUpDriver(RegainRideActionString.pickup_driver)

            hideLoader()
//            driverSharedInstance.selectedIndexPath.append(indexPath)
//            self.remainingDropsTableView.reloadData()
        }
    }
    
    
    
    func completeTrip(_ indexPath: IndexPath) {
        
        var params = [String: AnyObject]()
        printlnDebug(self.tripDetail)
        
        showLoader()
        if let id = driverSharedInstance.pickupDriverDetail[indexPath.row]["_id"] as? String{
            params["ride_id"] = id as AnyObject
        }
        
        params["actual_distance"] = "10" as AnyObject
        params["actual_time"] = "10" as AnyObject
        params["current_lat"] = locationManager.location?.coordinate.latitude as AnyObject
        params["current_lon"] = locationManager.location?.coordinate.longitude as AnyObject
        
        
        printlnDebug(params)
        completePickUpTripApi(params) { (result: [String : AnyObject]) in
            printlnDebug(result)
            hideLoader()
            if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController, viewController != nil {
                
                let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestRidePopUpViewController") as! RequestRidePopUpViewController
                popUp.modalPresentationStyle = .overCurrentContext
                
                if let res = result["result"] as? JSONDictionary, let p_mode = res["p_mode"] as? String{
                    if p_mode.lowercased() == "cash"{
                        popUp.paymentType = .cash
                    }
                    else{
                        popUp.paymentType = .card
                    }
                    popUp.selectedPopUp = .payment
//                    popUp.userInfo = res
                    popUp.index = indexPath
                    popUp.delegate = self
                }
                getMainQueue({
                    viewController!.present(popUp, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    
    func chooseMap(_ indexPath: IndexPath){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "GoogleMap", style: .default , handler:{ (UIAlertAction)in
            self.openGoogleMap(indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "WazeMap", style: .default , handler:{ (UIAlertAction)in
            self.openWazeMap(indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            
            
        }))
        self.present(alert, animated: true, completion: {
        })
        
        
    }
    
    func openGoogleMap(_ indexPath: IndexPath){
        
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let result = driverSharedInstance.pickupDriverDetail[indexPath.row]
            if let status = result["status"] as? String  {
                
                if status == Status.five{
                    if let drop = result["drop"] as? JSONDictionaryArray{
                        let res = drop.first

                        if let lat = res!["latitude"],let lon = res!["longitude"]{
                            UIApplication.shared.openURL(URL(string:
                                "comgooglemaps://?saddr=&daddr=\(lat),\(lon)&directionsmode=driving")!)
                        }
                    }
                }else{
                    
                    if let pick = result["pickup"] as? JSONDictionary, let lat = pick["latitude"],let lon = pick["longitude"]{
                        
                        UIApplication.shared.openURL(URL(string:
                            "comgooglemaps://?saddr=&daddr=\(lat),\(lon)&directionsmode=driving")!)
                    }
                }
            }
        } else {
            let url  = URL(string: URLName.real_Time_navigate_URL)
            if UIApplication.shared.canOpenURL(url!) == true  {
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    
    func openWazeMap(_ indexPath: IndexPath){
        
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            // Waze is installed. Launch Waze and start navigation
            let result = driverSharedInstance.pickupDriverDetail[indexPath.row]
            if let status = result["status"] as? String  {
                
                if status == Status.five{
                    if let drop = result["drop"] as? JSONDictionaryArray{
                        let res = drop.first
                        if let lat = res!["latitude"],let lon = res!["longitude"]{
                            let urlStr: String = "waze://?ll=\(lat),\(lon)&navigate=yes"
                            UIApplication.shared.openURL(URL(string: urlStr)!)
                        }
                    }
                }else{
                    if let pick = result["pickup"] as? JSONDictionary, let lat = pick["latitude"],let lon = pick["longitude"]{
                        
                        let urlStr: String = "waze://?ll=\(lat),\(lon)&navigate=yes"
                        UIApplication.shared.openURL(URL(string: urlStr)!)
                    }
                }
            }
            }
        else {
            // Waze is not installed. Launch AppStore to install Waze app
            UIApplication.shared.openURL(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
        
        
    }
    
    
    
    func reloadeTripData() {
        self.closeRideView()
        self.remainingDropsTableView.reloadData()
    }
    
    //    func completeTripTapped(sender: UIButton){
    //
    //
    //    }
}


// MARK: ================================
// MARK: LocationManager Delegate Methods

extension PickUpTripDetail: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.driver_current_loc = (manager.location?.coordinate)!
        if self.cameraMap == .zoomin{
            self.cameraMap = .zoomout
            updateMarker()
        }
    }
}

// MARK: =========================================
// MARK: TableView Delegate and DataSource Methods

extension PickUpTripDetail: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return driverSharedInstance.pickupDriverDetail.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickUpTripDetailCell", for: indexPath) as! PickUpTripDetailCell
        delay(0.1) {
            
            cell.setUpView()
            
        }
        
        if let status = driverSharedInstance.pickupDriverDetail[indexPath.row]["status"] as? String  {
            
            self.status = status
            if self.status == Status.five{
                driverSharedInstance.selectedIndexPath.append(indexPath)
            }
        }
        
        if self.status == Status.five {
            cell.showCompleteTripBtn(false)
        }else{
            cell.showCompleteTripBtn(true)
        }
        
        cell.cancelBtn.addTarget(self, action: #selector(self.cancelBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.startBtn.addTarget(self, action: #selector(self.startBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.startNavigationBtn.addTarget(self, action: #selector(self.startNaviBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.userContactNo.addTarget(self, action: #selector(self.phoneBtnTapped(_:)), for: UIControlEvents.touchUpInside)


        
        //cell.completeTripBtn.addTarget(self, action: #selector(self.completeTripTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        printlnDebug(driverSharedInstance.pickupDriverDetail)
        
        var result = driverSharedInstance.pickupDriverDetail[indexPath.row]
        
        if let name = result["user_name"] as? String{
            cell.userName.text = name
        }
        if let phone = result["user_contact"] as? String{
            cell.userContactNo.setTitle(phone, for: UIControlState())
        }

        if let image = result["user_image"] as? String{
            let imageUrlStr = imgUrl + image
            if let imageUrl = URL(string: imageUrlStr){
                cell.userImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
        
        
        if let pick = result["pickup"] as? [String: AnyObject], let address = pick["address"] as? String{
            cell.fromAddressLabel.text = address
        }
        if let drop = result["drop"] as? [[String: AnyObject]]{
            if let address = drop[0]["address"] as? String{
                self.pick_drop_Loc["drop"] = address
                printlnDebug(self.pick_drop_Loc)
                cell.toAddressLabel.text = address
                
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 226
    }
    
    
     func phoneBtnTapped(_ sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(self.remainingDropsTableView) else{return}
        var result = driverSharedInstance.pickupDriverDetail[indexPath.row]
        printlnDebug(result)
        if let phone = result["user_contact"] as? String{
            if phone != ""{
                let phoneNumber = phone
                let phone = "telprompt://" + phoneNumber.replacingOccurrences(of: " ", with: "")
                if let url = URL(string: phone){
                    UIApplication.shared.openURL(url)
                }
            }

        }

        
    }

}

