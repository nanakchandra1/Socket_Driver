//
//  ForgotPasswordViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {
    
    // MARK: Constants
    
    
    // MARK: Variables
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textFieldBorderView: UIView!
        
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var lastDotView: UIView!
    
    @IBOutlet weak var dontWorryLabel: UILabel!
    @IBOutlet weak var pleaseFollowStepsLabel: UILabel!
    @IBOutlet weak var enterRegisteredMobileNumber: UILabel!
    @IBOutlet weak var navTitleLabel: UILabel!
    
    
    
    // MARK: View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navTitleLabel.text = FORGOT_PASSWORD.localized
        self.dontWorryLabel.text = DONT_WORRY.localized
        self.pleaseFollowStepsLabel.text = OTP_DESC.localized
        self.enterRegisteredMobileNumber.text = FORGIE_ENTER_MOBILE_NUMBER.localized
        self.sendBtn.setTitle(C_SEND.localized, for: .normal)
        
        
        self.initialSetup()
        
        self.mobileNumberTextField.delegate = self
        self.countryCodeTextField.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.mobileNumberTextField.text = nil
        self.countryCodeTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private methods
    
    func initialSetup() {
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        
        // Customising buttons and label
        self.sendBtn.layer.cornerRadius = cornerRadius
        
        self.textFieldBorderView.layer.cornerRadius = cornerRadius
        self.textFieldBorderView.layer.borderColor = UIColor.lightGray.cgColor
        self.textFieldBorderView.layer.borderWidth = 1.5

        // Drawing traingle for slant View
        
        let slope: CGFloat = IsIPad ? 70:50
        
        self.cancelBtn.addSlope(withColor: UIColor.gray, ofWidth: slope, ofHeight: slope)
        
        if self.cancelBtn.imageView != nil {
          
            self.cancelBtn.bringSubview(toFront: self.cancelBtn.imageView!)
        }
        self.cancelBtn.imageEdgeInsets = IsIPad ? UIEdgeInsetsMake(0, 28, 22, 0):UIEdgeInsetsMake(0, 18, 14, 0)
        
        self.firstDotView.layer.cornerRadius = cornerRadius
        self.centerDotView.layer.cornerRadius = cornerRadius
        self.lastDotView.layer.cornerRadius = cornerRadius
    }
    

    // Check is all field details are valid
    func isAllFieldsVerified() -> Bool {
        
        if self.countryCodeTextField.text == nil || self.countryCodeTextField.text!.isEmpty {
            
            showToastWithMessage(ForgotPasswordStrings.countryCodeRequired.localized)
            return false
            
        } else if (self.mobileNumberTextField.text == nil) || self.mobileNumberTextField.text!.isEmpty {
            
            showToastWithMessage(ForgotPasswordStrings.mobileRequired.localized)
            return false
            
        } else if !isValidPhoneNumber(str: self.mobileNumberTextField.text!) {
            
            showToastWithMessage(ForgotPasswordStrings.invalidMobile.localized)
            return false
        }
        
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerified() {
            
            // #Warning: Need code for navigation
            self.sendOTPAction()
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        UserDefaults.clearUserDefaults()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        UserDefaults.clearUserDefaults()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Web APIs
    
    func sendOTPAction() {
        
        guard isNetworkAvailable() else{
            return
        }
        
        showLoader()
        let params = ["mobile":(self.countryCodeTextField.text!+self.mobileNumberTextField.text!)]
        
        ServiceClass.forgotPassowrdApi(params) { (data) in
            
            let otp = data["result"]["temp_otp"].stringValue

            let otpVc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
            otpVc.OTP = otp
            otpVc.mobileNumberText = (self.countryCodeTextField.text!+self.mobileNumberTextField.text!)
            self.navigationController?.pushViewController(otpVc, animated: true)

        }
    }
    
}

// MARK: Text Field Delegate Life Cycle Methods

extension ForgotPasswordViewController: UITextFieldDelegate {
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.mobileNumberTextField.text = self.mobileNumberTextField.text!
    }
    
}


// MARK: UIPickerView Delegate  Methods

extension ForgotPasswordViewController: ShowCountryDetailDelegate {
    
    func getCountryDetails(_ text:String!,countryName:String!,Max_NSN_Length:Int!,Min_NSN_Length:Int!,countryShortName : String!){
        self.countryCodeTextField.text = text
    }
}

