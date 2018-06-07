//
//  NotificationVC.swift
//  UserApp
//
//  Created by Appinventiv on 14/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    //MARK:- IBOutletes
    //MARK:- =================================================
    
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var notificationTableView: UITableView!
    
    
    var notificationData = JSONDictionaryArray()
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationTitle.text = NOTIFICATIONS.localized
        
        driverSharedInstance.notificationCount = 0
        self.notificationTableView.delegate = self
        self.notificationTableView.dataSource = self
        getNotifications()
        self.navigationView.setMenuButton()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getNotifications(){
        showLoader()
        
        notificationApi(nil) { (result: JSONDictionaryArray) in
            
            self.notificationData = result
            self.notificationTableView.reloadData()

        }
    }
}


extension NotificationVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.notificationData.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        cell.notiMsg.text = self.notificationData[indexPath.row]["title"] as? String ?? ""
        if let date = self.notificationData[indexPath.row]["date_created"] as? String{
            cell.dateLbl.text = covert_UTC_to_Local_WithTime(date)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showPopUp(self.notificationData[indexPath.row])
    }
    
    
    func showPopUp(_ info: [String: AnyObject]){
        guard let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController else{return}
        if viewController != nil {
            
            printlnDebug(info)
            let popUp = getStoryboard(StoryboardName.Jobs).instantiateViewController(withIdentifier: "NotificationPopUpVC") as! NotificationPopUpVC
            
            popUp.modalPresentationStyle = .overCurrentContext
            popUp.userInfo = info
            
            getMainQueue({
                viewController!.present(popUp, animated: true, completion: nil)
            })
        }
    }
    
}



class NotificationCell: UITableViewCell{
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var notiMsg: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
}
