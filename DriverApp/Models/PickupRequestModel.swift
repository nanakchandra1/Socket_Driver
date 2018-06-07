//
//  PickupRequestModel.swift
//  DriverApp
//
//  Created by Appinventiv on 10/11/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON


struct PickupRequestModel{
    
    var dropAddress = ""
    var dropLat:Double = 0
    var dropLong:Double = 0
    
    var pickupAddress :String!
    var picLat:Double = 0
    var picLong:Double = 0

    var ride_id : String!
    
    var contact : String!
    var image : String!
    var user_name : String!
    
    var userLat : String!
    var userLong : String!
    
    var total_fare : String!
    var vehicleModel : String!
    var vehicleNo : String!
    var vehicleType : String!
    var timeStamp : String!
    var driverContact  : String!
    var driverLat  : String!
    var driverLong  : String!
    var driverID  : String!
    var driverImage  : String!
    var driverName  : String!
    var driverUid  : String!
    
    var p_mode : String!
    var status : Int!
    var p_amount : String!
    var user_rating : Int!
    
    
    init(with data : JSON) {
        
        
        self.status = data["status"].intValue
        self.p_amount = data["p_amount"].stringValue
        self.p_mode = data["p_mode"].stringValue
        self.user_rating = data["user_rating"].intValue
        
        let drop = data["drop"].dictionaryValue
        self.dropAddress = drop["address"]!.stringValue
        self.dropLat = drop["latitude"]!.doubleValue
        self.dropLong = drop["longitude"]!.doubleValue

        
        let pickup = data["pickup"].dictionaryValue
        
        self.pickupAddress = pickup["address"]!.stringValue
        self.picLat = pickup["latitude"]!.doubleValue
        self.picLong = pickup["longitude"]!.doubleValue
        
        self.ride_id = data["ride_id"].stringValue
//        self.total_fare = data["total_fare"].stringValue
//        
//        
//        let userTable = data["user_detail"].dictionaryValue
//        
//        self.contact = data["user_contact"].stringValue
//        self.image = data["user_image"].stringValue
//        self.user_name = data["user_name"].stringValue
//        
//        let vechicleTable = userTable["vehicle"]?.dictionaryValue
//        
//        self.vehicleNo = vechicleTable?["no"]?.stringValue
//        self.vehicleModel = vechicleTable?["model"]?.stringValue
//        self.vehicleType = vechicleTable?["type"]?.stringValue
//        
//        self.timeStamp = data["timeStamp"].stringValue
//        
//        let driverTable = data["driver_detail"].dictionaryValue
//        
//        self.driverContact = driverTable["contact"]?.stringValue
//        self.driverID = driverTable["driver_id"]?.stringValue
//        self.driverImage = driverTable["image"]?.stringValue
//        self.driverName = driverTable["name"]?.stringValue
//        self.driverUid = driverTable["uid"]?.stringValue
//        
//        
//        let driverLocation = driverTable["driver_current_loc"]?.dictionaryValue
//        
//        self.driverLong = driverLocation?["coordinates"]?.arrayValue[0].stringValue
//        self.driverLat = driverLocation?["coordinates"]?.arrayValue[1].stringValue
    }
    
    init() {
        
    }
    
}
