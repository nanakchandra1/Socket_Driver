//
//  SingltonClass.swift
//  DriverApp
//
//  Created by Appinventiv on 16/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

let driverSharedInstance = SingltonClass.sharedInstance


class SingltonClass {
    
    var notificationCount: Int = 0
    var pickupDriverDetail = JSONDictionaryArray()
    var selectedIndexPath = [IndexPath]()
    var ride_id = ""
    var rideDetail = JSONDictionary()
    var changelocData = JSONDictionary()
    static let sharedInstance = SingltonClass()
    
    fileprivate init(){
        
    }
    
}
