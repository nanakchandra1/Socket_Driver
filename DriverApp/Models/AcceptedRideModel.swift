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
    
    init(with data : JSON) {
        
        
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
        
        self.contact = data["contact"].stringValue
        self.image = data["image"].stringValue
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


//
//{
//    "driver_detail" =         {
//        contact = "+2138130302339";
//        "driver_current_loc" =             {
//            coordinates =                 (
//                "77.38120000000001",
//                "28.621"
//            );
//            type = Point;
//        };
//        "driver_id" = 59509ecead6f6e723d590d05;
//        image = "uploads/149845575859509eceac471.jpg";
//        name = Test;
//        uid = "WAV-DRV-1498455673";
//    };
//    drop =         (
//        {
//            address = "Noida City Center, Noida, Uttar Pradesh, India";
//            latitude = "28.5747441";
//            longitude = "77.3560263";
//            "place_id" = ChIJq3O6GZblDDkRmoGWYr9waDc;
//        }
//    );
//    message = "Ride has been accepted by driver.";
//    pickup =         {
//        address = "8, Sector 63 Rd, D Block, Sector 63, Noida, Uttar Pradesh 201307, India";
//        latitude = "28.6202357";
//        longitude = "77.3814512";
//    };
//    "ride_id" = 59f2d69629c57f3a9f33de64;
//    timeStamp = "2017-10-27T06:48:35.496Z";
//    "user_detail" =         {
//        vehicle =             {
//            desc = "Ref high nanak";
//            model = Guests;
//            no = JEHBFHU;
//            type = car;
//        };
//    };
//}
