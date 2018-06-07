//
//  UpdatePasswordViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
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


class UpdatePasswordViewController: UIViewController {

    // MARK: Variables
    var mobileNumberText:String!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var lastDotView: UIView!
    
    @IBOutlet weak var dontWorryLabel: UILabel!
    @IBOutlet weak var otpGuideLabel: UILabel!
    @IBOutlet weak var enterNewPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    @IBOutlet weak var navTitleLabel: UILabel!
    
    
    
    
    // MARK: View Controller Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navTitleLabel.text = FORGOT_PASSWORD.localized
        self.dontWorryLabel.text = DONT_WORRY.localized
        self.otpGuideLabel.text = OTP_DESC.localized
        self.enterNewPasswordLabel.text = PLEASE_ENTER_PASS.localized
        self.confirmPasswordLabel.text = PLEASE_ENTER_CONFIRM_PASS.localized
        self.updateBtn.setTitle(C_UPDATE.localized, for: .normal)
        
        self.initialSetup()
        
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func initialSetup() {
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        let slope: CGFloat = IsIPad ? 70:50
        
        // Customising buttons and label
        self.updateBtn.layer.cornerRadius = cornerRadius
        
        self.newPasswordTextField.layer.cornerRadius = cornerRadius
        self.newPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.newPasswordTextField.layer.borderWidth = 1.5
        
        self.confirmPasswordTextField.layer.cornerRadius = cornerRadius
        self.confirmPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.confirmPasswordTextField.layer.borderWidth = 1.5
        
        // Drawing traingle for slant View
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
        
        if (self.newPasswordTextField.text == nil) || self.newPasswordTextField.text!.isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.newPass.localized)
            return false
            
        } else if self.newPasswordTextField.text!.characters.count < 6 {
            
            showToastWithMessage(ChangePasswordStrings.passMinLength.localized)
            return false
            
        } else if (self.confirmPasswordTextField.text == nil) || self.confirmPasswordTextField.text!.isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.confirmPass.localized)
            return false
            
        } else if self.newPasswordTextField.text! != self.confirmPasswordTextField.text! {
            
            showToastWithMessage(ChangePasswordStrings.newPassNotMatch)
            return false
        }
        
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerified() {
            
            // #Warning: Need code for navigation
            self.updatePasswordAction()
        }
    }
    
    // MARK: Web APIs
    
    func updatePasswordAction() {
        
        guard isNetworkAvailable() else{
            return
        }
        showLoader()
        let params = ["new_password":self.newPasswordTextField.text!, "confirm_password":self.newPasswordTextField.text!,"action":"reset","mobile":self.mobileNumberText] as [String : Any]
        
        ServiceClass.updatePasswordApi(params) { (data) in
            
            UserDefaults.clearUserDefaults()
            self.navigationController?.popToRootViewController(animated: true)

        }
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: Text Field Delegate Life Cycle Methods

extension UpdatePasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.characters.count > 30 {
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.next {
            
            self.confirmPasswordTextField.becomeFirstResponder()
            
        } else {
            
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.newPasswordTextField {
            
            self.newPasswordTextField.text = self.newPasswordTextField.text!
        
        } else {
            
            self.confirmPasswordTextField.text = self.confirmPasswordTextField.text!
        }
    }
}
