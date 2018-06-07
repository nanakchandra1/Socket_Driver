//
//  OnRideViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/25/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps

enum OnRide_ArrivalNowState {
    case onRide, arrival
}

class OnRideViewController: UIViewController {
    
    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userMobileNumber: UILabel!
    
    // @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var pickDropTableViewCell: UITableView!
    @IBOutlet weak var googleMapView: GMSMapView!
    
    // select drop
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var selectLocLbl: UILabel!
    @IBOutlet weak var selectDropPickerView: UIPickerView!
    @IBOutlet weak var dropCancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancleBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var etaBgView: UIView!
    @IBOutlet weak var etaLbl: UILabel!
    
    @IBOutlet weak var pickUpConfirmBgView: UIView!
    @IBOutlet weak var pickUpConfirmPopupView: UIView!
    @IBOutlet weak var picEtaLbl: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var driverPhone: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    
    @IBOutlet weak var tripCancelBtn: UIButton!
    
    @IBOutlet weak var pickUpDetailsLabel: UILabel!
    
    
    
    
    
    // MARK: =========
    // MARK: Variables
    lazy var locationManager = CLLocationManager()
    var vcState = OnRide_ArrivalNowState.arrival
    var rideDetail = JSONDictionary()
    var dropLoc = ""
    var ride_id = ""
    var driverLoc = ""
    var navigationTitleStr = ""
    var status: String!
    var estimatedDistance : Float = 0.0
    var currentLoc: CLLocation?
    var isConfirm = false
    var isPopUp = false
    var isZoom = true
    var sharedMsg = ""


    
    
    
    // MARK: =================================
    // MARK: ViewController Life Cycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationTitle.text = ON_RIDE.localized
        self.tripCancelBtn.setTitle(CANCEL_TRIP.localized, for: .normal)
        self.pickUpDetailsLabel.text = PICKUP_DETAILS.localized.capitalized
        
        
        self.pickUpConfirmBgView.isHidden = true
        self.initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.isPopUp{
            
                self.pickUpConfirmBgView.isHidden = false
                self.isPopUp = false
        }
        if self.vcState == .onRide{
            self.cancleBtnHeightConstraint.constant = 0
        }
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.navigationTitle.text = self.navigationTitleStr
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
        self.driverImage.layer.cornerRadius = self.driverImage.frame.size.height/2
        
        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.borderWidth = 1.8
        self.userImageView.layer.borderColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1).cgColor
        self.driverImage.layer.masksToBounds = true
        
        self.driverImage.layer.borderWidth = 1.8
        self.driverImage.layer.borderColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1).cgColor
        
        self.navigationView.setMenuButton()
        
    }
    
    
    // MARK: Private Methods
    //MARK:- ===================================================================
    
    func initialSetup() {
        
        
        self.checkStatus()
        sharedAppdelegate.stausTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.checkStatus), userInfo: nil, repeats: true)
        
        if CurrentUser.driver_arriving_state == NavigationTitle.onTheWay{
            if CurrentUser.driver_arriving_state == NavigationTitle.onTheWay{
                self.navigationTitleStr = NavigationTitle.onTheWay
            }else{
                self.navigationTitleStr = NavigationTitle.arrivalNow
            }
        }
        
        self.pickDropTableViewCell.register(UINib(nibName: "PickDropTableViewCell" ,bundle: nil), forCellReuseIdentifier: "PickDropTableViewCell")
        
        self.pickDropTableViewCell.dataSource = self
        self.pickDropTableViewCell.delegate = self
        
            self.setUserData()
            self.setPicDropLoc()
            self.updateMarker()
        
    }
    
    
    func setUserData(){
        
        if let driver_Detail = self.rideDetail["driver_detail"] as? JSONDictionary{
            
            if let d_id = driver_Detail["uid"] as? String, let contact = driver_Detail["contact"] as? String, let name = driver_Detail["name"] as? String{
                
                self.userNameLabel.text = name.uppercased()
                self.driverNameLbl.text = name.uppercased()
                self.userMobileNumber.text = contact
                self.driverPhone.text = contact
                self.userIdLabel.text = DRIVER_ID.localized + d_id
            }
            
            if let image = self.rideDetail["driver_detail"]!["image"] as? String{
                
                let imageUrlStr = "http://52.76.76.250/"+image
                if let imageUrl = URL(string: imageUrlStr){
                    
                    self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
                    self.driverImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
                }
            }

        }
    }
    
    
    func setPicDropLoc(){
        
        if let drop = self.rideDetail["drop"] as? JSONDictionaryArray{
            var dropl = ""
            self.dropLoc = ""
            for res in drop{
                
                if let address = res["address"] as? String{
                    dropl = dropl + "\n" + address
                    
                    
                    if self.dropLoc == ""{
                        self.dropLoc = address
                    }
                    else{
                        self.dropLoc =  "\(self.dropLoc)\n\(address)"
                    }
                }
            }
            self.pickDropTableViewCell.reloadData()
        }
        
        if self.vcState == .arrival{
            if let driver_loc = self.rideDetail["driver_current_loc"] as? JSONDictionary{
                if let cord = driver_loc["coordinates"] as? [AnyObject]{
                    
                    let D_cord = CLLocationCoordinate2D(latitude: Double("\(cord[1])")!, longitude: Double("\(cord[0])")!)
                    self.getPlaceDetail(D_cord)
                }
            }
        }
    }

    
    func setEta(){
        
        var source = ""
        var destinationStr = ""

        if let pickup = self.rideDetail["pickup"] as? JSONDictionary,let lat = pickup["latitude"],let lon = pickup["longitude"]{
            source = "\(lat),\(lon)|"
            
        }
        
        
        
        if let drop = self.rideDetail["drop"] as? JSONDictionaryArray{
            for res in drop{
                
                if let lat = res["latitude"],let lon = res["longitude"]{
                    destinationStr.append("\(lat),\(lon)|")
                }
            }
            self.pickDropTableViewCell.reloadData()
        }
        
        if self.vcState == .arrival{
            if let driver_loc = self.rideDetail["driver_current_loc"] as? JSONDictionary{
                if let cord = driver_loc["coordinates"] as? [AnyObject]{
                    //let D_cord = CLLocationCoordinate2D(latitude: Double("\(cord[1])")!, longitude: Double("\(cord[0])")!)
                    destinationStr = "\(cord[1]),\(cord[0])|"
                    self.calcEta(source, destination: destinationStr)
                    //self.getPlaceDetail(D_cord)

                }
            }
        }else{
            if let driver_loc = self.rideDetail["driver_current_loc"] as? JSONDictionary{
                
                if let cord = driver_loc["coordinates"] as? [AnyObject]{
                    source = "\(cord[1]),\(cord[0])|"
                    self.calcEta(source, destination: destinationStr)
                }
            }

            //self.calcEta(source, destination: destinationStr)
        }
    }
    
    
    
    func updateMarker(){
        
        self.setEta()
        self.googleMapView.clear()
        
        if let driver_loc = self.rideDetail["driver_current_loc"] as? JSONDictionary{
            if let cord = driver_loc["coordinates"] as? [AnyObject]{
                let marker = GMSMarker()
                if !cord.isEmpty{
                    let D_cord = CLLocationCoordinate2D(latitude: Double("\(cord[1])")!, longitude: Double("\(cord[0])")!)
                    self.googleMapView.camera = GMSCameraPosition(target: D_cord, zoom: 14, bearing: 0, viewingAngle: 15)
                    marker.position = D_cord
                    marker.icon = UIImage(named: "ic_request_pin_car_pin")
                    marker.map = self.googleMapView
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        if self.vcState == .arrival{

        if let pickup = self.rideDetail["pickup"] as? JSONDictionary,let lat = pickup["latitude"],let lon = pickup["longitude"]{
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(Double("\(lat)")!, Double("\(lon)")!)
            marker.icon = UIImage(named: "request_job_location_pin")
            marker.map = self.googleMapView
        }
    }
        
        if self.vcState == .onRide{
            
            if let drop = self.rideDetail["drop"] as? JSONDictionaryArray{
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
    
    
    func cancelRide(){
    
        var params = JSONDictionary()
        
        params["action"] = "cancel" as AnyObject
        params["cancelled_by"] = "user" as AnyObject
        params["reason"] =  "I want to cancel" as AnyObject
        if let id = self.rideDetail["_id"] as? String{
            params["ride_id"] = id as AnyObject
        }
        
        showLoader()
        rideActionApi(params) { (result: JSONDictionary) in
            hideLoader()
            leavePickup()
            
        }
    
    }
    
    
    
    func displayContentController(_ content: UIViewController) {
        
        addChildViewController(content)
        self.view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    
    
    func hideContentController(_ content: UIViewController) {
        
        content.willMove(toParentViewController: nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    
    // MARK: IBActions
    //MARK:- ===================================================================
    
    
    @IBAction func crossBtnTapped(_ sender: UIButton) {
        
        self.pickUpConfirmBgView.isHidden = true
        self.updateMarker()
        
    }
    
    
    @IBAction func phoneNoTapped(_ sender: UIButton) {
        
        if self.userMobileNumber.text != ""{
            let phoneNumber = self.userMobileNumber.text ?? ""
            let phone = "telprompt://" + phoneNumber.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: phone){
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        
        let alert = UIAlertController(title: "", message: alertMessageRide, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.cancelRide()
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    
    @IBAction func userPhoneNoTapped(_ sender: UIButton) {
        
        if self.driverPhone.text != ""{
            let phoneNumber = self.driverPhone.text ?? ""
            let phone = "telprompt://" + phoneNumber.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: phone){
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        
        self.displayShareSheet(self.sharedMsg)
    }

    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }

}


//MARK:- Goto viewcontrollers
//MARK:- ===================================================================

extension OnRideViewController {
    
    
    func cancel_ride_Serive_Call(_ action: String){
        
        var params = [String: AnyObject]()
        params["action"] = action as AnyObject
        
        if let ride_uid = self.rideDetail["ride_id"] as? String{
            params["ride_id"] = ride_uid as AnyObject
        }
        
        if self.currentLoc != nil{
            params["current_lat"] = self.currentLoc?.coordinate.latitude as AnyObject
            params["current_lon"] = self.currentLoc?.coordinate.longitude as AnyObject
        }
        
        if let d_id = CurrentUser.user_id , let name = CurrentUser.full_name, let contact = CurrentUser.mobile, let uid = CurrentUser.uid{
            
            params["driver_id"] = d_id as AnyObject
            params["driver_name"] = name as AnyObject
            params["driver_contact"] = contact as AnyObject
            params["driver_uid"] = uid as AnyObject
            
        }
        
        if let img = CurrentUser.user_image{
            params["driver_image"] = img as AnyObject
        }
        
        
        showLoader()
        printlnDebug(params)
        rideActionApi(params) { (success) in
            printlnDebug(success)
            self.navigationController?.popViewController(animated: true)
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func checkStatus(){
        
        var params = JSONDictionary()
        params["action"] = "driver" as AnyObject
        params["ride_id"] = self.ride_id as AnyObject
        
        checkStatusApi(params, completionHandler: { (result: JSONDictionary) in
            
            printlnDebug(result)
            if let status = result["status"] as? String{
                
                if status == Status.five && self.vcState != .onRide{
                    hideLoader()
                    UserDefaults.save(RideStateString.onride as AnyObject, forKey: NSUserDefaultKey.TRIP_STATE)
                    
                    self.vcState = .onRide
                    UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.DRIVER_ARRIVING_STATE)
                    self.navigationTitleStr = NavigationTitle.onRide
                    self.cancleBtnHeightConstraint.constant = 0
                    self.setPicDropLoc()
                }
                else if status == Status.six{
                    
                    hideLoader()
                    sharedAppdelegate.stausTimer.invalidate()
                    let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
                    obj.tripDetail = result
                    obj.ride_id = self.ride_id
                    self.displayContentController(obj)
                    
                }else if status == Status.seven{
                    
                    hideLoader()
                    sharedAppdelegate.stausTimer.invalidate()
                    UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.DRIVER_ARRIVING_STATE)

                    showToastWithMessage(AppConstantString.rideCancel)
                    leavePickup()
                }
            }
            self.updateMarker()
            hideLoader()
        })
        
    }
}



// MARK: LocationManager Delegate Methods and get ETA methods
// MARK: ================================


extension OnRideViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.currentLoc = manager.location
    }
    
    
    
    func getPlaceDetail(_ coordinates:CLLocationCoordinate2D){
        
        
        let params = ["latlng": "\(coordinates.latitude ?? 0),\(coordinates.longitude ?? 0)", "key": API_Keys.googleApiKey]
        
        googleGeocodeApi(params as [String : AnyObject]) { (result:JSONDictionary) in
            
            printlnDebug(result)
            
            if let address = result["formatted_address"] as? String{
                
                self.driverLoc = address
                self.pickDropTableViewCell.reloadData()
            }
        }
    }

    
    
    // calculate eta
    
    func calcEta(_ source:String,destination:String){
        
        self.estimatedDistance = 0.0
        
        let params : [String : AnyObject] = [:]
        
        
        getEatApi(params, source: source, destination: destination, completionHandler: { (data: JSONDictionaryArray, staus: String) in
            
            printlnDebug(data)
            
            
            guard let firstElement = data.first else{
                fatalError("")
            }
            
            if let elements = firstElement["elements"] as? JSONDictionaryArray{
                
                var timeArray = ""
                
                for item in elements{
                    
                    
                    if let timeData = item["duration"] as? JSONDictionary{
                        
                        if let time = timeData["text"] as? String{
                            timeArray = time
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
            
            
        })
        
    }
    
    
    
    func retriveTotalEat(_ timeArray:String){
        
        var hourArray = ""
        var minArray = ""
        
        
        if timeArray.contains(" hours") && timeArray.contains(" mins"){
            
            
            let str = timeArray.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " mins", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hours") && timeArray.contains(" min"){
            
            let str = timeArray.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " min", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hour") && timeArray.contains(" mins"){
            
            let str = timeArray.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " mins", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hour") && timeArray.contains(" min"){
            
            let str = timeArray.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " min", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hours"){
            
            let str = timeArray.replacingOccurrences(of: " hours", with: "")
            hourArray = str
            
        }else if timeArray.contains(" mins"){
            
            let str = timeArray.replacingOccurrences(of: " mins", with: "")
            minArray = str
            
        }else if timeArray.contains(" hour"){
            
            let str = timeArray.replacingOccurrences(of: " hour", with: "")
            hourArray = str
            
        }else if timeArray.contains(" min"){
            
            let str = timeArray.replacingOccurrences(of: " min", with: "")
            minArray = str
        }
        
        self.calculateNetTime(hourArray, minArray: minArray)
        
    }
    
    
    func calculateNetTime(_ hrArray : String , minArray : String){
        
        var total = 0
        
        if !hrArray.contains("day") && !hrArray.isEmpty{
            total = total + (Int(hrArray) ?? 0 * 60)

        }

        if !minArray.contains("day") && !minArray.isEmpty{
            total = total + Int(minArray)!
        }

            self.picEtaLbl.text = ETA_OF_DRIVER.localized + "\(total) mins"
            self.etaLbl.text = "\(total) Mins (\(self.estimatedDistance) kms)"
        if self.vcState == .arrival{
            if total <= 2{
                UserDefaults.save(NavigationTitle.arrivalNow as AnyObject, forKey: NavigationTitle.arrivalNow)
                self.navigationTitleStr = NavigationTitle.arrivalNow
            }else{
                UserDefaults.save(NavigationTitle.arrivalNow as AnyObject, forKey: NavigationTitle.onTheWay)
                self.navigationTitleStr = NavigationTitle.onTheWay
            }
            self.sharedMsg = "\(RideStrings.arrivalnow_share_eta_Msg) \(total) mins"
        }else{
            self.sharedMsg = "\(RideStrings.share_eta_Msg) \(total) mins"
        }
    }
}



// MARK: TableView Delegate and DataSource Methods
// MARK: =========================================


extension OnRideViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickDropTableViewCell", for: indexPath) as! PickDropTableViewCell
        if self.vcState == .arrival{
            if indexPath.row == 0{
                cell.populate(at: indexPath.row, with: self.driverLoc)
            }
            else{
                if let pickup = self.rideDetail["pickup"] as? JSONDictionary, let address = pickup["address"] as? String{
                    cell.populate(at: indexPath.row, with: address)
                }
            }

        }else{
            if indexPath.row == 0{
                if let pickup = self.rideDetail["pickup"] as? JSONDictionary, let address = pickup["address"] as? String{
                    cell.populate(at: indexPath.row, with: address)
                }
            }
            else{
                cell.populate(at: indexPath.row, with: self.dropLoc)
            }

        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
