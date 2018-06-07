
//  EarningReceiptVC.swift
//  DriverApp
//
//  Created by Appinventiv on 16/03/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class EarningReceiptVC: UIViewController {

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var wavFeeLbl: UILabel!
    @IBOutlet weak var wavFeeAmntLbl: UILabel!
    @IBOutlet weak var myEarnLbl: UILabel!
    @IBOutlet weak var myEarnAmntLbl: UILabel!
    @IBOutlet weak var cancelChargeLbl: UILabel!
    @IBOutlet weak var cancelChrgeAmntLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var discountAmntLbl: UILabel!
    @IBOutlet weak var waitingChargeLbl: UILabel!
    @IBOutlet weak var waitingChargeAmntLbl: UILabel!
    @IBOutlet weak var cancelationHeight: NSLayoutConstraint!
    @IBOutlet weak var bgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var netEarnLbl: UILabel!
    @IBOutlet weak var netEarnAmnt: UILabel!
    
    var dateStr = ""
    var tripDetail = JSONDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
       // self.dateLbl.text = self.dateStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initialSetup(){
    
        self.navigationTitle.text = EARNING_RECEIPT.localized
        self.wavFeeLbl.text = WAV_FEE.localized
        self.myEarnLbl.text = MY_EARNINGS.localized
        self.cancelChargeLbl.text = CANCELLATION_CHARGE.localized
        self.waitingChargeLbl.text = WAITING_CHARGES.localized
        self.netEarnLbl.text = NET_EARNINGS.localized
        self.discountLbl.text = PICKUP_DEDUCTION.localized
        
        
        let wav_earning = self.tripDetail["wav_earning"] as? String ?? "0"
        let cancel_deduction = self.tripDetail["cancel_deduction"] as? String ?? "0"
        let wav_waiting_fee = self.tripDetail["wav_waiting_fee"] as? String ?? "0"
        let driver_valet_earning = self.tripDetail["driver_valet_earning"] as? String ?? "0"
        let driver_pickup_earning = self.tripDetail["driver_pickup_earning"] as? String ?? "0"
        let driver_cancel_earning = self.tripDetail["driver_cancel_earning"] as? String ?? "0"
        let pickup_deduction = self.tripDetail["pickup_deduction"] as? String ?? "0"
        let driver_waiting_fee = self.tripDetail["driver_waiting_fee"] as? String ?? "0"
        //let discount = self.tripDetail["discount_amount"] as? String ?? "0"

        //let wavFee = Double(wav_earning)! + Double(wav_waiting_fee)!
        
        let myEarning = Double(driver_valet_earning)! + Double(driver_pickup_earning)! + Double(driver_cancel_earning)! + Double(driver_waiting_fee)!
        
        let totalEarn = myEarning + Double(wav_waiting_fee)! + Double(cancel_deduction)!
        
        let deduction = Double(pickup_deduction)! + Double(cancel_deduction)!
        let netEarning = myEarning - deduction
        
        self.netEarnAmnt.text = "$\(netEarning)"
        self.wavFeeAmntLbl.text = "$\(wav_earning)"
        self.myEarnAmntLbl.text = "$\(myEarning)"
        self.cancelChrgeAmntLbl.text = "$\(cancel_deduction)"
        self.discountAmntLbl.text = "$\(pickup_deduction)"
        self.waitingChargeAmntLbl.text = "$\(driver_waiting_fee)"
        let type = self.tripDetail["type"] as? String ?? "valet"
        if type.lowercased() == "pickup"{
            self.cancelationHeight.constant = 0
            self.bgViewHeight.constant = 280
        }else{
            self.cancelationHeight.constant = -35
            self.bgViewHeight.constant = 245
        }
        delay(0.01) {
            self.bgView.addDashedBorder()
        }
        
        if let date = self.tripDetail["the_date"] as? String{
            self.dateLbl.text = covert_UTC_to_Local_WithTime(date)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }

}


extension UIView {
    func addDashedBorder() {
        let color = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        //(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}

