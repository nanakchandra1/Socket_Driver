//
//  ChangeDropModel.swift
//  DriverApp
//
//  Created by Appinventiv on 03/11/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ChangeDropModel{

    var ride_id : String!
    var new_fare : String!
    var dropAddress = ""
    var dropLat = [String]()
    var dropLong = [String]()
    var timeStamp : String!
    var cd_position : String!
    var dropTable : JSONDictionaryArray!
    
    init(with data: JSON) {
        
        self.ride_id = data["ride_id"].stringValue
        self.new_fare = data["new_fare"].stringValue
        self.timeStamp = data["timeStamp"].stringValue
        self.cd_position = data["cd_position"].stringValue

        self.dropTable = data["drop"].arrayObject as? [JSONDictionary] ?? []
        
        let drop = data["drop"].arrayValue
        for i in 0..<drop.count{
            
            self.dropAddress += "\(i+1). " + drop[i]["address"].stringValue + "\n"
            self.dropLat.append(drop[i]["latitude"].stringValue)
            self.dropLong.append(drop[i]["longitude"].stringValue)
        }
    }
}

//{
//    "ride_id" : "59fc418a09eca235d80b4ebc",
//    "new_fare" : null,
//    "drop" : [
//    {
//    "latitude" : 27.1766701,
//    "place_id" : "",
//    "longitude" : 78.00807449999999,
//    "address" : "Agra, Uttar Pradesh, India"
//    }
//    ],
//    "timeStamp" : "2017-11-03T12:59:45.305Z",
//    "cd_position" : 0
//}
