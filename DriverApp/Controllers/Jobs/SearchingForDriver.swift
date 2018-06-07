//
//  SearchingForDriver.swift
//  DriverApp
//
//  Created by Appinventiv on 03/01/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import UIKit

class SearchingForDriver: UIViewController {

    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var searchinForDriverLabel: UILabel!
    
    
    
    
    var info = JSONDictionary()
    var ride_id = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchinForDriverLabel.text = SEARCHING_FOR_DRIVER.localized

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchingForDriver.startAnimate), name:NSNotification.Name(rawValue: SATRTANIMATE), object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SATRTANIMATE), object: nil)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let halo = PulsingHaloLayer()
        halo.position = view.center
        self.animateView.layer.addSublayer(halo)
        halo.backgroundColor = APP_TAB_RED_COLOR.cgColor
        halo.haloLayerNumber = 5
        halo.radius = screenWidth / 3
        halo.animationDuration = 5
        halo.zPosition = 3
        halo.start()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func startAnimate(){
        self.viewDidLayoutSubviews()
        
    }

    

//    @IBAction func crossbtnTapped(_ sender: UIButton) {
//        
//        var params = JSONDictionary()
//        params["ride_id"]        = self.ride_id as AnyObject
//        
//        params["action"]        = "cancel" as AnyObject
//        params["cancelled_by"]  = "user" as AnyObject
//        params["reason"]        = "I want to cancel" as AnyObject
//        
//        showLoader()
//        rideActionApi(params) { (success) in
//            
//            hideLoader()
//            self.dismiss(animated: true, completion: nil)
//            sharedAppdelegate.stausTimer.invalidate()
//            hideLoader()
//           // gotoHomeVC()
//        }
//    }
    
    @IBAction func crossbtnTapped(_ sender: UIButton) {
        
        var params = JSONDictionary()
        params["ride_id"]        = self.ride_id as AnyObject
        
        params["action"]        = "cancel" as AnyObject
        params["cancelled_by"]  = "user" as AnyObject
        params["reason"]        = "I want to cancel" as AnyObject
        
        
        SocketServices.socketEmitCancelPickupRequest(params: params)
        
        SocketServices.socketOnCancelPickupRequest_res { (success, data) in
            
            self.dismiss(animated: true, completion: nil)
            sharedAppdelegate.stausTimer.invalidate()
        }
        //        showLoader()
        //        rideActionApi(params) { (success) in
        //
        //            hideLoader()
        //            self.dismiss(animated: true, completion: nil)
        //            sharedAppdelegate.stausTimer.invalidate()
        //            hideLoader()
        //           // gotoHomeVC()
        //        }
    }


}
