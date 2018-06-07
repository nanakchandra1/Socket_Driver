//
//  CurrentUser.swift
//  DriverApp
//
//  Created by Appinventiv on 26/12/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

class CurrentUser{


    static var code : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.CODE)
    }
    
    static var ride_id : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.ride_id)
    }
    
    
    static var pickup : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.PICKUP)
    }


    static var user_id : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.UserId)
    }

    static var full_name : String? {
        
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.FULL_NAME)
    }
    static var email : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.EMAIL)
    }
    static var mobile : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.MOBILE)
    }
    
    static var token : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.TOKEN)
    }
    static var country_code : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.COUNTRY_CODE)
    }
    static var user_image : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.USER_IMAGE)
    }
    
    static var amount : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.AMOUNT)
    }
    
    static var trip_state : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.TRIP_STATE)
    }

    
//    static var userData : AnyObject?{
//        return NSUserDefaults.userDefaultForKey(NSUserDefaultsKeys.USERDATA)
//    }
//    
//    static var vehicles : AnyObject?{
//        return NSUserDefaults.userDefaultForKey(NSUserDefaultsKeys.VEHICLES)
//    }
//    
//    static var card_detail : AnyObject?{
//        return NSUserDefaults.userDefaultForKey(NSUserDefaultsKeys.CARD_DETAILS)
//    }
//    
//    
    static var skills : [String]?{
        return UserDefaults.userdefaultStringArrayForKey(NSUserDefaultKey.SKILLS)
    }
    
    
    static var type : [String]?{
        return UserDefaults.userdefaultStringArrayForKey(NSUserDefaultKey.TYPE)
    }

    static var online_for : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.ONLINE_FOR)
    }
    static var stop_accepting : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.STOP_ACCEPTING)
    }

    
    static var seating : Int? {
        return UserDefaults.userdefaultIntForKey(NSUserDefaultKey.SEATING)
    }
    
    static var arrived : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.ARRIVED)
    }

    
    static var driver_arriving_state : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.DRIVER_ARRIVING_STATE)
    }

    static var vmodel : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.V_MODEL)
    }
    static var plate_no : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.PLATE_NO)
    }
    static var uid : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.UID)
    }
    static var notification_status : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.NOTIFICATION_STATUS)
    }

    static var average_rating : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.AVERAGE_RATING)
    }
    
    static var card_token : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.CARD_TOKEN)
    }
    
    static var stripe_id : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.STRIPE_ID)
    }
    
    static var ridestate : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.ride_State)
    }

    
    static var r_type : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.R_TYPE)
    }

    static var d_type : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.D_TYPE)
    }


    static var gender : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.GENDER)
    }
    
    static var lisenceNumber : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultKey.DLN)
    }
}
