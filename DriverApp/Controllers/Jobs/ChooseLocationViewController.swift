//
//  ChooseLocationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/22/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import CoreLocation


enum LocationType {
    case pickUp, dropoff, none
}

protocol ManageLocationsDelegate {
    
    func addEditLocation(withLocation location: [String: String])
}

class ChooseLocationViewController: UIViewController,CLLocationManagerDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var previousSavedLocaitonTableView: UITableView!
    @IBOutlet weak var searchedLocationTableView: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    
    // MARK: Variables
    var locationType = "Pick-Up"
    var numberOfSections = 1
    var currentLoc = [String: String]()
    var locationManager:CLLocationManager!
    var location_Type = LocationType.none
    var delegate: ManageLocationsDelegate?
    
    var matchedLocationsDict = [[String: String]]()
    var savedLocationDict = [["place_id": "ChIJL_P_CXMEDTkRw0ZdG-0GVvw", "address":"Delhi, India"]]
    var previousLocationDict = [["place_id": "ChIJL_P_CXMEDTkRw0ZdG-0GVvw", "address":"Delhi, India"]]
    
    var country_cod = ""
    let geoCoder = CLGeocoder()

    // MARK: Constants
    let googleAPIKey = "AIzaSyCpvhVhEb0N4ihzWh8FA3FIVsdBEBGuESU"
    
    // MARK: View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    func initialSetup() {
        
        self.navigationTitle.text = CHOOSE_YOUR_LOCATION.localized
        self.searchTextField.placeholder = CHOOSE_YOUR_LOCATION.localized.capitalized
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        self.show_GPS_prompt()

        let locType = locationType.replacingOccurrences(of: " ", with: "")
        let title = "Choose Your \(locType)"
        self.navigationTitle.text = title.uppercased()

        locationType = locationType.replacingOccurrences(of: " ", with: "-")
        
        self.searchTextField.delegate = self
        
        self.previousSavedLocaitonTableView.dataSource = self
        self.previousSavedLocaitonTableView.delegate = self
        
        self.searchedLocationTableView.dataSource = self
        self.searchedLocationTableView.delegate = self
        self.searchedLocationTableView.isHidden = true
        
//        if IsIPhone {
//            
//            self.searchedLocationTableView.rowHeight = 44
//            self.previousSavedLocaitonTableView.rowHeight = 35
//            
//        } else if IsIPad {
//            
//            self.searchedLocationTableView.rowHeight = 70
//            self.previousSavedLocaitonTableView.rowHeight = 55
//        }
        
        self.previousSavedLocaitonTableView.estimatedRowHeight = 40
        self.searchedLocationTableView.estimatedRowHeight = 40
        self.previousSavedLocaitonTableView.rowHeight = UITableViewAutomaticDimension
        self.searchedLocationTableView.rowHeight = UITableViewAutomaticDimension

        
        let style = self.searchTextField.defaultTextAttributes[NSParagraphStyleAttributeName] as! NSMutableParagraphStyle
        style.minimumLineHeight = (self.searchTextField.font?.lineHeight)! - ((self.searchTextField.font?.lineHeight)! - UIFont(name: "SFUIDisplay-Regular", size: IsIPad ? 22:11.5)!.lineHeight)/2
        
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: "Choose Your \(locationType)", attributes: [NSForegroundColorAttributeName: UIColor(red: 137/255, green: 136/255, blue: 136/255, alpha: 1), NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: IsIPad ? 20:11.5)!, NSParagraphStyleAttributeName: style])
        
        self.searchTextField.addTarget(self, action: #selector(getMatchingLocations), for: .editingChanged)
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard let currentLocPlacemark = placemarks?.first else { return }
            guard let code = currentLocPlacemark.isoCountryCode else{return}
            self.country_cod = code
        }
    }

    
    
    func show_GPS_prompt(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                printlnDebug("No access")
                
            case .restricted, .denied:
                printlnDebug("No access")

            case .authorizedAlways, .authorizedWhenInUse:
                printlnDebug("Access")
                self.setPickUpLocation()
            }
        }
    }
    
    
    
    func setPickUpLocation() {
        
        let params = ["latlng": "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)", "key": "AIzaSyB0jPK6b0QwIZV8u1hSKLpe8cZsHpot3yc"]
        
        googleGeocodeApi(params as [String : AnyObject]) { (result:JSONDictionary) in
            
            printlnDebug(result)
            
            if let address = result["formatted_address"] as? String, let placeId =  result["place_id"] as? String{
                
                self.currentLoc["address"] = address
                self.currentLoc["place_id"] = placeId
                self.previousSavedLocaitonTableView.reloadData()
            }
        }
    }

    
    
    
    func getMatchingLocations() {
        
        self.matchedLocationsDict.removeAll()
        
        if !self.searchTextField.text!.isEmpty {
            self.searchedLocationTableView.isHidden = false
        } else {
            self.searchedLocationTableView.isHidden = true
        }
        
        guard let text = self.searchTextField.text, !text.isEmpty && isNetworkAvailable() else {
            
            self.searchedLocationTableView.reloadData()
            return }
        
        
        
        //let params = ["input": text, "key": googleAPIKey]
        
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(text)&key=\(googleAPIKey)&components=country:\(self.country_cod)"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        
        googlePlacesAPI(encodedUrl!) { (result:JSONDictionaryArray, status: String) in
            printlnDebug(result)
            
            printlnDebug(result)
            
            guard status == "OK" else {
                self.matchedLocationsDict = [["address": status]]
                self.searchedLocationTableView.reloadData()
                return
            }
            
            
                self.matchedLocationsDict.removeAll()
                
                for location in result {
                    
                    let place_id = location["place_id"] as! String
                    let address = location["description"] as! String
                    let dict = ["place_id": place_id, "address": address]
                    
                    self.matchedLocationsDict.append(dict)
                }
                delay(Double(0.1), closure: {
                    self.searchedLocationTableView.reloadData()
                })

        }
        
    }
    
    
    func matchLocation(_ id: String?) -> Bool {
        
        if id == nil { return false }
        
        for location in self.savedLocationDict {
            
            if location["place_id"] == id {
                
                return true
            }
        }
        return false
    }

    
    // MARK: IBActions
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        
        if self.searchTextField.isFirstResponder {
        
            self.getMatchingLocations()
            
        } else {
        
            self.searchTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.searchedLocationTableView.isHidden = true
        self.searchTextField.text = ""
        self.view.endEditing(true)
        self.matchedLocationsDict.removeAll()
        self.searchedLocationTableView.reloadData()
    }
    
    @IBAction func backBtntapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}



// MARK: TableView DataSource Life Cycle Methods
extension ChooseLocationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView === self.searchedLocationTableView {
            
            return 1
        }
        if self.location_Type == LocationType.pickUp{
            return numberOfSections
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView === self.searchedLocationTableView {
            
            return self.matchedLocationsDict.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === self.previousSavedLocaitonTableView {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousSavedLocationTableViewCell", for: indexPath) as! PreviousSavedLocationTableViewCell
            
                if let add = self.currentLoc["address"]{
                cell.populate(withLocation: add)
                }
                else{
                    cell.populate(withLocation: "")

                }

                cell.makeRoundCorners()
            
            return cell
            
        } else {
            
           let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedLocationtableViewCell", for: indexPath) as! SearchedLocationtableViewCell
            if self.matchedLocationsDict.count > 0{

            var location = self.matchedLocationsDict[indexPath.row]["address"] ?? ""
            let place_id = self.matchedLocationsDict[indexPath.row]["place_id"] ?? ""
            
            if location == "ZERO_RESULTS" {
                location = "NO MATCHING RESULTS FOUND"
                self.searchedLocationTableView.allowsSelection = false
                
            } else {
                
                self.searchedLocationTableView.allowsSelection = true
            }

            cell.populate(withLocation: location, isSavedLocation: self.matchLocation(place_id))
            
            if indexPath.row == self.matchedLocationsDict.count-1 {
                cell.separatorLineView.isHidden = true
            }
            }
            return cell
        }
    }
}


// MARK: TableView Delegate Life Cycle Methods
extension ChooseLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView === self.searchedLocationTableView {
            
            return nil
        }
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.previousSavedLocaitonTableView.frame.width, height: IsIPad ? 50:30))
        sectionHeaderView.backgroundColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.previousSavedLocaitonTableView.frame.width, height: IsIPad ? 50:30))
        view.backgroundColor = UIColor.white
        view.layer.mask = cornerLayer(view.bounds, corners: [.topLeft, .topRight], cgsizeWidth: 3, cgsizeHeight: 3)
        view.clipsToBounds = true
        
        let locationTypeLabel = UILabel(frame: CGRect(x:15, y: sectionHeaderView.center.y, width: view.frame.width-30, height: IsIPad ? 20:15))
        
        locationTypeLabel.font = UIFont(name: "SFUIDisplay-Semibold", size: IsIPad ? 16:11.5)!
        
        locationTypeLabel.text = "My Location"

        
        
        view.addSubview(locationTypeLabel)
        sectionHeaderView.addSubview(view)
        
        return sectionHeaderView
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if tableView === self.searchedLocationTableView {
            
            return nil
        }
        return UIView()
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView == self.searchedLocationTableView {
            return 0
        } else if section == 0 && self.previousLocationDict.count == 0 {
            return 0
        } else if section == 1 && self.savedLocationDict.count == 0 {
            return 0
        }
        return IsIPad ? 50:30
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if tableView == self.searchedLocationTableView {
            return 0
        } else if section == 0 && self.previousLocationDict.count == 0 {
            return 0
        } else if section == 1 && self.savedLocationDict.count == 0 {
            return 0
        }
        return IsIPad ? 12:8
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if tableView === self.searchedLocationTableView {
            
            delegate?.addEditLocation(withLocation: self.matchedLocationsDict[indexPath.row])
            
        }
        else{
        
            if !self.currentLoc.isEmpty{
                delegate?.addEditLocation(withLocation: self.currentLoc)
            }
            else{
                delegate?.addEditLocation(withLocation: ["currentLoc": "","place_id": ""])
            }

        }
        
        self.dismiss(animated: true, completion: nil)
    }
}




// MARK: Text Field Delegate Life Cycle Methods
extension ChooseLocationViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.getMatchingLocations()
        self.searchTextField.resignFirstResponder()
        return true
        
    }
    
}




// MARK:
// MARK: Class for PreviousSavedLocation TableViewCell
class PreviousSavedLocationTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var previousSavedLocationLabel: UILabel!
    
    // Table view cell life cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.previousSavedLocationLabel.text = nil
        self.layer.mask = cornerLayer(CGRect(x:0, y: 0, width: screenWidth-30, height: IsIPad ? 55:35), corners: [.bottomLeft, .bottomRight], cgsizeWidth: 0, cgsizeHeight: 0)
    }
    
    // MARK: Private Methods
    func populate(withLocation location: String?) {
        
        self.previousSavedLocationLabel.text = location
    }
    
    func makeRoundCorners() {
        
        self.layer.mask = cornerLayer(CGRect(x:0, y: 0, width: screenWidth-30, height: IsIPad ? 55:35), corners: [.bottomLeft, .bottomRight], cgsizeWidth: 3, cgsizeHeight: 3)
    }
}



// MARK:
// MARK: Class for SearchedLocation TableViewCell
class SearchedLocationtableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var searchedLocationLabel: UILabel!
    @IBOutlet weak var savedLocationImageView: UIImageView!
    @IBOutlet weak var separatorLineView: UIView!
    
    // Table view cell life cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.searchedLocationLabel.text = nil
        //self.savedLocationImageView.image = nil
        self.separatorLineView.isHidden = false
    }
    
    // MARK: Private Methods
    func populate(withLocation location: String?, isSavedLocation: Bool) {
        
        self.searchedLocationLabel.text = location
        
        if isSavedLocation {
            
            //self.savedLocationImageView.image = UIImage(named: "request_job_star_select")
            
        } else {
            
           // self.savedLocationImageView.image = UIImage(named: "request_job_star_deselect")
        }
    }
}
