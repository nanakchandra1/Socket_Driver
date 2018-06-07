//
//  TripDetailViewController.swift
//  CustomSlider
//
//  Created by Aakash Srivastav on 10/26/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps

class TripDetailViewController: UIViewController {
    
    // MARK: =====
    // MARK: Enums
    
    // MARK: ========
    // MARK: IBOulets
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var phoneNumberBtn: UIButton!
    @IBOutlet weak var tripDetailTableView: UITableView!
    @IBOutlet weak var remainingDropsTableView: UITableView!
    @IBOutlet weak var startTripBtn: UIButton!
    @IBOutlet var reachBtn: UIButton!
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var startNavigateBtn: UIButton!
    @IBOutlet weak var etaView: UIView!
    @IBOutlet weak var etaLbl: UILabel!
    @IBOutlet weak var remainingDropsTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var remainingTableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var cancelTripButton: UIButton!
    
    
    // MARK: Variables
    // MARK: ===================================================================
    
    lazy var locationManager = CLLocationManager()
    var remainingDropLocations = 3
    var remainingTableViewRowHeight: CGFloat = (IsIPad ? 70:30)
    var tripDetail : JobDetailsModel!
    var pickUpLoc = ""
    var dropLoc = [String]()
    var currentLoc = [String: String]()
    var estimatedDistance : Float = 0.0
    var zoom = Zoom_in_Zoom_Out.zoomin
    var userContactNo = ""
    
    
    // MARK: ViewController Life Cycle Methods
    // MARK: ===================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationTitleLabel.text = TRIP_DETAILS.localized
        self.startTripBtn.setTitle(START_TRIP.localized, for: .normal)
        self.cancelTripButton.setTitle(CANCEL_TRIP.localized, for: .normal)
        self.startNavigateBtn.setTitle(START_NAVIGATION.localized, for: .normal)
        self.reachBtn.setTitle(REACH.localized, for: .normal)
        self.locationManager.distanceFilter = 10
        hideLoader()
        printlnDebug(self.tripDetail)
        self.navigationView.setMenuButton()
        self.initialSetup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.remainingDropsTableViewBottomConstraint.constant = -(self.remainingTableHeightConstraint.constant + 10)
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 10
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
        self.remainingTableHeightConstraint.constant = CGFloat(self.remainingDropLocations)*self.remainingTableViewRowHeight
    }
    
    // MARK: IBActions
    // MARK: ===================================================================
    
    @IBAction func cancelRideBtnTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: alertMessageTrip, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.cancelRide()
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    
    @IBAction func phoneBtnTapped(_ sender: UIButton) {
        
        if self.userContactNo != ""{
            let phoneNumber = self.userContactNo
            let phone = "telprompt://" + phoneNumber.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: phone){
                UIApplication.shared.openURL(url)
            }
        }

    }
    
    
    @IBAction func reachBtnTapped(_ sender: UIButton) {
        
        self.calculateWaitingTime()
    }
    
    @IBAction func showCancelRideBtnTapped(_ sender: UIButton) {
        
        if self.remainingDropsTableViewBottomConstraint.constant == 10 {
            self.hideDropTable()
        } else {
            self.showDropTable()
        }
    }
    
    
    @IBAction func startNavigationBtnTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "GoogleMap", style: .default , handler:{ (UIAlertAction)in
            self.openGoogleMap()
        }))
        alert.addAction(UIAlertAction(title: "WazeMap", style: .default , handler:{ (UIAlertAction)in
            self.openWazeMap()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    @IBAction func startTripTapped(_ sender: UIButton) {
        
        var params = [String: AnyObject]()
        printlnDebug(self.tripDetail)
        showLoader()
        if let res = self.tripDetail.ride_id{
            params["ride_id"] = res as AnyObject
        }
//        params["actual_distance"] = "10" as AnyObject
//        params["actual_time"] = "10" as AnyObject
        params["current_lat"] = locationManager.location?.coordinate.latitude as AnyObject
        params["current_lon"] = locationManager.location?.coordinate.longitude as AnyObject
        printlnDebug(params)

        SocketServices.socketEmitStartRide(params: params)
        
        SocketServices.socketOnStartRide_res { (success, data) in
            
            if success{
            
                printlnDebug(data)
                let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnTripVC") as! OnTripVC
                obj.tripDetail = self.tripDetail
                self.navigationController?.pushViewController(obj, animated: true)

            }
        }
        
//        startTripApi(params) { (result:  [String : AnyObject]) in
//            printlnDebug(result)
//            sharedAppdelegate.stausTimer.invalidate()
//            hideLoader()
//            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ARRIVED)
//            UserDefaults.save(RequestType.valet as AnyObject, forKey: NSUserDefaultKey.ride_State)
//            let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "OnTripVC") as! OnTripVC
//            obj.tripDetail = self.tripDetail
//            self.navigationController?.pushViewController(obj, animated: true)
//        }
    }
    
    
    // MARK: Private Methods
    // MARK: ===========================================
    
    
    func initialSetup() {
        
        
        SocketServices.socketOnCancelRide_res { (success, data) in
            
            if success{
                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ride_id)
                showToastWithMessage(data["message"].stringValue)
                gotoHomeVC()
            }
            
        }
        
        
        self.getupdateLoc_res()
        
        self.startNavigateBtn.layer.cornerRadius = 5
        self.reachBtn.layer.cornerRadius = 3
        self.reachBtn.isHidden = true
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.borderWidth = 1.8
        self.userImageView.layer.borderColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1).cgColor
        self.tripDetailTableView.register(UINib(nibName: "PickDropTableViewCell" ,bundle: nil), forCellReuseIdentifier: "PickDropTableViewCell")
        self.tripDetailTableView.dataSource = self
        self.tripDetailTableView.delegate = self
        self.remainingDropsTableView.dataSource = self
        self.remainingDropsTableView.delegate = self
        printlnDebug(self.tripDetail)
//        self.checkStatus()
//        sharedAppdelegate.stausTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.checkStatus), userInfo: nil, repeats: true)
        hideLoader()
        
        if let username = self.tripDetail.user_name{
            self.userNameLabel.text = username
        }
        if let phone = self.tripDetail.contact{
            self.userContactNo = phone
            self.phoneNumberBtn.setTitle(self.userContactNo, for: UIControlState())
        }

        if let userImage = self.tripDetail.image{
            let imageUrlStr = "http://52.76.76.250/uploads/users/" + userImage
            if let imageUrl = URL(string: imageUrlStr){
                self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
            }
        }
        
        if let address = self.tripDetail.pickupAddress{
            self.pickUpLoc = address
            self.tripDetailTableView.reloadData()
        }
        
        self.dropLoc.append(self.tripDetail.dropAddress)
        self.remainingDropsTableView.reloadData()
        
//        if let drop = result["drop"] as? [[String: AnyObject]]{
//            for res in drop{
//                if let address = res["address"] as? String{
//                    self.dropLoc.append(address)
//                }
//            }
//            self.remainingDropsTableView.reloadData()
//        }
//        if let result = self.tripDetail["result"] as? [String: AnyObject]{
//            
//        }
    }

    func cancelRide(){
        
        printlnDebug("Cancel")
        var params = JSONDictionary()
        
//        params["action"] = "cancel" as AnyObject
        params["cancelled_by"] = "driver" as AnyObject
        params["reason"] =  "I want to cancel" as AnyObject
        if let res = self.tripDetail.ride_id{
            params["ride_id"] = res as AnyObject
        }
        showLoader()
        SocketServices.socketEmitCancelRide(params: params)
        
//        showLoader()
//        rideActionApi(params) { (result: JSONDictionary) in
//            hideLoader()
//            sharedAppdelegate.stausTimer.invalidate()
//            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ARRIVED)
//            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.R_TYPE)
//            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ride_State)
//            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.D_TYPE)
//            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.TRIP_STATE)
//            gotoHomeVC()
//        }
    }
    
    func openGoogleMap(){
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?saddr=&daddr=\(self.tripDetail.userLat),\(self.tripDetail.userLong)&directionsmode=driving")!)

//            if let result = self.tripDetail["result"] as? JSONDictionary{
//                if let pick = result["pickup"] as? JSONDictionary, let lat = pick["latitude"],let lon = pick["longitude"]{
//                }
//            }
        } else {
            let url  = URL(string: URLName.real_Time_navigate_URL)
            if UIApplication.shared.canOpenURL(url!) == true  {
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    
    func openWazeMap(){
        
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            // Waze is installed. Launch Waze and start navigation
            
            let urlStr: String = "waze://?ll=\(self.tripDetail.userLat),\(self.tripDetail.userLong)&navigate=yes"
            UIApplication.shared.openURL(URL(string: urlStr)!)

            
//            if let result = self.tripDetail["result"] as? JSONDictionary{
//                if let pick = result["pickup"] as? JSONDictionary, let lat = pick["latitude"],let lon = pick["longitude"]{
//                    let urlStr: String = "waze://?ll=\(lat),\(lon)&navigate=yes"
//                    UIApplication.shared.openURL(URL(string: urlStr)!)
//                }
//            }
        }
        else {
            // Waze is not installed. Launch AppStore to install Waze app
            UIApplication.shared.openURL(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
        
        
    }
    
    
    
    func showDropTable() {
        UIView.animate(withDuration: 0.5, animations: {
            self.remainingDropsTableViewBottomConstraint.constant = 10
            self.downArrow.image = UIImage(named: "payment_method_down_arrow")
            self.view.layoutIfNeeded()
        }) 
    }
    
    
    
    func hideDropTable() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.downArrow.image = UIImage(named: "right")
            self.remainingDropsTableViewBottomConstraint.constant = -(self.remainingTableHeightConstraint.constant + 10)
            self.view.layoutIfNeeded()
        }) 
    }
}



//MARK:- Call webservices methods
//MARK:- ===================================================================

extension TripDetailViewController {
    
    
    
//    func checkStatus(){
//        
//        var params = JSONDictionary()
//        params["action"] = "driver" as AnyObject
//        if let res = self.tripDetail.ride_id{
//            params["ride_id"] = res as AnyObject
//        }
//        checkStatusApi(params, completionHandler: { (result: JSONDictionary) in
//            if let status = result["status"] as? String{
//                if status == Status.seven{
//                    showToastWithMessage(AppConstantString.rideCancel)
//                    sharedAppdelegate.stausTimer.invalidate()
//                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultKey.ARRIVED)
//                    leavePickup()
//                }
//            }
//            hideLoader()
//        })
//        
//        let destination = "\(self.tripDetail.userLat),\(self.tripDetail.userLong)|"
//        if self.locationManager.location != nil{
//            let source = "\(self.locationManager.location!.coordinate.latitude),\(self.locationManager.location!.coordinate.longitude)|"
//            printlnDebug(source)
//            printlnDebug(destination)
//
//        }
////        if let result = self.tripDetail["result"] as? JSONDictionary{
////            
////            if let pick = result["pickup"] as? JSONDictionary, let lat = pick["latitude"],let lon = pick["longitude"]{
////                let destination = "\(lat),\(lon)|"
////                if self.locationManager.location != nil{
////                let source = "\(self.locationManager.location!.coordinate.latitude),\(self.locationManager.location!.coordinate.longitude)|"
////                printlnDebug(source)
////                printlnDebug(destination)
////                self.calcEta(source, destination: destination)
////                }
////            }
////        }
//    }
    
    
    
    func setPickUpLocation() {
        
        let params = ["latlng": "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)", "key": "AIzaSyCpvhVhEb0N4ihzWh8FA3FIVsdBEBGuESU"]
        
        googleGeocodeApi(params as [String : AnyObject]) { (result:[String: AnyObject]) in
            printlnDebug(result)
            if let address = result["formatted_address"] as? String, let placeId =  result["place_id"] as? String{
                self.currentLoc["address"] = address
                self.currentLoc["place_id"] = placeId
                self.tripDetailTableView.reloadData()
            }
        }
    }
    
    
    
    
    func calculateWaitingTime(){
    
        
        if locationManager.location != nil{
            var params = JSONDictionary()
            params["user_id"] = CurrentUser.user_id as AnyObject
            params["current_lon"] = locationManager.location?.coordinate.longitude as AnyObject 
            params["current_lat"] = locationManager.location?.coordinate.latitude as AnyObject
            if let res = self.tripDetail.ride_id{
                params["ride_id"] = res as AnyObject
            }
            printlnDebug(params)
            
            SocketServices.socketEmitReachLocation(params: params)
            
            SocketServices.socketOnReachLocation_res(completion: { (success, data) in
                
                if success{
                
                    self.reachBtn.isHidden = true
//                    UserDefaults.save("1" as AnyObject, forKey: NSUserDefaultKey.ARRIVED)
                    printlnDebug(data)
                }
            })
//            watingChargeApi(params, SuccessBlock: { (result) in
//                printlnDebug(result)
//                self.reachBtn.isHidden = true
//                UserDefaults.save("1" as AnyObject, forKey: NSUserDefaultKey.ARRIVED)
//                printlnDebug(CurrentUser.arrived)
//                
//            })
        }

    }
}





// MARK: LocationManager Delegate Methods
// MARK: ================================


extension TripDetailViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.currentLoc["latitude"] = "\(manager.location?.coordinate.latitude)"
        self.currentLoc["longitude"] = "\(manager.location?.coordinate.longitude)"
        if self.zoom == Zoom_in_Zoom_Out.zoomin{
            self.zoom = .zoomout
            self.setPickUpLocation()
            printlnDebug(self.tripDetail)
            self.googleMapView.clear()
            self.googleMapView.camera = GMSCameraPosition(target: manager.location!.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
                    let destination = self.tripDetail.userLat + "," + self.tripDetail.userLong + "|"
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(Double(self.tripDetail.userLat)!, Double(self.tripDetail.userLong)!)
                    marker.icon = UIImage(named: "request_job_location_pin")
                    marker.map = self.googleMapView
                    let source = "\(manager.location!.coordinate.latitude),\(manager.location!.coordinate.longitude)|"
                    let sourceMarker = GMSMarker()
                    sourceMarker.position = CLLocationCoordinate2DMake((manager.location?.coordinate.latitude)!, (manager.location?.coordinate.longitude)!)
                    sourceMarker.icon = UIImage(named: "ic_user_map_marker")
                    sourceMarker.map = self.googleMapView
                    printlnDebug(source)
                    printlnDebug(destination)
                    self.calcEta(source, destination: destination)
        }
        
        self.updateLocation(location: manager.location!)

    }
    
    
    func updateLocation(location: CLLocation){
        
        var params = JSONDictionary()
        params["ride_id"] = self.tripDetail.ride_id as AnyObject
        params["current_lat"] = location.coordinate.latitude as AnyObject
        params["current_lon"] = location.coordinate.longitude as AnyObject
        params["actual_distance"] = "10" as AnyObject
        params["actual_time"] = "10" as AnyObject
        
        SocketServices.updateLocationOnride(params: params)
    }
    
    func getupdateLoc_res(){
        
        SocketServices.update_Location_on_trip_res { (success, data) in
            
            printlnDebug(data)
        }
    }
    

    
    func calcEta(_ source:String,destination:String){
        self.estimatedDistance = 0.0
        let params : [String : AnyObject] = [:]
        
        printlnDebug(source)
        printlnDebug(destination)
        //        "28.535517,77.391029"
        
        getEatApi(params, source: source, destination: destination, completionHandler: { (data: JSONDictionaryArray, staus: String) in
            
            printlnDebug(data)
            guard let firstElement = data.first else{
                fatalError("")
            }
            if let elements = firstElement["elements"] as? JSONDictionaryArray{
                var timeArray = ""
                for item in elements{
                    //let time = item["duration"]!["text"]
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
                printlnDebug(timeArray)
                printlnDebug(self.estimatedDistance)
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
        printlnDebug(hourArray)
        printlnDebug(minArray)
        self.calculateNetTime(hourArray, minArray: minArray)
    }
    
    
    
    
    func calculateNetTime(_ hrArray : String , minArray : String){
        var total = 0
        
        printlnDebug("hours**********************\(hrArray)")
        printlnDebug("Mins**********************\(minArray)")

        if !hrArray.contains("day") && !hrArray.isEmpty{
            total = total + (Int(hrArray) ?? 0 * 60)
        }
        if !minArray.contains("day") && !minArray.isEmpty{
            total = total + Int(minArray)!
        }
        self.etaLbl.text = "\(total) mins (\(self.estimatedDistance) kms)"

        printlnDebug(total)
        if CurrentUser.arrived == nil{
            if total <= 1{
                
                self.reachBtn.isHidden = false
            }
        }
    }
}





// MARK: =========================================
// MARK: TableView Delegate and DataSource Methods
extension TripDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView === self.tripDetailTableView {
            return 2
        }
        return self.dropLoc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === self.tripDetailTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickDropTableViewCell", for: indexPath) as! PickDropTableViewCell
            
            if indexPath.row == 0{
                if let address = self.currentLoc["address"] {
                    cell.populate(at: indexPath.row, with: address)
                }else{
                    cell.populate(at: indexPath.row, with: "Not DeterMined")
                }
            }
            else{
                cell.populate(at: indexPath.row, with: self.pickUpLoc)
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RemainingDropTableViewCell", for: indexPath) as! RemainingDropTableViewCell
        cell.dropAddressLabel.text = self.dropLoc[indexPath.row]
        if self.remainingDropLocations > 1 {
            cell.dropLabel.text = "DROP \(indexPath.row+1) -"
        } else {
            cell.dropLabel.text = "DROP -"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView === self.tripDetailTableView {
            return UITableViewAutomaticDimension
        }
        return remainingTableViewRowHeight
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView === self.tripDetailTableView {
            return UITableViewAutomaticDimension
        }
        return remainingTableViewRowHeight
    }
}



// MARK: ================================
// MARK: TableViewCell Life Cycle Methods
class RemainingDropTableViewCell: UITableViewCell {
    
    // MARK: =========
    // MARK: IBOutlets
    
    @IBOutlet weak var dropAddressLabel: UILabel!
    @IBOutlet weak var dropLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dropLabel.text = DROP.localized
    }
    
    // MARK: ================================
    // MARK: TableViewCell Life Cycle Methods
    
    // MARK: =========
    // MARK: Private Methods
}

