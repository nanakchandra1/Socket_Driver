//
//  NotificationPopUpVC.swift
//  DriverApp
//
//  Created by Appinventiv on 02/02/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu

class NotificationPopUpVC: UIViewController {
    
    var userInfo = JSONDictionary()
    var url = ""
    
    @IBOutlet weak var popUpview: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var noti_title_Lbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var urlBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = self.userInfo["title"] as? String{
            
            self.noti_title_Lbl.text = title
            
        }
        if let msg = self.userInfo["message"] as? String{
            
            self.msgLbl.text = msg
            
        }
        
        if let urltext = self.userInfo["urltext"] as? String, urltext != "" {
            
            if let url = self.userInfo["url"] as? String, url != ""{
                urlBtn.isHidden = false
                self.urlBtn.setTitle(urltext, for: UIControlState())
            }else{
                self.urlBtn.isHidden = true
            }
        }else{
            self.urlBtn.isHidden = true
        }
        
        
        if let date = self.userInfo["date_created"] as? String{
            self.dateLbl.text = covert_UTC_to_Local_WithTime(date)
        }
        
        if let image = self.userInfo["image"] as? String{
            
            let imageUrlStr = imgUrl + image
            
            if let imageUrl = URL(string: imageUrlStr){
                if image != ""{
                    self.logoImg.isHidden = true
                }
                
                self.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "splash_bg"))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone
    }

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
    
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let view = touches.first?.view {
            if view == self.bgView && !self.bgView.subviews.contains(view) {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func urlBtnTapped(_ sender: UIButton) {
        
        
    }
    
}
