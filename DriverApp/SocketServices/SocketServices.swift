//
//  SocketServices.swift
//  DriverApp
//
//  Created by Appinventiv on 30/10/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

internal typealias successClosure = (_ success : Bool, _ data: JSON) -> Void

func faliureBlock(){
    hideLoader()
}

class SocketServices{
    
    //Location Update During Trip
    
    class func updateLocationOnride(params :JSONDictionary){
        
        
        SocketManegerInstance.socket?.emit("LocationUpdate", params)
        
    }
    
    class func curr_updateLocationOnride(params :JSONDictionary){
        
        
        SocketManegerInstance.socket?.emit("CurrLocation", params)
        
    }

    
    class func update_Location_on_trip_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("LocationUpdate_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
    }

    
    class func curr_update_Location_on_trip_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("CurrLocation_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
    }
    
    //Socket_On_RideRequest
    class func socketOnRideRequest(completion: @escaping successClosure){
    
        SocketManegerInstance.socket?.on("RideRequest", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
            
                faliureBlock()
            }
        })
    }
    
    //Socket_Emit_AcceptRide
    class func socketEmitAcceptRide(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("acceptRide", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_AcceptRide
    class func socketOnAcceptRide_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("acceptRide_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    //Socket_Emit_CancelRide
    class func socketEmitCancelRide(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("CancelRide", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_CancelRide
    class func socketOnCancelRide_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("CancelRide_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    //Socket_Emit_StartRide
    class func socketEmitStartRide(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("StartRide", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_StartRide
    class func socketOnStartRide_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("StartRide_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    //Socket_On_ReachLocation
    class func socketOnReachLocation_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("SetArrived_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
    }
    
    //Socket_Emit_ReachLocation
    class func socketEmitReachLocation(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("SetArrived", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_Emit_EndRide
    class func socketEmitEndRide(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("EndRide", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_StartRide
    class func socketOnEndRide_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("EndRide_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    //Socket_Emit_RegainState
    class func socketEmitRegainState(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("RegainState", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_StartRide
    class func socketOnRegainState_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("RegainState_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    
    //Socket_On_ChangeLocation
    class func socketOnChangeLocation_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("DropChange", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    //Socket_Emit_AcceptChangeLocation
    class func socketEmitAcceptChangeLocation(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("SetChangeDrop", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_AcceptChangeLocation
    class func socketOnAcceptChangeLocation_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("SetChangeDrop_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    
    // pickup request flow
    
    //Socket_On_pickup_RideRequest
    
    class func socketOn_pickup_RideRequest(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("PickupRequest", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
    }
    
    
    class func pickup_RideRequest_Accept(params :[String:Any]){
        
        let ack = SocketManegerInstance.socket?.emitWithAck("AcceptPickup", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }

    
    
    //Socket_On_pickup_RideRequest
    
    class func pickup_RideRequest_Accept_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("AcceptPickup_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
    }
    
    //Socket_Emit_AcceptChangeLocation
    class func socketEmitRequestPickup(params :JSONDictionary){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("RequestPickup", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_AcceptChangeLocation
    class func socketOnRequestPickup_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("RequestPickup_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                if json["code"].intValue == 200 || json["code"].intValue == 209 {
                    
                    completion(true, json)
                    
                } else {
                    
                    showToastWithMessage(json["message"].stringValue)
                }
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
    
    //Socket_Emit_CancelPickupRequest
    class func socketEmitCancelPickupRequest(params :JSONDictionary){
        
        let ack = SocketManegerInstance.socket?.emitWithAck("CancelPickupRequest", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            hideLoader()
        })
    }
    
    //Socket_On_CancelPickupRequest
    class func socketOnCancelPickupRequest_res(completion: @escaping successClosure){
        
        SocketManegerInstance.socket?.on("CancelPickupRequest_res", callback: { (data, ack) in
            
            if !data.isEmpty{
                
                let result  = data.first!
                let json    = JSON(result)
                
                completion(true, json)
                
            } else {
                
                faliureBlock()
            }
        })
        
    }
}

