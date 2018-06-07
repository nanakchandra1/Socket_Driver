//
//  SettingsViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu

class SettingsViewController: UIViewController {
    
    // MARK: IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var settingLabel: UILabel!
    
    // MARK: Constants
    //MARK:- =================================================

    let settingsArray = ["Notification", "Share App", "Terms & Condition" , "About", "Privacy Policy", "Change Password"]
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingLabel.text = S_SETTINGS.localized.uppercased()
        self.navigationView.setMenuButton()
        self.initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        self.settingsTableView.dataSource = self
        self.settingsTableView.delegate = self
        
        self.settingsTableView.rowHeight = IsIPad ? 70:54
    }
    
    func toggleNotification(_ sender: UIButton) {
        
        var params = JSONDictionary()

        if CurrentUser.notification_status == Status.zero{
            params["status"] = Status.one as AnyObject

        }else{
            params["status"] = Status.zero as AnyObject

        }
        showLoader()
        
        ServiceClass.notificationStatusAPI(params) { (success) in
            
            if CurrentUser.notification_status == Status.zero{
                
                UserDefaults.save(Status.one as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
                
            }else{
                UserDefaults.save(Status.zero as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
                
                
            }
            self.settingsTableView.reloadData()

            
        }
//        notificationStatusAPI(params, SuccessBlock: { (result: Bool) in
//            hideLoader()
//            if CurrentUser.notification_status == Status.zero{
//                UserDefaults.save(Status.one as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
//                
//            }else{
//                UserDefaults.save(Status.zero as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
//   
//                
//            }
//            self.settingsTableView.reloadData()
//        }) { (error: NSError) in
//            hideLoader()
//        }

    }
    

    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }

    

}

// MARK: TableView Datasource Life Cycle Methods
//MARK:- =================================================

extension SettingsViewController: UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        
        cell.populate(withSettingName: self.settingsArray[indexPath.row])
        cell.notificationSwitchBtn.addTarget(self, action: #selector(self.toggleNotification(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            
        case 1:
            
            self.displayShareSheet("Invite your friends to join WAV: https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/1224596233")
            
        case 2:
            

            let obj = getStoryboard(StoryboardName.Setting).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            obj.str = "TERMS AND CONDITIONS"
            obj.action = "terms-and-conditions"
            self.navigationController?.pushViewController(obj, animated: true)

            
        case 3:
            
            let obj = getStoryboard(StoryboardName.Setting).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            obj.str = "ABOUT"
            obj.action = "about-us"
            self.navigationController?.pushViewController(obj, animated: true)
            
        case 4:
            
            let obj = getStoryboard(StoryboardName.Setting).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            obj.str = "PRIVACY POLICY"
            obj.action = "privacy-policy"
            self.navigationController?.pushViewController(obj, animated: true)

            
        case 5:
            
            let obj = getStoryboard(StoryboardName.Setting).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            self.navigationController?.pushViewController(obj, animated: true)
            
        default:
            printlnDebug("error")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }

    
    
}


// MARK: Class for SettingsTableViewCell
//MARK:- =================================================

class SettingsTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var notificationSwitchBtn: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.notificationSwitchBtn.isHidden = true
        self.arrowImageView.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: Private Methods
    func populate(withSettingName settingName: String) {
        
        if settingName == "Notification" {
            
            if CurrentUser.notification_status == Status.zero{
                self.notificationSwitchBtn.setImage(UIImage(named: "settings_off_btn"), for: UIControlState())

            }else{
                self.notificationSwitchBtn.setImage(UIImage(named: "settings_on_btn"), for: UIControlState())
            }

            self.notificationSwitchBtn.isHidden = false
            self.arrowImageView.isHidden = true
            
        } else {
            
            self.notificationSwitchBtn.isHidden = true
            self.arrowImageView.isHidden = false
        }
        self.settingLabel.text = settingName
    }
    
}
