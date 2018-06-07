//
//  LeftSidePannelViewController.swift
//  DriverApp
//
//  Created by saurabh on 08/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SDWebImage
import MFSideMenu

var selectedIndex = 1

class LeftSidePannelViewController: UIViewController {
    
    // Constants
    
    let menuDeSelectedImageArray = [" ","sidepanel_home_deselect", "sidepanel_wallet_deselect", "sidepanel_support_deselect", "sidepanel_notification_deselect", "sidepanel_settings_deselect","sidepanel_car","sidepanel_history", "sidepanel_logout_deselect"]
    
    let menuSelectedImageArray = [" ","sidepanel_home_select", "sidepanel_wallet_select", "sidepanel_support_select", "sidepanel_notification_select", "sidepanel_settings_select","sidepanel_car_red","sidepanel_history_red", "sidepanel_logout_select"]

    let menuNameArray = [" ",HOME,MY_WALLET,SUPPORT, NOTIFICATIONS,S_SETTINGS,REQUEST_PICKUP,RIDE_HISTORY,LOGOUT]
    
    var blurredImage : UIImage?

    //MARK: IBOutlets
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var menuTableHeader: UIView!
    @IBOutlet weak var visualView: UIView!
    
    @IBOutlet weak var userBlurImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    

    
    // View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name:NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.menuTableView.reloadData()
    }
    
    
    
    func methodOfReceivedNotification(){
        
        self.menuTableView.reloadData()
    }

}

// MARK: Table View Datasource Life Cycle Methods

extension LeftSidePannelViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.menuNameArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if IsIPad{
            if indexPath.row == 0{
                return 250
            }
            return 100
        }
        
        if indexPath.row == 0{
            return 200
        }
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHeaderTableViewCell", for: indexPath) as! MenuHeaderTableViewCell
            
            cell.setLayOut()
            
            if let name = CurrentUser.full_name {
                cell.menuNameLabel.text = name
            }
            
            if let imageName = CurrentUser.user_image{
            let imageUrlStr = imgUrl+imageName

            if let imageUrl = URL(string: imageUrlStr){
                
                
                cell.profileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"), options: [], completed: { (image, error, _, url) in
                    
                    if error == nil {
                        
                        let cacheKey = "userBlurredImage" + imageName
                        
                        SDImageCache.shared().queryCacheOperation(forKey: cacheKey, done: { (cachedImage, _, _) in

                            
                            if cachedImage != nil {
                                
                                cell.menuImageView.image = cachedImage
                                
                            } else {
                                SDImageCache.shared().store(image?.blurEffect(60), forKey: cacheKey)
                                cell.menuImageView.image = image?.blurEffect(60)
                            }
                        })
                    }
                })
                
            }else{
                cell.menuImageView.backgroundColor = UIColor.black
            }
            }else{
                cell.menuImageView.backgroundColor = UIColor.black
            }



            
        return cell
        
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        delay(0.001, closure: {
            cell.setUpViews(indexPath.row)
            
        })

        
        if indexPath.row == 8{
            cell.lineView.isHidden = true
        }
        else{
            cell.lineView.isHidden = false

        }
        if selectedIndex == indexPath.row {
            
            cell.populateCell(withImage: self.menuSelectedImageArray[indexPath.row], withMenu: self.menuNameArray[indexPath.row].localized.uppercased(), withColor: UIColor(red: 194/255, green: 0, blue: 52/255, alpha: 1))
            
        } else {
            
            cell.populateCell(withImage: self.menuDeSelectedImageArray[indexPath.row], withMenu: self.menuNameArray[indexPath.row].localized.uppercased(), withColor: UIColor.black)
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
//        if selectedIndex == indexPath.row {
//            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
//            return
//        }
        
        selectedIndex = indexPath.row

        
        switch indexPath.row {
        case 0:
            
            let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
            
            let navController = UINavigationController(rootViewController: vc)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets=false
            
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            }
        case 1:
            baseTabBarController?.selectedIndex = 1

        gotoHomeVC()

            
        case 2:
            
            let obj = getStoryboard(StoryboardName.Wallet).instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            
            let navController = UINavigationController(rootViewController: obj)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            }

//        case 3:
//            
//            let obj = getStoryboard(StoryboardName.Wallet).instantiateViewController(withIdentifier: "PaymentMethodID") as! PaymentMethodViewController
//            let navController = UINavigationController(rootViewController: obj)
//            navController.isNavigationBarHidden = true
//            navController.automaticallyAdjustsScrollViewInsets=false
//            mfSideMenuContainerViewController.centerViewController = navController
//            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}

        case 3:
            
            let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
            let navController = UINavigationController(rootViewController: obj)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            }

        case 4:
            
            let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            
            let navController = UINavigationController(rootViewController: obj)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            }

            
        case 5:

            let obj = getStoryboard(StoryboardName.Setting).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            let navController = UINavigationController(rootViewController: obj)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            }

        case 6:
            
            //if CurrentUser.r_type != RequestType.pickup{
                let tabBarCantroller = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RequestARideViewController") as! RequestARideViewController
                let navController = UINavigationController(rootViewController: tabBarCantroller)
                navController.isNavigationBarHidden = true
                navController.automaticallyAdjustsScrollViewInsets=false
                
                mfSideMenuContainerViewController.centerViewController = navController
           // }
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            }

        case 7:
            
            let obj = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "RideHistory") as! RideHistory
            let navController = UINavigationController(rootViewController: obj)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets=false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion { }

        case 8:
                
                guard isNetworkAvailable() else { return }
                showLoader()
                
                ServiceClass.logoutApi(JSONDictionary(), completionHandler: { (data) in
                    
                    printlnDebug(data)
                })

        default:
            break
        }
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
//    }

}

// MARK: Table View Datasource Life Cycle Methods

extension LeftSidePannelViewController: UITableViewDelegate {
    
    //    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //
    //        return self.
    //    }
}

// Class for Table View Cell (Not resued anyWhere)
// MARK: Menu Cell
class MenuTableViewCell: UITableViewCell {
    
    // IBOutlets
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    // Table View Cell Life Cycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.menuImageView.image = nil
        self.menuNameLabel.text = nil
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.menuImageView.image = nil
        self.menuNameLabel.text = nil
    }
    
    // Private Methods
    func setUpViews(_ index: Int){
        
        if index == 4{
            if driverSharedInstance.notificationCount == 0{
                
                self.countLbl.isHidden = true
                
            }else{
                
                self.countLbl.isHidden = false
                self.countLbl.text = "\(driverSharedInstance.notificationCount)"
            }
        }else{
            self.countLbl.isHidden = true
            
        }
        self.countLbl.layer.cornerRadius = 10
        self.countLbl.layer.masksToBounds = true
    }

    
    func populateCell(withImage imageName: String, withMenu menuName: String, withColor textColor: UIColor) {
        
        self.menuImageView.image = UIImage(named: imageName)
        self.menuNameLabel.text = menuName
        self.menuNameLabel.textColor = textColor
    }
    
}



class MenuHeaderTableViewCell: UITableViewCell {
    
    // IBOutlets
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    // Table View Cell Life Cycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    // Private Methods
    
    func setLayOut(){
    
        self.profileImage.layer.borderWidth = 3
        
        
        self.shadowView.layer.cornerRadius = self.shadowView.bounds.height / 2
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.height / 2
        self.profileImage.layer.masksToBounds = true
        

        
                self.profileImage.layer.borderColor = UIColor(red: 219/255, green: 0, blue: 84/255, alpha: 1).cgColor
                self.profileImage.clipsToBounds = true
        
                self.shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
                self.shadowView.layer.shadowOpacity = 0.80
                self.shadowView.layer.shadowRadius = 2.0
                self.shadowView.clipsToBounds = false

    }
    
    
    func applyBlurEffect(_ image: UIImage){
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.value(forKey: "outputImage") as! CIImage
        let blurredImage = UIImage(ciImage: resultImage)
        self.menuImageView.image = blurredImage
        
    }
    
    func populateCell(withImageName imageName: String, withMenuName menuName: String) {
        
        self.menuImageView.image = UIImage(named: imageName)
        self.menuNameLabel.text = menuName
    }
    
}

