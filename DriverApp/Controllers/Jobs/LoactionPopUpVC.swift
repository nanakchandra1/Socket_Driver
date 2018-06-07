//
//  LoactionPopUpVC.swift
//  UserApp
//
//  Created by Appinventiv on 06/01/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

class LoactionPopUpVC: UIViewController {

    //Outlets
    @IBOutlet weak var turnOnGPSTitleLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var popUpDescriptionLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.turnOnGPSTitleLabel.text = TURN_GPS_ON.localized
        self.yesButton.setTitle(YES.localized, for: .normal)
        self.popUpDescriptionLabel.text = LOCATION_POPUP_DESCRIPTION.localized
        self.noButton.setTitle(NO.localized, for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func yesBtnTapped(_ sender: UIButton) {
        
        self.turn_GPS_ON()
        dismiss(animated: true, completion: nil)


    }

    @IBAction func noBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

        
    }

    func turn_GPS_ON() {
        
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }

    


}
