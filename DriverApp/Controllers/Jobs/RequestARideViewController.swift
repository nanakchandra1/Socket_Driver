//
//  RequestARideViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/21/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


enum Zoom_in_Zoom_Out{
    case zoomin, zoomout
}

var isvehecleAdd = true
var sdeletedVehicle = 0

enum VehecleTypeSelection{
    
    case car, bike
    
}

protocol SetPaymentModeDelegate {
    
    func setPaymentMode(_ paymentMode: String, paymentImage: String)
}

class RequestARideViewController: UIViewController {
    
    
    // MARK: Enums
    enum LocationAction {
        case add
        case edit
    }
    
    enum DictType {
        
        case pick
        case drop
    }
    
    
    // MARK:- IBOutlets
    //MARK:- ===================================================================
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var bookBtn: UIButton!
    
    @IBOutlet weak var rideView: UIView!
    @IBOutlet weak var bottomLayoutConstraintOfRideView: NSLayoutConstraint!
    @IBOutlet weak var rideViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pickUpDropOffTableView: UITableView!
    
    @IBOutlet weak var tripFareLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var pickerOuterView: UIView!
    @IBOutlet weak var vehivleNameLabel: UILabel!
    
    @IBOutlet weak var gpsOuterView: UIView!
    @IBOutlet weak var gpsView: UIView!
    
    @IBOutlet weak var pickUpDotView: UIView!
    @IBOutlet weak var pickUpAddressLabel: UILabel!
    
    @IBOutlet weak var carTypeBgView: UIView!
    @IBOutlet weak var carTypeImg: UIImageView!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var carTypeBtn: UIButton!
    
    @IBOutlet weak var bikeTypeBgView: UIView!
    @IBOutlet weak var bikeTypeImg: UIImageView!
    @IBOutlet weak var bikeLbl: UILabel!
    @IBOutlet weak var bikeTypeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var totalFareLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var pickUpButton: UIButton!
    
    @IBOutlet weak var turnOnGPSLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var turnGPSDescLabel: UILabel!
    
    
    
    // MARK: Variables
    var numberOfLocations = 1
    var dropLocationDict: [String: AnyObject] = [:]
    var pickLocationDict: [String: AnyObject] = [:]
    var tappedIndex = -1
    var action: LocationAction!
    var dictType: DictType!
    var locationManager:CLLocationManager!
    var vehicleDetails = JSONDictionaryArray()
    var isPickedUpLoc = true
    lazy var pickerView = UIPickerView()
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var index: Int?
    var cameraPosition = true
    var currenSelected = 0
    var currenLat_long: CLLocationCoordinate2D?
    var ride_id = ""
    var status = false
    let timeInterval:TimeInterval = 1.0
    let timerEnd:TimeInterval = 10.0
    var timeCount:TimeInterval = 0
    var selectedVehicleType = VehecleTypeSelection.car
    var estimatedDistance : Float = 0.0
    var estimatedTime = "0"
    var destinationMarker = GMSMarker()
    var destinationCoordinate: CLLocationCoordinate2D?
    var mapGesture = true
    var isShow = false

    
    lazy var pickerDoneView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    lazy var pickDoneButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    
    // MARK: Constants
    
    
    
    
    // MARK: View Controller Life Cycle Methods
    //AMRK:- ======================================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initialSetup()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        self.pickerView.center = self.pickerOuterView.center
        self.pickerDoneView.center.x = self.pickerView.center.x
        self.pickerDoneView.center.y = self.pickerView.frame.origin.y-20
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        self.show_GPS_prompt()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        super.viewDidAppear(animated)
        
        self.addSwipeGesture(toView: self.rideView)
        self.cameraPosition = true
        
    }
    
    
    
    // MARK: IBAction
    //MARK:- ======================================================================
    
    
    @IBAction func bookBtnTapped(_ sender: UIButton) {
        
        self.requestARide()
        printlnDebug("Book btn Tapped")
    }
    
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        
        self.displayShareSheet("")
    }
    
    @IBAction func openPickerBtnTapped(_ sender: UIButton) {
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerOuterView.isHidden = false
    }
    
    
    @IBAction func gpsSettingsBtnTapped(_ sender: UIButton) {
        
        self.turn_GPS_ON()
        self.gpsView.isHidden = true
        self.gpsOuterView.isHidden = true
    }
    
    @IBAction func gpsOkBtnTapped(_ sender: UIButton) {
        
        self.gpsView.isHidden = true
        self.gpsOuterView.isHidden = true
    }
    
    
    @IBAction func pickUpTapped(_ sender: UIButton) {
        self.action = .edit
        self.tappedIndex = -1
        self.navigate(LocationType.pickUp)
        
    }
    
    @IBAction func carTypeBtnTapped(_ sender: UIButton) {
        
        self.carTypeImg.image = UIImage(named: "booking_circle_filled")
        self.bikeTypeImg.image = UIImage(named: "booking_circle")
        self.selectedVehicleType = VehecleTypeSelection.car
        
    }
    
    @IBAction func bikeTypeBtnTapped(_ sender: UIButton) {
        
        self.carTypeImg.image = UIImage(named: "booking_circle")
        self.bikeTypeImg.image = UIImage(named: "booking_circle_filled")
        self.selectedVehicleType = VehecleTypeSelection.bike
        
    }
    
    
    
    // MARK: Private Methods
    //MARK:- ==========================================================
    
    
    func initialSetup() {
        
        self.navigationTitleLabel.text = REQUEST_PICKUP.localized
        self.bookBtn.setTitle(BOOK.localized, for: .normal)
        self.pickLabel.text = PICK.localized
        self.turnOnGPSLabel.text = TURN_GPS_ON.localized
        self.turnGPSDescLabel.text = LOCATION_POPUP_DESCRIPTION.localized
        self.yesButton.setTitle(YES.localized, for: .normal)
        self.noButton.setTitle(NO.localized, for: .normal)
        
        self.shareBtn.isUserInteractionEnabled = false
        self.googleMapView.delegate = self
        self.pickerDoneView.addSubview(self.pickDoneButton)
        self.pickDoneButton.setTitle("Done", for: UIControlState())
        self.pickDoneButton.addTarget(self, action: #selector(toolbarDoneBtnTapped), for: .touchUpInside)
        
        self.bookBtn.layer.borderColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1).cgColor
        self.bookBtn.clipsToBounds = true
        self.bookBtn.layer.borderWidth = IsIPad ? 5:4.5
        self.bookBtn.layer.cornerRadius = IsIPad ? 45:30
        
        self.pickUpDropOffTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        
        self.pickUpDropOffTableView.dataSource = self
        self.pickUpDropOffTableView.delegate = self
        self.pickUpDropOffTableView.rowHeight = IsIPad ? 80:60
        
        self.setBookBtn()
        self.navigationView.setMenuButton()
        
        self.pickUpDotView.layer.cornerRadius = IsIPad ? 5:3.5
        self.pickUpAddressLabel.text = "Choose your Pick Up"
        self.pickUpAddressLabel.sizeToFit()
        
        
        self.pickerView.backgroundColor = UIColor.white
        self.pickerDoneView.backgroundColor = UIColor(red: 194/255, green: 0, blue: 52/255, alpha: 1)
        self.pickerView.frame.size.height = 150
        self.pickerView.frame.size.width = screenWidth * 0.85
        self.pickerDoneView.frame.size.width = screenWidth * 0.85
        self.pickDoneButton.frame.size.width = screenWidth * 0.85
        
        self.pickerDoneView.clipsToBounds = true
        
        self.pickerOuterView.addSubview(self.pickerView)
        self.pickerOuterView.addSubview(self.pickerDoneView)
        
        self.view.bringSubview(toFront: self.pickerOuterView)
        self.view.bringSubview(toFront: self.gpsOuterView)
        
    }
    
    
    
    // To check if book btn should be enabled or disabled
    func setBookBtn() {
        
        if dropLocationDict["address"] == nil || pickLocationDict["address"] == nil || (dropLocationDict["address"] as! String).isEmpty || (pickLocationDict["address"] as! String).isEmpty {
            
            self.disableBookBtn()
            
        } else {
            
            self.enableBookBtn()
            
            
            delay(2, closure: {
                
                printlnDebug(self.pickLocationDict)
                printlnDebug(self.dropLocationDict)
                if let _ = self.pickLocationDict["latitude"], let _ = self.dropLocationDict["latitude"] as? Double{
                    
                    let pickup_loc = CLLocation(latitude: self.pickLocationDict["latitude"] as! Double, longitude: self.pickLocationDict["longitude"] as! Double)
                    self.setPickUpMarker(pickup_loc)
                    let drop_loc = CLLocation(latitude: self.dropLocationDict["latitude"] as! Double, longitude: self.dropLocationDict["latitude"] as! Double)
                    self.setPickUpMarker(drop_loc)
                    
                    self.pickUpDropOffTableView.reloadData()
                }
            })
        }
    }
    
    
    
    func setPickUpMarker(_ locValue:CLLocation){
        self.destinationMarker.position = CLLocationCoordinate2DMake(locValue.coordinate.latitude, locValue.coordinate.longitude)
        self.destinationMarker.icon = UIImage(named: "request_job_location_pin")
        self.destinationMarker.map = self.googleMapView
    }
    
    
    
    func disableBookBtn() {
        
        self.bookBtn.isEnabled = false
        self.bookBtn.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        self.bookBtn.tintColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1)
    }
    
    
    
    func enableBookBtn() {
        
        self.bookBtn.isEnabled = true
        self.bookBtn.backgroundColor = UIColor(red: 218/255, green: 0, blue: 84/255, alpha: 1)
        self.bookBtn.tintColor = UIColor.white
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
        
        if swipe.direction == .up && self.bottomLayoutConstraintOfRideView.constant == -(IsIPad ? 169:119) {
            
            self.openRideView()
            
        } else if swipe.direction == .down && self.bottomLayoutConstraintOfRideView.constant == 0 {
            
            self.closeRideView()
        }
    }
    
    
    
    func openRideView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            
            self.bottomLayoutConstraintOfRideView.constant = 0
            self.view.layoutIfNeeded()
            
            }, completion: { (didComplete: Bool) in
                
        })
    }
    
    
    
    func closeRideView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            
            self.bottomLayoutConstraintOfRideView.constant = -(IsIPad ? 169:119)
            self.view.layoutIfNeeded()
            
            }, completion: { (didComplete: Bool) in
                
        })
    }
    
    
    
    
    func addMoreLocationBtnTapped(_ sender: UIButton) {
        
        let cell = sender.superview?.superview as! LocationTableViewCell
        let indexPath = self.pickUpDropOffTableView.indexPath(for: cell)!
        
        self.tappedIndex = indexPath.row
        action = .add
        
        self.navigate(LocationType.dropoff)
    }
    
    
    
    
    func editLocationBtnTapped(_ sender: UIButton) {
        
        let cell = sender.superview?.superview as! LocationTableViewCell
        let indexPath = self.pickUpDropOffTableView.indexPath(for: cell)!
        
        self.tappedIndex = indexPath.row
        self.action = .edit
        
        self.navigate(LocationType.dropoff)
    }
    
    
    
    func editDropLocation(atIndex index: Int) {
        
        self.tappedIndex = index
        self.action = .edit
        
        self.navigate(LocationType.dropoff)
    }
    
    
    
    func addMoreLocation(atIndex index: Int) {
        
        self.tappedIndex = index
        action = .add
        
        self.navigate(LocationType.dropoff)
    }
    
    
    
    func addEditLocation(withLocation location: [String: String]) {
        
        if action == .add {
            
            if self.numberOfLocations < 5 {
                
                self.dropLocationDict = location as [String : AnyObject]
                self.numberOfLocations = self.numberOfLocations.advanced(by: 1)
                self.pickUpDropOffTableView.reloadData()
                
                self.getPlaceDetail(dropLocationDict["place_id"] as! String, dict: .drop)
                
            } else {
                
                showToastWithMessage(RideStrings.addLocLimit.localized)
            }
            
        } else if (self.action == .edit) && (self.tappedIndex == -1) {
            
            self.pickLocationDict = location as [String : AnyObject]
            self.isPickedUpLoc = false
            self.pickUpAddressLabel.text = location["address"] ?? RideStrings.choosePic
            self.getPlaceDetail(pickLocationDict["place_id"] as! String, dict: .pick)
            
        } else {
            
            self.dropLocationDict = location as [String : AnyObject]
            self.pickUpDropOffTableView.reloadData()
            
            self.getPlaceDetail(self.dropLocationDict["place_id"] as! String, dict: .drop)
        }
        
        self.setBookBtn()
    }
    
    
    
    func navigate(_ type: LocationType) {
        
        let chooseLocationScene = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "ChooseLocationViewController") as! ChooseLocationViewController
        
        let locationType = self.getLocationType(forIndex: self.tappedIndex)
        
        chooseLocationScene.locationType = locationType
        chooseLocationScene.delegate = self
        chooseLocationScene.location_Type = type
        self.present(chooseLocationScene, animated: true, completion: nil)
    }
    
    
    
    func getLocationType(forIndex index: Int) -> String {
        
        if index == -1 {
            
            return LocationTypeString.pickUp
            
        } else {
            
            return LocationTypeString.dropOff
        }
    }
    
    
    
    func toolbarDoneBtnTapped() {
        
        self.pickerOuterView.isHidden = true
        self.vehivleNameLabel.text = (self.vehicleDetails[self.pickerView.selectedRow(inComponent: 0)]["model"] as? String) ?? ""
    }
    
    
    
    func showPopUp(_ aps: [String: AnyObject],ride_id: String){
        if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController, viewController != nil {
            
            printlnDebug(aps)
            let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "SearchingForDriver") as! SearchingForDriver
            
            popUp.modalPresentationStyle = .overCurrentContext
            popUp.info = aps
            popUp.ride_id = self.ride_id
            
            getMainQueue({
                viewController!.present(popUp, animated: true, completion: nil)
            })
        }
    }
    
    
    
    
    func getJsonObject(_ Detail: AnyObject) -> String{
        var data = Data()
        do {
            data = try JSONSerialization.data(
                withJSONObject: Detail ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch{
            
        }
        let paramData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return paramData
    }
    
    
    
    
    func show_GPS_prompt(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                printlnDebug("No access")
                
            case .restricted, .denied:
                self.gpsView.isHidden = false
                self.gpsOuterView.isHidden = false
                self.googleMapView.clear()
            case .authorizedAlways, .authorizedWhenInUse:
                printlnDebug("Access")
            }
        } else {
            
            self.gpsView.isHidden = false
            self.gpsOuterView.isHidden = false
            self.googleMapView.clear()
            
        }
    }
    
    
    func turn_GPS_ON() {
        
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }
    
    
    
    func displayShareSheet(_ shareContent:String) {
        
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true, completion: nil)
        
    }
    
}



//MARK:- Google Map delegate
//MARK:- ========================================================

extension RequestARideViewController: GMSMapViewDelegate{
    
    // UpdteLocationCoordinate
    func updateLocationoordinates(_ coordinates:CLLocationCoordinate2D) {
        
        
        //            if destinationMarker == nil
        //            {
        //                destinationMarker = GMSMarker()
        //                destinationMarker!.position = coordinates
        //                let image = UIImage(named:"request_job_location_pin")
        //                destinationMarker!.icon = image
        //                destinationMarker?.map = self.googleMapView
        //                destinationMarker!.appearAnimation = kGMSMarkerAnimationPop
        //            }
        //            else
        //            {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.01)
        destinationMarker.position =  coordinates
        CATransaction.commit()
        self.getPlaceDetailWithCordinate(coordinates)
        
        //  }
        
    }
    
    // Camera change Position this methods will call every time
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        var destinationLocation = CLLocation()
        if self.mapGesture == true
        {
            destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
            destinationCoordinate = destinationLocation.coordinate
            updateLocationoordinates(destinationCoordinate!)
            printlnDebug(destinationCoordinate?.latitude)
        }
    }
    
    func getPlaceDetailWithCordinate(_ coordinates:CLLocationCoordinate2D) {
        
        let params = ["latlng": "\(coordinates.latitude ),\(coordinates.longitude )", "key": "AIzaSyB0jPK6b0QwIZV8u1hSKLpe8cZsHpot3yc"]
        
        googleGeocodeApi(params as [String : AnyObject]) { (result:JSONDictionary) in
            printlnDebug(result)
            
            if let address = result["formatted_address"] as? String, let geometry = result["geometry"] as? [String: AnyObject], let location = geometry["location"] as? [String: AnyObject], let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                
                self.pickUpAddressLabel.text = address
                self.pickLocationDict["address"] = address as AnyObject
                self.pickLocationDict["latitude"] = latitude as AnyObject
                self.pickLocationDict["longitude"] = longitude as AnyObject
                
                //self.setMapZoomLevel()
                
            }

        }
    }
    
}



//MARK:- Call webservices methods
//MARK:- ===================================================================

extension RequestARideViewController {
    
    
    
    func requestARide(){
        
        sharedAppdelegate.stausTimer.invalidate()
        showLoader()
        let pickupLoc = self.pickLocationDict
        
        let dropLoc = self.dropLocationDict
        
        printlnDebug(dropLoc)
        
        var params = JSONDictionary()
        
        if !self.vehicleDetails.isEmpty{
            
            if let type =  self.vehicleDetails[self.currenSelected]["type"] as? String{
                params["vehicle_type"] = type.lowercased() as AnyObject
            }
        }
        
        if self.currenLat_long != nil{
            
            params["current_lat"] = self.currenLat_long?.latitude as AnyObject
            params["current_lon"] = self.currenLat_long?.longitude as AnyObject
        }
        params["estimated_time"] = self.estimatedTime as AnyObject
        
        if self.selectedVehicleType == .car{
            
            params["vehicle_type"] = VehicleType.car as AnyObject
        }else{
            params["vehicle_type"] = VehicleType.bike as AnyObject
        }
        
        params["estimated_distance"] = self.estimatedDistance as AnyObject
        params["pickup_locations"] = self.getJsonObject(pickupLoc as AnyObject) as AnyObject
        params["drop_locations"] = self.getJsonObject(dropLoc as AnyObject) as AnyObject
        
        
        printlnDebug(params)
        rideNowApi(params, SuccessBlock: { (result:  JSONDictionary) in
            printlnDebug(result)
            if let ride_id = result["ride_id"] as? String{
                self.ride_id = ride_id
            }
            showLoader()
            
            self.showPopUp(result,ride_id: self.ride_id)
            self.isShow = true
            self.checkStatus()
            sharedAppdelegate.stausTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.checkStatus), userInfo: nil, repeats: true)
            hideLoader()
        })
    }
    
    
    
    func checkStatus(){
        
        var params = JSONDictionary()
        params["action"] = "driver" as AnyObject
        
        params["ride_id"] = self.ride_id as AnyObject
        
        checkStatusApi(params, completionHandler: { (result: JSONDictionary) in
            printlnDebug(result)
            
            self.timeCount = self.timeCount + self.timeInterval
            
            if let status = result["status"] as? String{
                
                if status == Status.one && !self.status{
                    self.status = true
                    hideLoader()
                    sharedAppdelegate.stausTimer.invalidate()
                    self.dismiss(animated: true, completion: nil)
                    self.gotoOnrideScreen(result, state: RideStateString.arrivalNow, navigationTitle: NavigationTitle.arrivalNow,isPopup: true)
                    
                }
                else if status == Status.five{
                    
                    sharedAppdelegate.stausTimer.invalidate()
                    hideLoader()
                    self.gotoOnrideScreen(result, state: RideStateString.onTrip, navigationTitle: NavigationTitle.onRide,isPopup: false)
                }
                else if status == Status.seven{
                    self.isShow = false

                    showToastWithMessage(AppConstantString.rideCancel)
                    gotoHomeVC()
                }
            }
            hideLoader()
        })
    }
    
    
    
    func getPlaceDetail(_ placeID: String, dict: DictType) {
        
        let params = [ "placeid" : placeID, "key" : API_Keys.googleApiKey ]
        
        getLatLong(params as [String : AnyObject]) { (result: JSONDictionary, status: String) in
            
            printlnDebug(result)
            
            if status == "OK" {
                
                if let geometry = result["geometry"] as? [String: AnyObject], let location = geometry["location"] as? [String: AnyObject], let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                    
                    if dict == .drop {
                        
                        self.dropLocationDict["latitude"] = latitude as AnyObject
                        self.dropLocationDict["longitude"] = longitude as AnyObject
                        self.dropLocationDict["place_id"] = placeID as AnyObject
                        
                    } else {
                        
                        self.pickLocationDict["latitude"] = latitude as AnyObject
                        self.pickLocationDict["longitude"] = longitude as AnyObject
                        self.pickLocationDict["place_id"] = placeID as AnyObject
                    }
                    
                    printlnDebug(self.pickLocationDict)
                    
                    
                    if let srcLat = self.pickLocationDict["latitude"],let srcLon = self.pickLocationDict["longitude"],let desLat = self.dropLocationDict["latitude"],let desLon = self.dropLocationDict["longitude"]{
                        
                        let srcStr = "\(srcLat),\(srcLon)"
                        let desStr = "\(desLat),\(desLon)"
                        
                        self.calcEta(srcStr, destination: desStr)
                        
                    }
                    
                } else {
                    
                    //showToastWithMessage("Something went wrong.")
                }
                
            } else {
                printlnDebug(status)
                showToastWithMessage(status)
            }
            
        }
    }
    
    func setPickUpLocation() {
        
        let params = ["latlng": "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)", "key": "AIzaSyB0jPK6b0QwIZV8u1hSKLpe8cZsHpot3yc"]
        
        googleGeocodeApi(params as [String : AnyObject]) { (result:JSONDictionary) in
            
            printlnDebug(result)
            
            if let address = result["formatted_address"] as? String, let geometry = result["geometry"] as? [String: AnyObject], let location = geometry["location"] as? [String: AnyObject], let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                
                self.pickUpAddressLabel.text = address
                self.pickLocationDict["address"] = address as AnyObject
                self.pickLocationDict["latitude"] = latitude as AnyObject
                self.pickLocationDict["longitude"] = longitude as AnyObject
                
                self.googleMapView.camera = GMSCameraPosition(target: (self.locationManager.location?.coordinate)!, zoom: 14, bearing: 0, viewingAngle: 0)
                self.cameraPosition = false
                
                self.destinationMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
                self.destinationMarker.icon = UIImage(named: "request_job_location_pin")
                self.destinationMarker.map = self.googleMapView
                
            }
        }
    }
    
    
}


// MARK:- Table View Life Cycle Methods
//MARK:- ===================================================================


extension RequestARideViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        
        let locationAddress = (self.dropLocationDict["address"] as? String) ?? "Choose your Drop Off"
        
        cell.populate(atIndex: indexPath.row, withNumberOfLocations: self.numberOfLocations, withLocationAddress: locationAddress)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.dropLocationDict["address"] == nil) || (self.dropLocationDict["address"] as! String).isEmpty {
            
            self.addMoreLocation(atIndex: indexPath.row)
            
        } else {
            
            self.editDropLocation(atIndex: indexPath.row)
        }
    }
}

// MARK: Add/Edit Pick Up or Drop Off Locations
extension RequestARideViewController: ManageLocationsDelegate {
    
    
    
}

// MARK: Picker View data source life cycle methods
extension RequestARideViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.vehicleDetails.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        printlnDebug(self.vehicleDetails[row]["model"] as! String)
        
        return (self.vehicleDetails[row]["model"] as! String)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.currenSelected = row
        
    }
}



//MARK:- Goto viewcontrollers
//MARK:- ===================================================================

extension RequestARideViewController {
    
    func gotoOnrideScreen(_ rideDetail: JSONDictionary ,state: String, navigationTitle: String,isPopup: Bool){
        
        let onRideVC = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnRideViewController") as! OnRideViewController
        onRideVC.rideDetail = rideDetail
        onRideVC.ride_id = self.ride_id
        onRideVC.isPopUp = isPopup
        onRideVC.isPopUp = self.isShow
        UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.ride_State)
        UserDefaults.save(RideStateString.arrivalNow as AnyObject, forKey: NSUserDefaultKey.TRIP_STATE)
        
        UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.R_TYPE)
        UserDefaults.save(DriverType.pickup_user as AnyObject, forKey: NSUserDefaultKey.D_TYPE)
        
        onRideVC.navigationTitleStr = navigationTitle
        let navController = UINavigationController(rootViewController: onRideVC)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets=false
        
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
    
}



// MARK: CLLocation manager Delegate Life Cycle Methods
// MARK: ======================================================================

extension RequestARideViewController: CLLocationManagerDelegate {
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = manager.location!.coordinate
        
        self.currenLat_long = manager.location!.coordinate
        
        if self.zoomState == .zoomin{
            
            self.zoomState = .zoomout
            self.destinationMarker.position = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
            self.destinationMarker.icon = UIImage(named: "request_job_location_pin")
            self.destinationMarker.map = self.googleMapView
            
        }
        if cameraPosition{
            
            self.googleMapView.camera = GMSCameraPosition(target: manager.location!.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
            self.cameraPosition = false
        }
        
    }
    
    
    
    // get ETA AND Distance
    
    func calcEta(_ source:String,destination:String){
        
        self.estimatedDistance = 0.0
        
        let params : [String : AnyObject] = [:]
        
        
        getEatApi(params, source: source, destination: destination) { (data, statue) in
            
            guard let firstElement = data.first else{
                fatalError("")
            }
            
            if let elements = firstElement["elements"] as? JSONDictionaryArray{
                
                var timeArray = [String]()
                
                for item in elements{
                    
                    
                    if let timeData = item["duration"] as? JSONDictionary{
                        
                        if let time = timeData["text"] as? String{
                            timeArray.append(time)
                        }
                    }
                    
                    
                    if let disData = item["distance"] as? JSONDictionary{
                        
                        if let dis = disData["text"] as? String{
                            
                            if dis.contains(" m"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = Float(sepratedDis)! / 1000
                                
                            }else if dis.contains(" km"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = Float(sepratedDis)!
                                
                            }
                            
                            
                        }
                    }
                    
                }
                
                self.retriveTotalEat(timeArray)
            }
        }
        
    }
    
    
    
    func retriveTotalEat(_ timeArray:[String]){
        var hourArray = [String]()
        var minArray = [String]()
        
        for item in timeArray{
            
            if item.contains(" hours") && item.contains(" mins"){
                
                
                let str = item.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " mins", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hours") && item.contains(" min"){
                
                let str = item.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " min", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hour") && item.contains(" mins"){
                
                let str = item.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " mins", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hour") && item.contains(" min"){
                
                let str = item.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " min", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hours"){
                
                let str = item.replacingOccurrences(of: " hours", with: "")
                hourArray.append(str)
                
            }else if item.contains(" mins"){
                
                let str = item.replacingOccurrences(of: " mins", with: "")
                minArray.append(str)
                
            }else if item.contains(" hour"){
                
                let str = item.replacingOccurrences(of: " hour", with: "")
                hourArray.append(str)
                
            }else if item.contains(" min"){
                
                let str = item.replacingOccurrences(of: " min", with: "")
                minArray.append(str)
                
            }
            
        }
        
        self.calculateNetTime(hourArray, minArray: minArray)
        
    }
    
    
    
    func calculateNetTime(_ hrArray : [String] , minArray : [String]){
        
        var total = 0
        for item in hrArray{
            
            if !item.contains("day") && !item.isEmpty{
                total = total + (Int(item)! * 60)

            }
        }
        
        for item in minArray{
            
            if !item.contains("day") && !item.isEmpty{

                total = total + Int(item)!
            }
        }
        
        printlnDebug(total)
        self.estimatedTime = "\(total)"
        self.arrivalTimeLabel.text = "You'll reach to your destination in \(total) mins"
        self.shareBtn.isUserInteractionEnabled = true
        self.getFare(total)
        
    }
    
    
    
    func getFare(_ tot:Int){
        
        
        let params : [String:AnyObject] = ["trip_type":"pickup" as AnyObject,"estimated_distance": "\(self.estimatedDistance)" as AnyObject,"estimated_time": "\(tot)" as AnyObject,"no_of_drops" : "1" as AnyObject,"current_city":"singapore" as AnyObject]
        printlnDebug(params)
        
        calculateTotalFareAPI(params) { (data: JSONDictionary) in
            
            if let fare = data["total_fare"]{
                
                self.tripFareLabel.text = "$\(fare)"
            }
        }
    }
}



