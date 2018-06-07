//
//  SocketManager.swift
//  WashApp
//
//  Created by apple on 05/07/17.
//  Copyright © 2017 saurabh. All rights reserved.
//

import Foundation
import SocketIO

let SocketManegerInstance = SocketIOManager.instance

class SocketIOManager: NSObject {
    
    var socket: SocketIOClient?
    
    
    override init() {
        
        super.init()
        
        self.socket = SocketIOClient(socketURL: URL(string: "http://52.8.169.78:7042/")!, config: [.log(true), .forcePolling(true), .connectParams(["token": CurrentUser.token ?? "","role": "driver"])])
        
    }
    
    static let instance = SocketIOManager()
    
    fileprivate var socketHandlerArr = [(((Void)->Void))]()
    typealias ObjBlock = @convention(block) () -> ()
    
    func connectSocket(handler:((Void)->Void)? = nil){
        
        
        if socket?.status == .connected {
            
            handler?()
            
            return
            
        } else {
            
            if let handlr = handler{
                
                if !socketHandlerArr.contains(where: { (handle) -> Bool in
                    
                    let obj1 = unsafeBitCast(handle as ObjBlock, to: AnyObject.self)
                    let obj2 = unsafeBitCast(handlr as ObjBlock, to: AnyObject.self)
                    
                    return obj1 === obj2
                    
                }){
                    
                    socketHandlerArr.append(handlr)
                }
            }
            
            socket?.connect(timeoutAfter: 5, withHandler: {
                
                
                if self.socket?.status == .connecting{

                    printlnDebug("socket is still connecting")
                }
                
                if self.socket?.status != .connected{
                    self.connectSocket(handler: handler)
                }
                    
                else{
                    
                    handler?()
                }
            })
            
            socket?.on("connected", callback: { data, ack in
                
//                self.checkIfSessionIsValid(data: data)
                NotificationCenter.default.post(name: .connetSocketNotificationName, object: self)
            })
            
            
            if socket?.status != .connecting{
                
                socket?.connect()
            }
        }
        
    }
//    func connectSocket(handler:((Void)->Void)? = nil){
//        
////        guard CurrentUser.loggedInUserExists else {return}
////        
////        print_debug("sid \(socket?.sid ?? "")")
//        
//        if socket?.status == .connected {
//            
//            handler?()
//            
//            return
//            
//        } else {
//            
//        socket?.on("connected", callback: { data, ack in
//            
//            //self.checkIfSessionIsValid(data: data)
//        })
//            self.socket?.connect()
//    }
//    }
    
    func closeConnection() {
        socket?.disconnect()
    }
    
//    fileprivate func checkIfSessionIsValid(data:[Any]){
//        
//        if data.count > 0, let dict = (data[0] as? [String:Any]), let code = dict["code"],let msg = dict["message"]{
//            
//            if "\(code)" == "269"{
//                
//                showToastWithMessage("\(msg)")
//               // SocketManegerInstance.socket?.offAll()
//                SocketManegerInstance.socket?.disconnect()
//                //cleaeUserDefault()
//                //sharedAppdelegate.goToLoginOption()
//            }
//        }
//    }
}

extension Notification.Name{

    static let aceeptRequestNotificationName = Notification.Name("aceeptRequestNotificationName")
    static let cancelRequestNotificationName = Notification.Name("cancelRequestNotificationName")
    static let connetSocketNotificationName = Notification.Name("connetSocketNotificationName")
}
