//
//  TripsVC.swift
//  DriverApp
//
//  Created by Appinventiv on 16/03/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class TripsVC: UIViewController {

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tripTypeLbl: UILabel!
    @IBOutlet weak var netEarningLbl: UILabel!
    @IBOutlet weak var tripsTableView: UITableView!
    
    var dateStr = ""
    var showDate = ""
    var earningDetail = JSONDictionaryArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationTitle.text = TRIPS.localized
        self.tripTypeLbl.text = TRIP_TYPE.localized
        self.netEarningLbl.text = NET_EARNINGS.localized
        
        self.tripsTableView.delegate = self
        self.tripsTableView.dataSource = self
        self.dateLbl.text = self.showDate
        self.getEarningDetail()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    fileprivate func getEarningDetail(){
    
        var params = JSONDictionary()
        
        params["action"] = "driver" as AnyObject
        params["date"] = self.dateStr as AnyObject
        showLoader()
        getEarningDetailApi(params) { (response) in
            printlnDebug(response)
            hideLoader()
            if let detail = response["result"] as? JSONDictionaryArray{
                self.earningDetail = detail
                self.tripsTableView.reloadData()
            }
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension TripsVC: UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.earningDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath) as! TripsCell
        let data = self.earningDetail[indexPath.row]
        if let date = data["the_date"] as? String{
            cell.timeLbl.text = covert_SGT_to_LocalTime(date)
        }
        if let type = data["type"] as? String{
            cell.tripTypeLbl.text = type
        }
        
            cell.netEarningLbl.text = self.calculateNetEarn(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "EarningReceiptVC") as! EarningReceiptVC
        obj.dateStr = self.dateStr
        obj.tripDetail = self.earningDetail[indexPath.row]
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }

    
    func calculateNetEarn(_ tripDetail:JSONDictionary) -> String{
        let cancel_deduction = tripDetail["cancel_deduction"] as? String ?? "0"
        let driver_valet_earning = tripDetail["driver_valet_earning"] as? String ?? "0"
        let driver_pickup_earning = tripDetail["driver_pickup_earning"] as? String ?? "0"
        let driver_cancel_earning = tripDetail["driver_cancel_earning"] as? String ?? "0"
        let pickup_deduction = tripDetail["pickup_deduction"] as? String ?? "0"
        let driver_waiting_fee = tripDetail["driver_waiting_fee"] as? String ?? "0"
        
        let myEarning = Double(driver_valet_earning)! + Double(driver_pickup_earning)! + Double(driver_cancel_earning)! + Double(driver_waiting_fee)!
        let deduction = Double(pickup_deduction)! + Double(cancel_deduction)!
        let netEarning = myEarning - deduction
        return "$\(netEarning)"
    }
}


class TripsCell: UITableViewCell{

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var netEarningLbl: UILabel!
    @IBOutlet weak var tripTypeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
