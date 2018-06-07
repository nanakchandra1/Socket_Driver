//
//  MyProfileViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/12/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SDWebImage
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


class MyProfileViewController: UIViewController {
    
    // MARK: Enums
    // Gender enum
    enum Gender: Int {
        
        case male
        case female
        case undefined
        
        var description: String {
            
            switch self {
                
            case .male: return "Male"
            case .female   : return "Female"
            case .undefined  : return "Undefined"
                
            }
        }
    }
    
    // MARK: Constants
    let fieldArray = ["Email", "Contact Number", "Gender", "Driving Licence Number", "Driver Skills"]
    let profileDetailImages = ["my_profile_mail", "my_profile_call", "profile_setup_gender", "my_profile_name", "myprofile_driver"]
    
    // MARK: Variables
    var isEditable = false
    var userDetailsDict: [String:String] = [:]
    
    var pickerView: UIPickerView!
    var toolbarView: UIToolbar!
    var imageCache = ""
    
    // MARK: IBOutlets
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var myProfileTableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBlurImageView: UIImageView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var avgRatingLabel: UILabel!
    
    // MARK: View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navTitleLabel.text = MY_PROFILE.localized
        self.avgRatingLabel.text = AVG_RATING.localized
        
        self.navigationView.setMenuButton()
        
        self.myProfileTableView.tableFooterView = UIView(frame: CGRect.zero)

        // Delegating FloatRatingView
        self.floatRatingView.delegate = self
        
        // Delegating Table View
        
        self.myProfileTableView.dataSource = self
        self.myProfileTableView.delegate = self
        
        // Delegating picker view
        self.pickerView = UIPickerView()
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userImageView.layer.cornerRadius = 50
        self.userImageView.layer.masksToBounds = true
        

        self.setProfileData()
        
        if imageCache != (CurrentUser.user_image ?? "") {
            self.userBlurImageView.image = UIImage(named: "ic_place_holder")
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    func initialSetup() {
        self.floatRatingView.rating = 0
        // Customising Outlets
        self.userImageView.layer.borderWidth = IsIPad ? 4.5:2.5
        self.userImageView.layer.borderColor = UIColor(red: 115/255, green: 125/255, blue: 134/255, alpha: 1).cgColor
        
        self.tableHeaderView.frame.size.height = IsIPad ? 345:270
        
        self.pickerView.backgroundColor = UIColor.white
        
        // Creating and Customising toolbar
        self.toolbarView = UIToolbar()
        self.toolbarView.backgroundColor = UIColor.white
        
        // Create buttons for toolbar
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(toolbarCancelBtnTapped))
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(toolbarDoneBtnTapped))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        //Add ToolBar Buttons
        self.toolbarView.setItems([cancelBtn, flexibleSpace, doneBtn], animated: true)
        self.toolbarView.sizeToFit()
        
        
        //    let fieldArray = ["Email", "Contact Number", "Gender", "Driving Licence Number", "Driver Skills"]
        
        self.userNameLabel.text = CurrentUser.full_name
        if let rating = CurrentUser.average_rating{
            self.floatRatingView.rating = Float(rating)!

        }
        
        self.userDetailsDict["Email"] = CurrentUser.email
        self.userDetailsDict["Contact Number"] = CurrentUser.mobile
        self.userDetailsDict["Gender"] = CurrentUser.gender
        self.userDetailsDict["Driving Licence Number"] = CurrentUser.lisenceNumber
        
        if CurrentUser.skills != nil{
        var skills = ""
            for (key,value) in (CurrentUser.skills?.enumerated())!{
            
                if key == 0{
                    skills = value
                }else{
                    skills = skills + "'" + value
                }
            }
            self.userDetailsDict["Driver Skills"] = skills

        }
        
        self.myProfileTableView.reloadData()
        
    }
    
    
    func setProfileData(){
        
        
        if CurrentUser.user_image != nil {
            
            let imageUrlStr = imgUrl+(CurrentUser.user_image ?? "")
            if let imageUrl = URL(string: imageUrlStr) {
                
                self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"), options: [], completed: { (image, error, _, url) in
                    
                    if error == nil {
                        
                        let cacheKey = ("userBlurredImage" + (CurrentUser.user_image ?? ""))
                        self.imageCache = (CurrentUser.user_image ?? "")
                        
                        SDImageCache.shared().queryCacheOperation(forKey: cacheKey, done: { (cachedImage, _, _) in
                            
                            if cachedImage != nil {
                                
                                self.userBlurImageView.image = cachedImage
                                
                            } else {
                                
                                SDImageCache.shared().store(image?.blurEffect(60), forKey: cacheKey)
                                self.userBlurImageView.image = image?.blurEffect(60)
                            }
                        })
                    }
                })
                
            }
            else{
                self.userBlurImageView.backgroundColor = UIColor.black
            }
        }
    }
    
    func isAllFieldsVerified() -> Bool {
        
        // #Warning: Verify field data here
        
        if self.userDetailsDict["Email"] == nil || self.userDetailsDict["Email"]!.isEmpty {
            
            showToastWithMessage(LoginVCStrings.emailRequired.localized)
            return false
            
        } else if !isValidEmail(self.userDetailsDict["Email"]!) {
            
            showToastWithMessage(LoginVCStrings.invalidEmail.localized)
            return false
            
        } else if self.userDetailsDict["Contact Number"] == nil || self.userDetailsDict["Contact Number"]!.isEmpty {
            
            showToastWithMessage(ForgotPasswordStrings.mobileRequired.localized)
            return false
            
        } else if !isValidPhoneNumber(str: self.userDetailsDict["Contact Number"]!) {
            
            showToastWithMessage(ForgotPasswordStrings.invalidMobile.localized)
            return false
            
        } else if self.userDetailsDict["Gender"] == nil || self.userDetailsDict["Gender"]!.isEmpty {
            
            showToastWithMessage(LoginVCStrings.genderRequired.localized)
            return false
            
        } else if self.userDetailsDict["Driving Licence Number"] == nil || self.userDetailsDict["Driving Licence Number"]!.isEmpty {
            
            showToastWithMessage(LoginVCStrings.d_l_no_Required.localized)
            return false
            
        } else if self.userDetailsDict["Driver Skills"] == nil || self.userDetailsDict["Driver Skills"]!.isEmpty {
            
            showToastWithMessage(LoginVCStrings.driving_skill_Required.localized)
            return false
            
        }
        
        return true
    }
    
    // Date picker ToolBar Cancel Button
    func toolbarCancelBtnTapped() {
        
        self.view.endEditing(true)
        
    }
    
    // Date picker ToolBar Done Button
    func toolbarDoneBtnTapped() {
        
        let selectedRow = self.pickerView.selectedRow(inComponent: 0)
        
        self.userDetailsDict["Gender"] = Gender(rawValue: selectedRow)?.description ?? "Undefined"
        
        self.myProfileTableView.reloadRows(at: [IndexPath(row: 2, section: 0 )], with: UITableViewRowAnimation.none)
        
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    @IBAction func editProfileBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.isEditable {
            
            if self.isAllFieldsVerified() {
                
                self.saveUserDetailsAction()
                
                sender.setTitle("Edit", for: UIControlState())
                sender.setImage(UIImage(named: "my_profile_edit"), for: UIControlState())
                self.isEditable = false
            }
            
        } else {
            
            sender.setTitle("Save", for: UIControlState())
            sender.setImage(UIImage(named: "my_profile_save"), for: UIControlState())
            self.isEditable = true
        }
    }
    
    // MARK: Web APIs
    func saveUserDetailsAction() {
        
        // #Warning: Save user details service here
    }
    
}

// MARK: FloatRatingViewDelegate
extension MyProfileViewController: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
}

// MARK: TableView DataSource Life Cycle Methods
extension MyProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fieldArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileTableViewCell", for: indexPath) as! MyProfileTableViewCell
        
        cell.populateCell(withImageName: profileDetailImages[indexPath.row], withLabelText: self.fieldArray[indexPath.row], withTextFieldText: (userDetailsDict[self.fieldArray[indexPath.row]] ?? ""))
        
        cell.myProfileTextField.delegate = self
        
        return cell
    }
    
}

// MARK: TableView Delegate Life Cycle Methods
extension MyProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 82:55
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 82:55
    }
    
}

// MARK: TextField Delegate Life Cycle Methods
extension MyProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let cell = textField.superview?.superview as! MyProfileTableViewCell
        
        let indexPath = self.myProfileTableView.indexPath(for: cell)
        
        if indexPath?.row == 2 {
            
            textField.inputView = self.pickerView
            textField.inputAccessoryView = self.toolbarView
            
        } else {
            
            textField.inputView = nil
            textField.inputAccessoryView = nil
        }
        
        return isEditable
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let cell = textField.superview?.superview as! MyProfileTableViewCell
        
        let indexPath = self.myProfileTableView.indexPath(for: cell)!
        
        if indexPath.row == 1 && textField.text?.characters.count > 13 {
            
            return false
        }
        
        let userEnteredString = textField.text
        
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        
        switch self.fieldArray[indexPath.row] {
            
        case "Email":
            self.userDetailsDict["Email"] = String(newString)
            
        case "Contact Number":
            self.userDetailsDict["Contact Number"] = String(newString)
            
        case "Driving Licence Number":
            self.userDetailsDict["Driving Licence Number"] = String(newString)
            
        case "Driver Skills":
            self.userDetailsDict["Driver Skills"] = String(newString)
            
        default:
            break
        }
        
        return true
    }
    
}

// Class for Table View Cell (Not resued anyWhere)
// MARK: My Profile Cell
class MyProfileTableViewCell: UITableViewCell {
    
    // IBOutlets
    
    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myProfileNameLabel: UILabel!
    @IBOutlet weak var myProfileTextField: UITextField!
    
    // Table View Cell Life Cycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addLeftAndRightBorders(ofWidth : 5, ofHeight : 150, withColor : UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1))
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.myProfileImageView.image = nil
        self.myProfileNameLabel.text = nil
        self.myProfileTextField.text = nil
    }
    
    // Private Methods
    
    func populateCell(withImageName imageName: String, withLabelText labelText: String, withTextFieldText textFieldText: String) {
        
        self.myProfileImageView.image = UIImage(named: imageName)
        self.myProfileNameLabel.text = labelText
        self.myProfileTextField.text = textFieldText
        
    }
    
    func addLeftAndRightBorders(ofWidth width: CGFloat, ofHeight height: CGFloat, withColor color: UIColor) {
        
        let leftBorderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        leftBorderView.backgroundColor = color
        
        let rightBorderView = UIView(frame: CGRect(x: screenWidth-width, y: 0, width: width, height: height))
        rightBorderView.backgroundColor = color
        
        self.addSubview(leftBorderView)
        self.addSubview(rightBorderView)
    }
    
}

// MARK: UIPickerView DataSource Methods

extension MyProfileViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 3
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return Gender(rawValue: row)?.description
        
    }
    
}

// MARK: UIPickerView Delegate  Methods

extension MyProfileViewController: UIPickerViewDelegate {
    
    
    
}
