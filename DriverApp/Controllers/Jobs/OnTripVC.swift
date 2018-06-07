//
//  TripDetailViewController.swift
//  CustomSlider
//
//  Created by Aakash Srivastav on 10/26/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps

class OnTripVC: UIViewController {
    
    // MARK: IBOulets
    //MARK:- ===================================================================
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneNumberBtn: UIButton!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var startNavigateBtn: UIButton!
    @IBOutlet weak var etaView: UIView!
    @IBOutlet weak var etaLbl: UILabel!
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var tripDetailTableView: UITableView!
    @IBOutlet weak var remainingDropsTableView: UITableView!
    
    @IBOutlet weak var remainingDropsTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var remainingTableHeightConstraint:
    NSLayoutConstraint!
    
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    @IBOutlet weak var completeTripButton: UIButton!
    
    
    
    // MARK: Variables
    //MARK:- ===================================================================
    
    
    lazy var locationManager = CLLocationManager()
    var remainingDropLocations = 3
    var remainingTableViewRowHeight: CGFloat = (IsIPad ? 70:30)
    var tripDetail : JobDetailsModel!
    var pick_drop_Loc = ["":""]
    var dropLoc = [String]()
    var currentLoc = [String: String]()
    var estimatedDistance : Float = 0.0
    var mapZoomTimer = Timer()
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var currentLocation: CLLocation?
    var userContactNo = ""
    
    
    // MARK: ViewController Life Cycle Methods
    //MARK:- ===================================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationTitleLabel.text = ON_TRIP.localized
        self.startNavigateBtn.setTitle(START_NAVIGATION.localized, for: .normal)
        self.completeTripButton.setTitle(COMPLETE_TRIP.localized, for: .normal)
        
        
        
        printlnDebug(self.tripDetail)
        self.navigationView.setMenuButton()
        self.initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 10
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        self.remainingDropsTableViewBottomConstraint.constant = -(self.remainingTableHeightConstraint.constant + 10)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
        self.remainingTableHeightConstraint.constant = CGFloat(self.remainingDropLocations)*self.remainingTableViewRowHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapZoomTimer.invalidate()
    }
    
    
    // MARK: IBActions
    //MARK:- ===================================================================
    
    
    
    @IBAction func showCancelRideBtnTapped(_ sender: UIButton) {
        
        if self.remainingDropsTableViewBottomConstraint.constant == 10 {
            self.hideDropTable()
        } else {
            self.showDropTable()
        }
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
    
    
    @IBAction func completeTripTapped(_ sender: UIButton) {
        
        self.completeTrip()
        
    }
    
    
    // MARK: ===============
    // MARK: Private Methods
    
    
    
    
    func initialSetup() {
        
        self.getChangeLocationRequest()

        self.startNavigateBtn.layer.cornerRadius = 5
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.borderWidth = 1.8
        self.userImageView.layer.borderColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1).cgColor
        
        self.tripDetailTableView.register(UINib(nibName: "PickDropTableViewCell" ,bundle: nil), forCellReuseIdentifier: "PickDropTableViewCell")
        
        self.tripDetailTableView.dataSource = self
        self.tripDetailTableView.delegate = self
        
        self.remainingDropsTableView.dataSource = self
        self.remainingDropsTableView.delegate = self
        
        self.mapZoomTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.setMapZoomLevel), userInfo: nil, repeats: true)
        hideLoader()
        
        self.setUserDate()
        
        self.setPic_DropLocations()
        
        if CurrentUser.ridestate! == RideStateString.payment{
        }
    }
    
    
    func completeTrip(){
        
        
        var params = [String: AnyObject]()
        printlnDebug(self.tripDetail)
//        showLoader()
        if let res = self.tripDetail.ride_id{
            params["ride_id"] = res as AnyObject
            driverSharedInstance.ride_id = res
        }
        params["actual_distance"] = "10" as AnyObject
        params["actual_time"] = "10" as AnyObject
        params["current_lat"] = locationManager.location?.coordinate.latitude as AnyObject
        params["current_lon"] = locationManager.location?.coordinate.longitude as AnyObject
        
        printlnDebug(params)
        
        SocketServices.socketEmitEndRide(params: params)
        
        SocketServices.socketOnEndRide_res { (success, data) in
            
            if success{
            
                let result = data["result"]
                
                self.ShowPaymentPopUp(JobDetailsModel.init(with: result))
            }
        }
        
    }
    
    func setMapZoomLevel(){
        
        if self.currentLocation != nil {
            
            self.googleMapView.camera = GMSCameraPosition(target: self.currentLocation!.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
            
            //            let marker = GMSMarker()
            //            marker.position = CLLocationCoordinate2DMake((self.currentLocation!.coordinate.latitude), (self.currentLocation!.coordinate.longitude))
            //            marker.icon = UIImage(named: "request_job_location_pin")
            //            marker.map = self.googleMapView
            
        }
    }
    
    
    
    func openGoogleMap(){
        
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            if !self.tripDetail.dropLat.isEmpty && !self.tripDetail.dropLong.isEmpty{
                
                UIApplication.shared.openURL(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(self.tripDetail.dropLat[0]),\(self.tripDetail.dropLong[0])&directionsmode=driving")!)
                
            }
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
            
            if !self.tripDetail.dropLat.isEmpty && !self.tripDetail.dropLong.isEmpty{
                
                let urlStr: String = "waze://?ll=\(self.tripDetail.dropLat[0]),\(self.tripDetail.dropLong[0])&navigate=yes"
                UIApplication.shared.openURL(URL(string: urlStr)!)
                
            }
        }
        else {
            // Waze is not installed. Launch AppStore to install Waze app
            UIApplication.shared.openURL(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
    }
    
    
    func setUserDate(){
        
        
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
    }
    
    
    
    func setPic_DropLocations(){
        
        self.googleMapView.clear()
        
        self.pick_drop_Loc["pick"] = self.tripDetail.pickupAddress
        
        let pmarker = GMSMarker()
        pmarker.position = CLLocationCoordinate2DMake(Double(self.tripDetail.userLat)!, Double(self.tripDetail.userLong)!)
        pmarker.icon = UIImage(named: "request_job_location_pin")
        pmarker.map = self.googleMapView
        
        let source =  self.tripDetail.userLat + "," + self.tripDetail.userLong + "|"
        var destinationStr = ""
        var dropl = ""
        
        
        for (i,lat) in self.tripDetail.dropLat.enumerated(){
            
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(Double(lat)!, Double(self.tripDetail.dropLong[i])!)
            marker.icon = UIImage(named: "request_job_location_pin")
            marker.map = self.googleMapView
            
            destinationStr += lat + "," + self.tripDetail.dropLong[i] + "|"
            
            
        }
        
        dropl = self.tripDetail.dropAddress
        self.pick_drop_Loc["drop"] = dropl
        
        self.tripDetailTableView.reloadData()
        self.remainingDropsTableView.reloadData()
        
        self.calcEta(source, destination: destinationStr)
        
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

extension OnTripVC {
    
    
    func setPickUpLocation() {
        
        let params = ["latlng": "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)", "key": API_Keys.googleApiKey]
        
        googleGeocodeApi(params as [String : AnyObject]) { (result:[String: AnyObject]) in
            
            printlnDebug(result)
            
            if let address = result["formatted_address"] as? String, let placeId =  result["place_id"] as? String{
                
                self.currentLoc["address"] = address
                self.currentLoc["place_id"] = placeId
                self.tripDetailTableView.reloadData()
            }
        }
    }
    
}



// MARK: LocationManager Delegate Methods
//MARK:- ===================================================================


extension OnTripVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.currentLocation = manager.location
        
        if self.zoomState == .zoomin{
            self.setMapZoomLevel()
            self.zoomState = .zoomout
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
                                self.estimatedDistance =  self.estimatedDistance + (Float(sepratedDis)! / 1000)
                                
                            }else if dis.contains(" km"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = self.estimatedDistance + Float(sepratedDis)!
                                
                            }
                            
                            
                        }
                    }
                    
                }
                printlnDebug(timeArray)
                printlnDebug(self.estimatedDistance)
                
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
        
        printlnDebug(hourArray)
        printlnDebug(minArray)
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
        self.etaLbl.text = "\(total) mins (\(self.estimatedDistance) kms)"
    }
    
    func getChangeLocationRequest(){
        
        SocketServices.socketOnChangeLocation_res { (success, data) in
            
            if success{
                
                let result = data["result"]
                printlnDebug(data)
                if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
                    
                    let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestRidePopUpViewController") as! RequestRidePopUpViewController
                    
                    popUp.selectedPopUp = ShowPopUp.changeDestination
                    popUp.modalPresentationStyle = .overCurrentContext
                    popUp.userInfo = ChangeDropModel.init(with: result)
                    popUp.changeLocationDelegate = self
                    viewController!.present(popUp, animated: true, completion: nil)

//                    getMainQueue({
//                    })
                    
                }
            }
        }
    }
    
}

// MARK: =========================================
// MARK: TableView Delegate and DataSource Methods
extension OnTripVC: UITableViewDataSource, UITableViewDelegate {
    
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
                cell.populate(at: indexPath.row, with: self.pick_drop_Loc["pick"]!)
            }
            else{
                cell.populate(at: indexPath.row, with: self.pick_drop_Loc["drop"]!)
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OnTripRemainingDropTableViewCell", for: indexPath) as! OnTripRemainingDropTableViewCell
        
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
extension OnTripVC: LocationChangeDelegate{
    
    func didChangeLocation() {
        
        gotoHomeVC()
        
    }

//    func didChangeLocation(with newLocation: String) {
//        
//        let source =  self.tripDetail.userLat + "," + self.tripDetail.userLong + "|"
//
//        self.pick_drop_Loc["drop"] = newLocation
//        
//        self.remainingDropsTableView.reloadData()
//        self.tripDetailTableView.reloadData()
//        
//        self.calcEta(source, destination: <#T##String#>)
//    }
}

// MARK: ================================
// MARK: TableViewCell Life Cycle Methods
class OnTripRemainingDropTableViewCell: UITableViewCell {
    
    // MARK: =========
    // MARK: IBOutlets
    
    @IBOutlet weak var dropAddressLabel: UILabel!
    @IBOutlet weak var dropLabel: UILabel!
    
    // MARK: ================================
    // MARK: TableViewCell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dropLabel.text = DROP.localized
    }
    // MARK: =========
    // MARK: Private Methods
}
