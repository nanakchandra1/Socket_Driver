//
//  JobDetailsModel.swift
//  DriverApp
//
//  Created by Appinventiv on 27/10/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON


struct JobDetailsModel{
    
    var dropAddress = ""
    var dropLat = [String]()
    var dropLong = [String]()

    var pickupAddress :String!
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
        
        let dropTable = data["drop"].arrayValue
        
        for i in 0..<dropTable.count{
            
            self.dropAddress += "\(i+1). " + dropTable[i]["address"].stringValue + "\n"
            self.dropLat.append(dropTable[i]["latitude"].stringValue)
            self.dropLong.append(dropTable[i]["longitude"].stringValue)
        }
        
        
        let pickupTable = data["pickup"].dictionaryValue
        
        self.pickupAddress = pickupTable["address"]?.stringValue
        self.userLat = pickupTable["latitude"]?.stringValue
        self.userLong = pickupTable["longitude"]?.stringValue
        
        self.ride_id = data["ride_id"].stringValue
        self.total_fare = data["total_fare"].stringValue
        
        
        let userTable = data["user_detail"].dictionaryValue
        
        self.contact = data["user_contact"].stringValue
        self.image = data["user_image"].stringValue
        self.user_name = data["user_name"].stringValue

        let vechicleTable = userTable["vehicle"]?.dictionaryValue
        
        self.vehicleNo = vechicleTable?["no"]?.stringValue
        self.vehicleModel = vechicleTable?["model"]?.stringValue
        self.vehicleType = vechicleTable?["type"]?.stringValue
        
        self.timeStamp = data["timeStamp"].stringValue
        
        let driverTable = data["driver_detail"].dictionaryValue
        
        self.driverContact = driverTable["contact"]?.stringValue
        self.driverID = driverTable["driver_id"]?.stringValue
        self.driverImage = driverTable["image"]?.stringValue
        self.driverName = driverTable["name"]?.stringValue
        self.driverUid = driverTable["uid"]?.stringValue
        
        
        let driverLocation = driverTable["driver_current_loc"]?.dictionaryValue
        
        self.driverLong = driverLocation?["coordinates"]?.arrayValue[0].stringValue
        self.driverLat = driverLocation?["coordinates"]?.arrayValue[1].stringValue
    }
    
    init() {
        
    }
    
}


//{
//    code = 200;
//    message = "Ride request recived";
//    result =     {
//        drop =         {
//            address = "New Delhi, Delhi, India";
//            latitude = "28.6139391";
//            longitude = "77.2090212";
//            "place_id" = "ChIJLbZ-NFv9DDkRzk0gTkm3wlI";
//        };
//        pickup =         {
//            address = "8, Sector 63 Rd, D Block, Sector 63, Noida, Uttar Pradesh 201307, India";
//            latitude = "28.6202357";
//            longitude = "77.3814512";
//        };
//        "ride_id" = 5a0539d4d14a7e2311cf5b1d;
//        timeStamp = "2017-11-10T05:32:04.377Z";
//        "total_fare" = "10.00";
//    };
//}
