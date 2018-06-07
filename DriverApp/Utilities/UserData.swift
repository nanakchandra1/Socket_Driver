//
//  UserData.swift
//  UserApp
//
//  Created by Appinventiv on 25/02/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

let userdata = UserData.sharedInstance

final class UserData {
    
    static let sharedInstance = UserData()
    
    func saveJSONDataToUserDefault(_ resDict : JSON) {
        
        if let name = resDict["name"].string{
            UserDefaults.save(name as AnyObject, forKey: NSUserDefaultKey.FULL_NAME)
        }
        
        if let ride_id = resDict["ride_id"].string{
            UserDefaults.save(ride_id as AnyObject, forKey: NSUserDefaultKey.ride_id)
        }
        
        if let email = resDict["email"].string{
            UserDefaults.save(email as AnyObject, forKey: NSUserDefaultKey.EMAIL)
        }
        
        if let mobile = resDict["phone"].string{
            UserDefaults.save(mobile as AnyObject, forKey: NSUserDefaultKey.MOBILE)
        }
        
        if let type = resDict["type"].arrayObject{
        
            UserDefaults.save(type as AnyObject, forKey: NSUserDefaultKey.TYPE)
        }
        
        if let online_for = resDict["online_for"].string{
            UserDefaults.save(online_for as AnyObject, forKey: NSUserDefaultKey.ONLINE_FOR)
        }
        
        if let countryCode = resDict["country_code"].string{
            UserDefaults.save(countryCode as AnyObject, forKey: NSUserDefaultKey.COUNTRY_CODE)
        }
        
        if let token = resDict["token"].string{
            UserDefaults.save(token as AnyObject, forKey: NSUserDefaultKey.TOKEN)
        }
        
        if let default_pmode = resDict["default_pmode"].string{
        
            UserDefaults.save(default_pmode as AnyObject, forKey: NSUserDefaultKey.P_MODE)

        }
        
        if let image = resDict["image"].string{
            UserDefaults.save(image as AnyObject, forKey: NSUserDefaultKey.USER_IMAGE)
        }
        if let gender = resDict["gender"].string{
            UserDefaults.save(gender as AnyObject, forKey: NSUserDefaultKey.GENDER)
        }
        
        if let noti = resDict["notification_status"].string{
            UserDefaults.save(noti as AnyObject, forKey: NSUserDefaultKey.NOTIFICATION_STATUS)
        }
        
        
        if let stripe_id = resDict["stripe"].string{
            UserDefaults.save(stripe_id as AnyObject, forKey: NSUserDefaultKey.STRIPE_ID)
        }
        
            UserDefaults.save(resDict["seating"].intValue as AnyObject, forKey: NSUserDefaultKey.SEATING)

        
//        if (resDict["rides"] as? JSONDictionary) != nil{
//            UserDefaults.save("init" as AnyObject, forKey: NSUserDefaultKey.RIDE_STATE)
//        }
    }
    
}

