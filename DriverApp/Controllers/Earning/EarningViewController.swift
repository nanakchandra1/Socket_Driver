//
//  EarningViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

enum From_To_Date_Select {
    
    case from,to
    
}


class EarningViewController: BaseViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var calenderContentview: FSCalendar!
    @IBOutlet weak var earningsTableView: UITableView!
    @IBOutlet weak var totalEarningLbl: UILabel!
    @IBOutlet weak var totalEarnValueLbl: UILabel!
    @IBOutlet weak var calenderViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var toDate: UILabel!

    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var earningsButton: UIButton!
    @IBOutlet weak var serviceChargeButton: UIButton!
    @IBOutlet weak var netEarningButton: UIButton!
    
    
    
    // Calendar date colors
    let selectedDateColor = UIColor(colorLiteralRed: 219/255, green: 0, blue: 84/255, alpha: 1);
    let unSelectedDateColor = UIColor(colorLiteralRed: 189/255, green: 189/255, blue: 189/255, alpha: 1)
    let otherMonthDateColor = UIColor(colorLiteralRed: 82/255, green: 82/255, blue: 82/255, alpha: 1)
    //MARK:- Private Variables
    var earningDetailList = JSONDictionaryArray()
    var currentDate: Date!
    var from_To_Date_Select = From_To_Date_Select.from
    var currentDateStr = ""
    var fromdateStr:String?
    var todateStr:String?
    var from_Date: Date?
    var to_date: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationView.setMenuButton()
        self.setUpCalendarView()
        self.setUpSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let dateStr = dateFormatter.string(from: self.currentDate)
        self.monthLabel.text = dateStr.uppercased()
        dateFormatter.dateFormat = "dd MMM yyyy"
        self.currentDateStr = dateFormatter.string(from: self.currentDate)
        self.getEarningsFor("", to_date: "")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
    }

    //MARK:- Private Methods
    
    fileprivate func setUpCalendarView(){

        self.calenderContentview.delegate = self
        self.calenderContentview.dataSource = self

    }
    
    fileprivate func setUpSubviews() {
        
        self.navigationTitleLabel.text = MY_EARNINGS.localized
        self.fromDate.text = FROM.localized
        self.toDate.text = TO.localized
        self.dateButton.setTitle(DATE.localized, for: .normal)
        self.earningsButton.setTitle(EARNINGS.localized, for: .normal)
        self.serviceChargeButton.setTitle(SERVICE_CHARGE.localized, for: .normal)
        self.netEarningButton.setTitle(NET_EARNINGS.localized, for: .normal)
        
        
        self.earningsTableView.dataSource = self
        self.earningsTableView.delegate = self
        self.calenderViewHeightConstant.constant = 0
        let dateFormatter = DateFormatter()
        let date = Date()
        let from_Date = self.calenderContentview.currentPage
        printlnDebug(from_Date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: from_Date)
        dateFormatter.dateFormat = "dd MMM"
        let from_selectDate = dateFormatter.string(from: from_Date)
        let to_selectDate = dateFormatter.string(from: date)

        self.from_Date = from_Date
        self.to_date = date
        self.fromDate.text = from_selectDate
        self.toDate.text = to_selectDate
        self.fromdateStr = dateStr
        self.todateStr = dateStr
        
        self.calenderContentview.select(self.from_Date)

        self.getEarningsFor("",to_date: "")

    }
    
    
    fileprivate func getEarningsFor(_ from_date: String,to_date: String) {
        
        if isNetworkAvailable() {
            
            var params = JSONDictionary()
            
            params["date_from"] = from_date as AnyObject
            params["date_to"] = to_date as AnyObject
            params["action"] = "driver" as AnyObject


            showLoader()
            getEarningApi(params, completionHandler: { response in
                printlnDebug(response["result"])
                if let tot_earn = response["till_date"]{
                    self.totalEarnValueLbl.text = "  $\(tot_earn)"
                }
                if let data = response["result"] as? JSONDictionaryArray {
                    self.earningDetailList = data
                    self.earningsTableView.reloadData()
                }
                hideLoader()
            })
        } else {
            showToastWithMessage(noNetwork)
            hideLoader()
        }
    }

    
    //MARK:- IBAction Methods
    @IBAction func previousBtnAction(_ sender: UIButton) {
        
        let date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.month, value: -1, to: self.calenderContentview.currentPage, options: [])
        self.calenderContentview.select(date, scrollToDate: true)
        self.calenderContentview.deselect(date!)
        
    }
    
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        
        let date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.month, value: 1, to: self.calenderContentview.currentPage, options: [])
        self.calenderContentview.select(date, scrollToDate: true)
        self.calenderContentview.deselect(date!)

    }
    
    @IBAction func fromDateBtnTapped(_ sender: UIButton) {
        
        self.calenderContentview.select(self.from_Date)
        self.earningDetailList.removeAll(keepingCapacity: false)
        self.earningsTableView.reloadData()
        self.from_To_Date_Select = .from
        self.todateStr = nil
        self.toDate.text = "To"
        self.to_date = nil
        self.showCalender()
    }
    
    
    @IBAction func toDateBtnTapped(_ sender: UIButton) {
        
        self.earningDetailList.removeAll(keepingCapacity: false)
        self.earningsTableView.reloadData()

        if self.to_date  == nil{
            self.calenderContentview.deselect(self.from_Date!)
        }else{
            self.calenderContentview.select(self.to_date)
        }
        if self.fromdateStr == nil{
            showToastWithMessage("Please select from date")
            return
        }
        self.from_To_Date_Select = .to
        self.showCalender()
    }
}

extension EarningViewController: FSCalendarDataSource, FSCalendarDelegate {
    

    
    func setcalendar(_ calendar: FSCalendar, date: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM yyyy"
        let dateString = dateFormatter.string(from: date)
        self.monthLabel.text = dateString.uppercased()
        dateFormatter.dateFormat = "dd MMM"
        let selectDate = dateFormatter.string(from: date)
        
        if self.from_To_Date_Select == .from{
            self.fromDate.text = selectDate
            self.fromdateStr = dateStr
            self.from_Date = date
            if self.from_Date!.isGreaterThanDate(self.currentDate){
                self.calenderContentview.deselect(date)
                showToastWithMessage("From date can not be greater than To current date")
                self.calenderContentview.reloadData()
                self.fromDate.text = "From"
               // self.from_Date = nil
                return
            }
        }else{
            
            self.todateStr = dateStr
            self.to_date = date
            if self.from_Date!.isGreaterThanDate(date){
                self.calenderContentview.deselect(date)
                showToastWithMessage("You can not select previous date")
                self.calenderContentview.reloadData()
                self.toDate.text = "To"
                self.to_date = nil
                return
            }
            self.toDate.text = selectDate
        }

        if self.todateStr != nil && self.fromdateStr != nil{
            self.getEarningsFor(self.fromdateStr!,to_date: self.todateStr!)
        }
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        self.currentDateStr = dateFormatter.string(from: date)
        self.hideCalender()
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.setcalendar(calendar, date: date)
        if monthPosition == .previous || monthPosition == .next{
            
            self.calenderContentview.setCurrentPage(date, animated: true)
        }
        
    }
    
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
       let date = calendar.currentPage
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let dateStr = dateFormatter.string(from: date)
        self.monthLabel.text = dateStr.uppercased()
        
    }
    
    
    func hideCalender(){
        UIView.animate(withDuration: 0.5, animations: {
            self.calenderViewHeightConstant.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { (true) in
        }) 
    }
    
    func showCalender(){
        UIView.animate(withDuration: 0.5, animations: {
            self.calenderViewHeightConstant.constant = 250
            self.view.layoutIfNeeded()
        }, completion: { (true) in
        }) 

    }
    
}

extension EarningViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.earningDetailList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "earningCell", for: indexPath) as! EarningTableCell
        let data = self.earningDetailList[indexPath.row]
        let date = data["_id"] as? String ?? "2017-03-04"
        cell.dateLbl.text = self.converStringToDateFor_Show(date)
        let earning = data["total_earning"] ?? "0" as AnyObject
        cell.earningAmountLabel.text = "$\(earning)"
        let net_earning = data["net_earning"] ?? "0" as AnyObject
        cell.netEarningLbl.text = "$\(net_earning)"
        let service_charge = data["pickup_deduction"] ?? "0" as AnyObject
        cell.serviceChargesLbl.text = "$\(service_charge)"
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "TripsVC") as! TripsVC
        if let date = self.earningDetailList[indexPath.row]["_id"] as? String{
            obj.dateStr = date
            obj.showDate = self.converStringToDate(date)
        }
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }

    func converStringToDate(_ date: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "SGT")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date1 = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        let strDate = dateFormatter.string(from: date1!)
        return strDate

    }
    
    func converStringToDateFor_Show(_ date: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "SGT")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date1 = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        let strDate = dateFormatter.string(from: date1!)
        return strDate
        
    }

}


class EarningTableCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var serviceChargesLbl: UILabel!
    @IBOutlet weak var netEarningLbl: UILabel!
    @IBOutlet weak var earningAmountLabel: UILabel!
    @IBOutlet weak var separatorLineView: UIView!
    
}


