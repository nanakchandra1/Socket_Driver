//
//  SupportVC.swift
//  DriverApp
//
//  Created by Appinventiv on 05/01/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit
import MessageUI

class SupportVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- =========================================
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var mailLbl: UILabel!
    @IBOutlet weak var navigationTitleLabel: UILabel!
   // @IBOutlet weak var phoneLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationTitleLabel.text = SUPPORT.localized
        self.navigationView.setMenuButton()
        showSupport()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func mailTapped(_ sender: UIButton) {
        
        let mailComposeViewController = self.configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    
//    @IBAction func phoneTapped(sender: UIButton) {
//        
//        if self.phoneLbl.text != ""{
//            let phoneNumber = self.phoneLbl.text ?? ""
//            let phone = "telprompt://" + phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
//            if let url = NSURL(string: phone){
//                UIApplication.sharedApplication().openURL(url)
//            }
//        }
//    }
    
    
    func showSupport() {
        let params = ["action": "driver-support"] as JSONDictionary
        
        showLoader()
        
        ServiceClass.staticPagesApi(params) { (data) in
            
            if let mail = data["support_email"].string{

                self.mailLbl.text = mail
            }
        }
    }
}



extension SupportVC: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        navigationController?.navigationBar.isHidden = true
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        if self.mailLbl.text != ""{
            mailComposerVC.setToRecipients([self.mailLbl.text!])
            mailComposerVC.setSubject("")
            mailComposerVC.setMessageBody("", isHTML: false)
        }
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
