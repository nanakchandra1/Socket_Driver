//
//  OTPViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class OTPViewController: BaseViewController {
    
    // MARK: Variables
    var OTP: String!
    var mobileNumberText:String!
    var code:String!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var lastDotView: UIView!
    
    @IBOutlet weak var firstDigitTextField: UITextField!
    @IBOutlet weak var secondDigitTextField: UITextField!
    @IBOutlet weak var thirdDigitTextField: UITextField!
    @IBOutlet weak var fourthDigitTextField: UITextField!
    
    @IBOutlet weak var dontWorryLabel: UILabel!
    @IBOutlet weak var otpGuideLabel: UILabel!
    @IBOutlet weak var enterOTPLabel: UILabel!
    
    @IBOutlet weak var navTitleLabel: UILabel!
    
    
    // MARK: View controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // showToastWithMessage("Your OTP is: \(self.OTP)")
        
        self.navTitleLabel.text = FORGOT_PASSWORD.localized
        self.dontWorryLabel.text = DONT_WORRY.localized
        self.otpGuideLabel.text = OTP_DESC.localized
        self.enterOTPLabel.text = OTP_ENTER_OTP.localized
        
        self.initialSetup()
        
        self.firstDigitTextField.delegate = self
        self.secondDigitTextField.delegate = self
        self.thirdDigitTextField.delegate = self
        self.fourthDigitTextField.delegate = self
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.firstDigitTextField.text = nil
        self.secondDigitTextField.text = nil
        self.thirdDigitTextField.text = nil
        self.fourthDigitTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func initialSetup() {
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        let slope: CGFloat = IsIPad ? 70:50

        self.cancelBtn.addSlope(withColor: UIColor.gray, ofWidth: slope, ofHeight: slope)
        if self.cancelBtn.imageView != nil {
            
            self.cancelBtn.bringSubview(toFront: self.cancelBtn.imageView!)
        }
        self.cancelBtn.imageEdgeInsets = IsIPad ? UIEdgeInsetsMake(0, 28, 22, 0):UIEdgeInsetsMake(0, 18, 14, 0)

        // Cutomising TextFields View
        self.textFieldView.layer.borderWidth = 1.5
        self.textFieldView.layer.borderColor = UIColor.lightGray.cgColor
        self.textFieldView.layer.cornerRadius = cornerRadius
        self.textFieldView.clipsToBounds = true
        
        // Cutomising Buttons
        self.verifyBtn.layer.cornerRadius = cornerRadius
        self.resendBtn.layer.cornerRadius = cornerRadius
        
        self.firstDotView.layer.cornerRadius = cornerRadius
        self.centerDotView.layer.cornerRadius = cornerRadius
        self.lastDotView.layer.cornerRadius = cornerRadius
    }
    
    // Makes user enter only one digit in text field
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
        
    }
    // Check is all field details are valid
    func isAllFieldsVerified() -> Bool {
        
        if self.OTP.isEmpty {
            
            showToastWithMessage(LoginVCStrings.otpREquired.localized)
            return false
            
        } else if self.OTP.characters.count < 4 {
            
            showToastWithMessage(LoginVCStrings.invalidPin.localized)
            return false
        }
        
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.OTP = self.firstDigitTextField.text! + self.secondDigitTextField.text! + self.thirdDigitTextField.text! + self.fourthDigitTextField.text!
        
        if isAllFieldsVerified() {
            
            // #Warning: Need code for navigation
            self.verifyOTP()
        }
    }
    
    @IBAction func resendBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.firstDigitTextField.text = ""
        self.secondDigitTextField.text = ""
        self.thirdDigitTextField.text = ""
        self.fourthDigitTextField.text = ""

        self.resendOTPAction()
    }
    
    
    // MARK: Web APIs
    func resendOTPAction() {
        
        guard isNetworkAvailable() else{
            return
        }
        showLoader()
        let params = ["mobile":self.mobileNumberText] as JSONDictionary
        
        ServiceClass.forgotPassowrdApi(params) { (data) in
            
            printlnDebug(data)
        }
    }

    func verifyOTP() {
        
        guard isNetworkAvailable() else{
            return
        }
        showLoader()
        var params = JSONDictionary()
        params["action"] = "mobile" as AnyObject
        params["mobile"] = self.mobileNumberText as AnyObject
        params["otp"] = self.OTP as AnyObject
        
        ServiceClass.verifyOTPApi(params) { (data) in
            
            let updatePasswordVc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "UpdatePasswordViewController") as! UpdatePasswordViewController
            updatePasswordVc.mobileNumberText = self.mobileNumberText
            self.navigationController?.pushViewController(updatePasswordVc, animated: true)

        }

        
    }
}

// MARK: Text field delegate life cycle methods

extension OTPViewController: UITextFieldDelegate {
    
    
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
