//
//  NetworkAdapter.swift
//  Onboarding
//
//  Created by Neelam Yadav on 24/7/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import Alamofire


typealias JSONDictionary = [String : AnyObject]
typealias JSONDictionaryArray = [JSONDictionary]


typealias SuccessResponse = (json : JSON) -> ()
typealias FailureResponse = (error : NSError) -> ()



final class NetworkAdapter {
    
    
    static func GET(url : String, parameters : JSONDictionary, success : SuccessResponse, failure : FailureResponse) {
        
        let req = Alamofire.request(.GET, url, parameters: parameters)
        
        if isLoggingEnabled {
            req.logRequest()
        }
        
        req.handleResponse(success: success, failure: failure)
    }
    
    
    
    static func POST(url : String, parameters : JSONDictionary,header: [String:String], success : SuccessResponse, failure : FailureResponse) {
        
        let req = Alamofire.request(.POST, url, parameters: parameters, encoding: ParameterEncoding.URL, headers: header)
        
        if isLoggingEnabled {
            req.logRequest()
        }
        
        req.handleResponse(success: success, failure: failure)
    }
    
    
    
    static func POSTMultipart(url : String, parameters : JSONDictionary,header: [String:String],
        images : UIImage?, compression : CGFloat = 1, success : SuccessResponse, failure : FailureResponse) {
        
        Alamofire.upload(.POST, url, headers: header, multipartFormData: { (data : MultipartFormData) -> Void in
            
            for (key, value) in parameters {
                
                print_debug(key)
                print_debug(value)
                
                
                data.appendBodyPart(data: "\(value)".dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            
            
            
            if images != nil{
                guard let imageData = UIImageJPEGRepresentation(images!, compression) else { return }
                data.appendBodyPart(data: imageData, name: "user_image", fileName: "image", mimeType: "image/png")
            }
            
        }) { (result : Manager.MultipartFormDataEncodingResult) -> Void in
            
            switch result {
                
            case .Success(let req, _, _):
                
                if isLoggingEnabled {
                    req.logRequest()
                }
                
                req.handleResponse(success: success, failure: failure)
                
            case .Failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    // Logs
    private static var isLoggingEnabled = true
    
    static func enableLogs() {
        isLoggingEnabled = true
    }
    
    static func disableLogs() {
        isLoggingEnabled = false
    }
    
}

private extension Alamofire.Request {
    
    func logAndHandleRequest(success success : SuccessResponse, failure : FailureResponse) -> Self {
        return self.logRequest().handleResponse(success: success, failure: failure)
    }
    
    func logRequest() -> Self {
        
        return self.responseJSON { response in
            
            logNetwork("** Request Latency ** \n\n \(response.timeline.latency) \n")
            
            logNetwork("** Request ** \n\n \(response.request) \n")  // original URL request
            logNetwork("** Response ** \n\n \(response.response) \n") // URL response
            
            if let val = response.result.value {
                
                logNetwork("** Result ** \n\n \(val) \n")
                
            } else if let err = response.result.error {
                
                logNetwork("** Error ** \n\n \(err) \n")
            }
        }
    }
    
    func handleResponse(success success : SuccessResponse, failure : FailureResponse) -> Self {
        
        return self.responseJSON { response in
            
            if let value = response.result.value {
                
                success(json: JSON(value))
                
            } else if let error = response.result.error {
                
                failure(error: error)
            }
        }
    }
}

private func logNetwork<T>(obj : T) {
    print_debug(obj)
}
