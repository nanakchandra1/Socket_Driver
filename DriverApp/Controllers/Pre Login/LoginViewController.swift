//
//  ViewController.swift
//  DriverApp
//
//  Created by Saurabh Shukla on 9/6/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu
import SwiftyJSON

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginViewController: BaseViewController {
    
    
    //MARK:Variables
    
    
    //MARK:IBOutlets
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    
    // MARK: View Controller life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginBtn.setTitle(LOGIN.localized, for: .normal)
        self.forgotPasswordBtn.setTitle(LOGIN_FORGOT_PASSWORD.localized, for: .normal)
        
        
        self.initialSetup()
        
        if isIPhoneSimulator {
            
            self.emailTextField.text = "test@gmail.com"
            self.passwordTextField.text = "1234567890"
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func initialSetup() {
        
        self.checkIfuserIsLoggedIn()
        // Adjusting height of constraint according to screen
        // Setting Attributed placeholder to textfields
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email Address".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        self.loginBtn.layer.cornerRadius = (IsIPad ? 70:45)/2
        self.loginBtn.layer.borderWidth = 1
        self.loginBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.emailTextField.autocorrectionType = .no
        self.passwordTextField.autocorrectionType = .no
    }
    
    // Check is all field details are valid
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func isAllFieldsVerified() -> Bool {
        
        if (self.emailTextField.text == nil) || self.emailTextField.text!.isEmpty{
            
            showToastWithMessage(LoginVCStrings.emailRequired.localized)
            return false
            
        } else if !isValidEmail(self.self.emailTextField.text!) {
            
            showToastWithMessage(LoginVCStrings.invalidEmail.localized)
            return false
            
        } else if (self.passwordTextField.text == nil) || self.passwordTextField.text!.isEmpty {
            
            showToastWithMessage(LoginVCStrings.passRequired.localized)
            return false
            
        } else if self.passwordTextField.text!.characters.count < 6 {
            
            showToastWithMessage(LoginVCStrings.passLength.localized)
            return false
        }
        
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.isAllFieldsVerified() {
            // #Warning: Need navigation code here
            self.loginAction()
        }
    }
    
    @IBAction func forgotPasswordBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func showPassTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            self.passwordTextField.isSecureTextEntry = false

        }else{
            self.passwordTextField.isSecureTextEntry = true
        }
    }
    
    
    //MARK: Web APIs
    func loginAction(){
        
        guard isNetworkAvailable() else{
            return
        }
        showLoader()
        
        var params = JSONDictionary()
        
        params["email"] = self.emailTextField.text! as AnyObject
        params["password"] = self.passwordTextField.text! as AnyObject
        params["device_id"] = DeviceUUID as AnyObject
        params["device_model"] = DeviceModelName as AnyObject
        params["platform"] = OS_PLATEFORM as AnyObject
        params["os_version"] = SystemVersion_String as AnyObject
        
        if sharedAppdelegate.device_Token != nil{
            
            params["device_token"] = sharedAppdelegate.device_Token as AnyObject
            
        }
        else{
            
            params["device_token"] = "1456456" as AnyObject
            
        }
        
        printlnDebug(params)
        
        ServiceClass.loginApi(params) { (data) in
            
            printlnDebug(data)
            
            guard let code = data["statusCode"].int else {return}
            let message = data["message"].stringValue
            if code != 200{
                showToastWithMessage(message)
            }
            UserDefaults.save("\(code)" as AnyObject, forKey: NSUserDefaultKey.CODE)
            let result = data["result"]
            userdata.saveJSONDataToUserDefault(result)
            if CurrentUser.token != nil{
                
                let socketManager = SocketIOManager()
                
                socketManager.connectSocket(handler: { (data) in
                    
                })
                
            }
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            self.checkIfuserIsLoggedIn()
        }
        
    }
    
    func checkIfuserIsLoggedIn(){
        
        if let code = CurrentUser.code{
            
            if code == "232" || code == "219"{
                
                let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if code == "200"{
                
                gotoHomeVC()
            }
        }
        
    }
    
    
    func saveDriverData(_ User_info: JSONDictionary){
        
        if let code = User_info["statusCode"]{
            UserDefaults.save("\(code)" as AnyObject, forKey: NSUserDefaultKey.CODE)
            printlnDebug(CurrentUser.code)
        }
        
        if let info = User_info["result"] as? JSONDictionary {
            
            
            guard let _id = info["_id"] as? String else{return}
            UserDefaults.save(_id as AnyObject, forKey: NSUserDefaultKey.UserId)
            
            
            if let stripe = info["stripe"] as? String {
                
                UserDefaults.save(stripe as AnyObject, forKey: NSUserDefaultKey.STRIPE_ID)
                
            }

            
            if let token = info["token"] as? String {
                UserDefaults.save(token as AnyObject, forKey: NSUserDefaultKey.TOKEN)
            }
            
            if let name = info["name"] as? String {
                UserDefaults.save(name as AnyObject, forKey: NSUserDefaultKey.FULL_NAME)
                
            }
            
            if let default_pmode = info["default_pmode"] as? String {
                UserDefaults.save(default_pmode as AnyObject, forKey: NSUserDefaultKey.CARD_TOKEN)
                
            }

            if let email = info["email"] as? String {
                UserDefaults.save(email as AnyObject, forKey: NSUserDefaultKey.EMAIL)
            }
            if let mobile = info["phone"] as? String {
                UserDefaults.save(mobile as AnyObject, forKey: NSUserDefaultKey.MOBILE)
            }
            if let c_code = info["country_code"] as? String {
                UserDefaults.save(c_code as AnyObject, forKey: NSUserDefaultKey.COUNTRY_CODE)
            }
            if let image = info["image"] as? String {
                UserDefaults.save(image as AnyObject, forKey: NSUserDefaultKey.USER_IMAGE)
            }
            if let amnt = info["wallet_amount"] {
                UserDefaults.save("\(amnt)" as AnyObject, forKey: NSUserDefaultKey.AMOUNT)
            }
            if let v_model = info["vmodel"] as? String {
                UserDefaults.save(v_model as AnyObject, forKey: NSUserDefaultKey.V_MODEL)
            }
            if let vehivle = info["vehicle"] as? String {
                UserDefaults.save(vehivle as AnyObject, forKey: NSUserDefaultKey.VEHICLE)
            }
            if let p_no = info["plate_no"] as? String {
                UserDefaults.save(p_no as AnyObject, forKey: NSUserDefaultKey.PLATE_NO)
            }
            if let skills = info["skills"] as? [String] {
                UserDefaults.save(skills as AnyObject, forKey: NSUserDefaultKey.SKILLS)
            }
            if let type = info["type"] as? [String] {
                UserDefaults.save(type as AnyObject, forKey: NSUserDefaultKey.TYPE)
            }
            if let seat = info["seating"] {
                UserDefaults.save("\(seat)" as AnyObject, forKey: NSUserDefaultKey.SEATING)
            }
            if let uid = info["uid"] as? String {
                UserDefaults.save(uid as AnyObject, forKey: NSUserDefaultKey.UID)
            }
            if let notification_status = info["notification_status"] {
                UserDefaults.save("\(notification_status)" as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
            }
            if let average_rating = info["average_rating"] {
                UserDefaults.save("\(average_rating)" as AnyObject, forKey: NSUserDefaultKey.AVERAGE_RATING)
            }
            
            if let onle_for = info["online_for"] {
                UserDefaults.save("\(onle_for)" as AnyObject, forKey: NSUserDefaultKey.ONLINE_FOR)
            }
            if let onle_for = info["stop_accepting"] {
                UserDefaults.save("\(onle_for)" as AnyObject, forKey: NSUserDefaultKey.STOP_ACCEPTING)
            }

            if let uid = info["gender"] as? String {
                UserDefaults.save(uid as AnyObject, forKey: NSUserDefaultKey.GENDER)
            }
            
            if let uid = info["dl_no"] as? String {
                UserDefaults.save(uid as AnyObject, forKey: NSUserDefaultKey.DLN)
            }
            
            if let ride = info["rides"] as? JSONDictionary{
                
                printlnDebug(ride)
                
                if let type = ride["type"] as? String{
                    if type.lowercased() == RequestType.pickup{
                        
                        UserDefaults.save(RequestType.pickup as AnyObject, forKey: NSUserDefaultKey.R_TYPE)

                        if let driver_id = ride["driver_detail"]!["driver_id"] as? String,let user_id = ride["user_id"] as? String{
                            
                            if _id == driver_id{
                                UserDefaults.save(DriverType.pickup_driver as AnyObject, forKey: NSUserDefaultKey.D_TYPE)
                                
                            }else if _id == user_id{
                            
                                UserDefaults.save(DriverType.pickup_user as AnyObject, forKey: NSUserDefaultKey.D_TYPE)
                            }
                        }
                    }else{
                        UserDefaults.save(RequestType.valet as AnyObject, forKey: NSUserDefaultKey.R_TYPE)

                    }
                }
                UserDefaults.save("ride" as AnyObject, forKey: NSUserDefaultKey.ride_State)

            }
        }
        
    }
    
//    func saveDataForMobileVerification(_ User_info: JSON){
//        
//        guard let code = User_info["statusCode"].string else{ return}
//        guard let info = User_info["result"].dictionary else{ return}
//        guard let email = info["email"]?.string else{ return}
//        guard let mobile = info["phone"]?.string else{ return}
//        guard let c_code = info["country_code"]?.string else{ return}
//        
//        UserDefaults.save(code as AnyObject, forKey: NSUserDefaultKey.CODE)
//        UserDefaults.save(email as AnyObject, forKey: NSUserDefaultKey.EMAIL)
//        UserDefaults.save(mobile as AnyObject, forKey: NSUserDefaultKey.MOBILE)
//        UserDefaults.save(c_code as AnyObject, forKey: NSUserDefaultKey.COUNTRY_CODE)
//
//    }
//    
//    
//    func saveDataForEnterMobileNumber(_ User_info: JSON){
//        
//        guard let code = User_info["statusCode"].string else{ return}
//        guard let info = User_info["result"].dictionary else{ return}
//        guard let temp = info["temp_req"]?.dictionary else{ return}
//        guard let email = temp["email"]?.string else{ return}
//            
//        UserDefaults.save("\(code)" as AnyObject, forKey: NSUserDefaultKey.CODE)
//        UserDefaults.save(email as AnyObject, forKey: NSUserDefaultKey.EMAIL)
//
//    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === self.passwordTextField{
        if textField.text?.characters.count > 30 {
            
            return false
        }
        return true
        }else{
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.next {
            
            self.passwordTextField.becomeFirstResponder()
            
        } else {
            
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.emailTextField {
            
            self.emailTextField.text = self.emailTextField.text!
            self.emailTextField.text = self.emailTextField.text!
        } else {
            
            self.passwordTextField.text = self.passwordTextField.text!
        }
    }
}

