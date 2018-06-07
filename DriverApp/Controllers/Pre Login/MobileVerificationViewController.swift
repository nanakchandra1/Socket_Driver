//
//  MobileVerificationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class MobileVerificationViewController: UIViewController {
    
    // MARK: Constants
    var mobileNumberText:String?
    var email:String?
    var code:String?
    
    // MARK: Variables
    
    
    // MARK: IBOutlets
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var phoneImageView: UIImageView!
    
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var enterMobileNumberLabel: UILabel!
    
    
    
    
    // MARK: View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navTitleLabel.text = MOBILE_VARIFICATION.localized
        self.enterMobileNumberLabel.text = M__VARIFY_ENTER_MOB.localized
        self.submitBtn.setTitle(C_SUBMIT.localized, for: .normal)
        
        // Do any additional setup after loading the view.
        self.countryCodeTextField.attributedPlaceholder = NSAttributedString(string: "Code", attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        self.mobileNumberTextField.attributedPlaceholder = NSAttributedString(string: "Mobile Number", attributes:[NSForegroundColorAttributeName: UIColor.white])
        self.initialSetup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.countryCodeTextField.text = nil
        self.mobileNumberTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func initialSetup() {
        
        // Customising buttons and label
        
        if let c_code = CurrentUser.country_code, let mobile = CurrentUser.mobile{
            self.mobileNumberTextField.text = mobile
            self.countryCodeTextField.text = c_code
        }
        if let email = CurrentUser.email{
            self.email = email
        }
        
        // Delegating TextFields
        self.countryCodeTextField.delegate = self
        self.mobileNumberTextField.delegate = self
        
        self.countryCodeTextField.addRightImage(withImageNamed: "mobile_verification_down_arrow")
        
        self.submitBtn.layer.cornerRadius = (IsIPad ? 70:45)/2
        self.submitBtn.layer.borderWidth = 1
        self.submitBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
    }
    
    
    func isAllFieldsVerifed() -> Bool {
        
        if self.countryCodeTextField.text == nil || self.countryCodeTextField.text!.isEmpty {
            
            showToastWithMessage(ForgotPasswordStrings.countryCodeRequired.localized)
            return false
            
        }
        else if self.mobileNumberTextField.text == nil || self.mobileNumberTextField.text!.isEmpty {
            
            showToastWithMessage(ForgotPasswordStrings.mobileRequired.localized)
            return false
            
        } else if !isValidPhoneNumber(str: self.mobileNumberTextField.text!) {
            
            showToastWithMessage(ForgotPasswordStrings.invalidMobile.localized)
            self.mobileNumberTextField.text = nil
            return false
        }
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        UserDefaults.clearUserDefaults()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtntapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerifed() {
            
            // #Warning: Need code for naviagtion
            self.sendOTPAction()
        }
    }
    
    // MARK: Web APIs
    
    func sendOTPAction() {
        
        guard isNetworkAvailable() else{
            return
        }
        
        var params = [String:AnyObject]()
        
        params["action"] = "email" as AnyObject
        params["email"] = self.email as AnyObject
        params["phone"] = self.mobileNumberTextField.text! as AnyObject
        params["country_code"] = countryCodeTextField.text! as AnyObject
        
        printlnDebug(params)
        
        showLoader()
        
        ServiceClass.sendOTPApi(params) { (data) in
            
            let otp = data["result"]["temp_otp"].intValue
            
            let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "OTPVerificationViewController") as! OTPVerificationViewController
            
            vc.mobileNumberText = self.mobileNumberTextField.text!
            vc.OTP = "\(otp)"
            vc.emailStr = self.email!
            vc.code = self.countryCodeTextField.text!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

// MARK: Text Field Delegate Methods

extension MobileVerificationViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField.isAskingCanBecomeFirstResponder == false)
        {
            //Do your own work on tapping textField.
            if textField === self.countryCodeTextField{
                
                let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if textField === self.countryCodeTextField{
            return false
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text{
            
            let maxLength = 10
            let currentString: NSString = txt as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.mobileNumberTextField {
            
            self.mobileNumberTextField.text = self.mobileNumberTextField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .done {
            
            textField.resignFirstResponder()
        }
        return true
    }
}


// MARK: UIPickerView Delegate  Methods

extension MobileVerificationViewController: ShowCountryDetailDelegate {
    
    func getCountryDetails(_ text:String!,countryName:String!,Max_NSN_Length:Int!,Min_NSN_Length:Int!,countryShortName : String!){
        self.countryCodeTextField.text = text
    }
}
