//
//  OTPVerificationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu
import SwiftyJSON


class OTPVerificationViewController: UIViewController {
    
    // MARK: Variables
    var OTP = ""
    var mobileNumberText:String?
    var emailStr = ""
    var code = ""
    
    // MARK: IBOutlets
    
    @IBOutlet weak var phoneImageView: UIImageView!
    
    @IBOutlet weak var firstDigitTextField: UITextField!
    @IBOutlet weak var secondDigitTextField: UITextField!
    @IBOutlet weak var thirdDigitTextField: UITextField!
    @IBOutlet weak var fourthDigitTextField: UITextField!
    
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var changeMobileNumberBtn: UIButton!
    
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var enterVerficationCodeLabel: UILabel!
    
    
    
    // MARK: View controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navTitleLabel.text = MOBILE_VARIFICATION.localized
        self.enterVerficationCodeLabel.text = ENTER_VARIFY_CODE.localized
        self.resendOTPBtn.setTitle(C_RESEND.localized, for: .normal)
        self.changeMobileNumberBtn.setTitle(CHANGE_MOBILE_NUMBER.localized, for: .normal)
        
        // Do any additional setup after loading the view.
        
        self.initialSetup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // showToastWithMessage("Your OTP is: \(self.OTP)")
                    self.firstDigitTextField.text = ""
                    self.secondDigitTextField.text = ""
                    self.thirdDigitTextField.text = ""
                    self.fourthDigitTextField.text = ""

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    
    func initialSetup () {
        
        let textFieldCornerRadius: CGFloat = IsIPad ? 5:3
        let btnCornerRadius: CGFloat = (IsIPad ? 70:45)/2
        
        // Customising buttons
        self.resendOTPBtn.layer.cornerRadius = btnCornerRadius
        self.resendOTPBtn.layer.borderWidth = 1
        self.resendOTPBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
        
        self.changeMobileNumberBtn.layer.cornerRadius = btnCornerRadius
        self.changeMobileNumberBtn.layer.borderWidth = 1
        self.changeMobileNumberBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
        
        self.firstDigitTextField.delegate = self
        self.secondDigitTextField.delegate = self
        self.thirdDigitTextField.delegate = self
        self.fourthDigitTextField.delegate = self
        
        self.firstDigitTextField.layer.cornerRadius = textFieldCornerRadius
        self.secondDigitTextField.layer.cornerRadius = textFieldCornerRadius
        self.thirdDigitTextField.layer.cornerRadius = textFieldCornerRadius
        self.fourthDigitTextField.layer.cornerRadius = textFieldCornerRadius
        
    }
    
    // Method to move to previuos textfield
    func setPreviousResponder(_ textField: UITextField) {
        
        if textField === self.secondDigitTextField {
            
            self.firstDigitTextField.becomeFirstResponder()
            
        } else if textField === self.thirdDigitTextField {
            
            self.secondDigitTextField.becomeFirstResponder()
            
        } else if textField === self.fourthDigitTextField {
            
            self.thirdDigitTextField.becomeFirstResponder()
            
        }
        
           }
    
    // Method to move to next textfield
    func setNextResponder(_ textField: UITextField) {
        
        if textField === self.firstDigitTextField {
            
            self.secondDigitTextField.becomeFirstResponder()
            
        } else if textField === self.secondDigitTextField {
            
            self.thirdDigitTextField.becomeFirstResponder()
            
        } else if textField === self.thirdDigitTextField {
            
            self.fourthDigitTextField.becomeFirstResponder()
            
        } else if textField === self.fourthDigitTextField {
            
            self.fourthDigitTextField.resignFirstResponder()
            
        }
        self.OTP = (self.firstDigitTextField.text ?? "") + (self.secondDigitTextField.text ?? "") + (self.thirdDigitTextField.text ?? "") + (self.fourthDigitTextField.text ?? "")
        
        if self.OTP.characters.count>=4 {
            
            self.view.endEditing(true)
            self.verifyOTP()
        }

        
    }
    
    
    
    // MARK: IBActions
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func resendOTPBtnTapped(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        resendOTPAction()
    }
    
    @IBAction func changeMobileNumberBtnTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        
            if let code = CurrentUser.code{
                
                if "\(code)" == "219"{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
            self.navigationController?.pushViewController(obj, animated: true)
                }
                else{
                    self.navigationController?.popViewController(animated: true)
                }

            }
    }
    
    // MARK: Web APIs
    func resendOTPAction() {
        
        self.firstDigitTextField.text = ""
        self.secondDigitTextField.text = ""
        self.thirdDigitTextField.text = ""
        self.fourthDigitTextField.text = ""

        guard isNetworkAvailable() else{
            return
        }
        var params = [String:AnyObject]()

        
        params["action"] = "email" as AnyObject
        params["email"] = self.emailStr as AnyObject
        params["phone"] = self.mobileNumberText! as AnyObject
        params["country_code"] = self.code as AnyObject

        printlnDebug(params)
        showLoader()

        ServiceClass.sendOTPApi(params) { (data) in
            
            printlnDebug(data)
        }
    }
    
    
    
    func verifyOTP() {
        
        guard isNetworkAvailable() else{
            return
        }
        var params = [String:AnyObject]()
        
        params["email"] = self.emailStr as AnyObject
        params["phone"] = self.mobileNumberText as AnyObject
        params["country_code"] = self.code as AnyObject
        params["action"] = "email" as AnyObject
        params["otp"] = self.OTP as AnyObject
        
        showLoader()

        printlnDebug(params)
        
        ServiceClass.verifyOTPApi(params) { (data) in
            
//            self.saveDriverData(data)
            gotoHomeVC()

        }
        
    }
    

    
    
    func saveDriverData(_ User_info: JSON){
        
        
        if let code = User_info["statusCode"].int{
            UserDefaults.save("\(code)" as AnyObject, forKey: NSUserDefaultKey.CODE)
            printlnDebug(CurrentUser.code)
        }
        
        let info = User_info["result"]
        
        if let _id = info["_id"].string {
            UserDefaults.save(_id as AnyObject, forKey: NSUserDefaultKey.UserId)
        }
        
        if let token = info["token"].string {
            UserDefaults.save(token as AnyObject, forKey: NSUserDefaultKey.TOKEN)
        }
        if let name = info["name"].string {
            UserDefaults.save(name as AnyObject, forKey: NSUserDefaultKey.FULL_NAME)
            
        }
        if let email = info["email"].string {
            UserDefaults.save(email as AnyObject, forKey: NSUserDefaultKey.EMAIL)
        }
        if let mobile = info["phone"].string {
            UserDefaults.save(mobile as AnyObject, forKey: NSUserDefaultKey.MOBILE)
        }
        if let c_code = info["country_code"].string {
            UserDefaults.save(c_code as AnyObject, forKey: NSUserDefaultKey.COUNTRY_CODE)
        }
        if let image = info["image"].string {
            UserDefaults.save(image as AnyObject, forKey: NSUserDefaultKey.USER_IMAGE)
        }
        if let amnt = info["wallet_amount"].string {
            UserDefaults.save("\(amnt)" as AnyObject, forKey: NSUserDefaultKey.AMOUNT)
        }
        if let v_model = info["vmodel"].string {
            UserDefaults.save(v_model as AnyObject, forKey: NSUserDefaultKey.V_MODEL)
        }
        if let vehivle = info["vehicle"].string {
            UserDefaults.save(vehivle as AnyObject, forKey: NSUserDefaultKey.VEHICLE)
        }
        if let p_no = info["plate_no"].string {
            UserDefaults.save(p_no as AnyObject, forKey: NSUserDefaultKey.PLATE_NO)
        }
        if let skills = info["skills"].arrayObject {
            UserDefaults.save(skills as AnyObject, forKey: NSUserDefaultKey.SKILLS)
        }
        if let type = info["type"].arrayObject {
            UserDefaults.save(type as AnyObject, forKey: NSUserDefaultKey.TYPE)
        }
        if let seat = info["seating"].string {
            UserDefaults.save("\(seat)" as AnyObject, forKey: NSUserDefaultKey.SEATING)
        }
        if let uid = info["uid"].string {
            UserDefaults.save(uid as AnyObject, forKey: NSUserDefaultKey.UID)
        }
        if let notification_status = info["notification_status"].string {
            UserDefaults.save("\(notification_status)" as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
        }
        if let average_rating = info["average_rating"].string {
            UserDefaults.save("\(average_rating)" as AnyObject, forKey: NSUserDefaultKey.AVERAGE_RATING)
        }
        
        if let onle_for = info["online_for"].string {
            UserDefaults.save("\(onle_for)" as AnyObject, forKey: NSUserDefaultKey.ONLINE_FOR)
        }
        if let onle_for = info["stop_accepting"].int {
            UserDefaults.save("\(onle_for)" as AnyObject, forKey: NSUserDefaultKey.STOP_ACCEPTING)
        }
        if let _ = info["rides"].dictionaryObject{
            
            UserDefaults.save("ride" as AnyObject, forKey: NSUserDefaultKey.ride_State)
        }
    }
}

// MARK: Text field delegate life cycle methods

extension OTPVerificationViewController: UITextFieldDelegate {
    
    
//    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//
//        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
//            return false
//        }
//        
//        return super.canPerformAction(action, withSender: sender)
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !(textField.text!.isEmpty) {
            
            textField.text = ""
        }
        
        if (string.characters.count == 0) && (range.length > 0)  {
            
            self.perform(#selector(self.setPreviousResponder(_:)), with: textField, afterDelay: 0.2)
            
        } else {
            
            self.perform(#selector(self.setNextResponder(_:)), with: textField, afterDelay: 0.1)
        }
        
        return true
    }
}
