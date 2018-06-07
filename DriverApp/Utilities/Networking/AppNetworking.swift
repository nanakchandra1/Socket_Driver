
import Foundation
import SwiftyJSON
import Alamofire

typealias JSONDictionary = [String : AnyObject]
typealias JSONDictionaryArray = [JSONDictionary]
typealias JSONArray = [JSON]



extension Notification.Name {
    
    static let NotConnectedToInternet = Notification.Name("NotConnectedToInternet")
}

enum AppNetworking {
    
    
    static func POST(endPoint : String,
                     parameters : JSONDictionary = [:],
                     loader : Bool = true,
                     success : @escaping (JSON) -> Void,
                     failure : @escaping (Error) -> Void) {
        
        
        request(URLString: endPoint, httpMethod: .post, parameters: parameters, loader: loader, success: success, failure: failure)
    }
    
    
    static func POSTWithImage(endPoint : String,
                              parameters : [String : Any] = [:],
                              image : [String:UIImage]? = [:],
                              loader : Bool = true,
                              success : @escaping (JSON) -> Void,
                              failure : @escaping (Error) -> Void) {
        
        upload(URLString: endPoint, httpMethod: .post, parameters: parameters as JSONDictionary,image: image , loader: loader, success: success, failure: failure )
    }
    
    
    static func GET(endPoint : String,
                    parameters : JSONDictionary = [:],
                    headers : HTTPHeaders = [:],
                    loader : Bool = true,
                    success : @escaping (JSON) -> Void,
                    failure : @escaping (Error) -> Void) {
        
        request(URLString: endPoint, httpMethod: .get, parameters: parameters, encoding: URLEncoding.queryString, loader: loader, success: success, failure: failure)
    }
    
    
    static func PUT(endPoint : String,
                    parameters : JSONDictionary = [:],
                    headers : HTTPHeaders = [:],
                    loader : Bool = true,
                    success : @escaping (JSON) -> Void,
                    failure : @escaping (Error) -> Void) {
        
        request(URLString: endPoint, httpMethod: .put, parameters: parameters, loader: loader, success: success, failure: failure)
    }
    
    static func DELETE(endPoint : String,
                       parameters : JSONDictionary = [:],
                       headers : HTTPHeaders = [:],
                       loader : Bool = true,
                       success : @escaping (JSON) -> Void,
                       failure : @escaping (Error) -> Void) {
        
        request(URLString: endPoint, httpMethod: .delete, parameters: parameters, loader: loader, success: success, failure: failure)
    }
    
    private static func request(URLString : String,
                                httpMethod : HTTPMethod,
                                parameters : JSONDictionary = [:],
                                encoding: URLEncoding = .httpBody,
                                loader : Bool = true,
                                success : @escaping (JSON) -> Void,
                                failure : @escaping (Error) -> Void) {
        
        if loader { () }
        
        let URLStr = URLString
        
        //let basicAuth = headers
        
        printlnDebug("******************************************************** Request URL *****************************************************\n \(URLStr)")
        printlnDebug("******************************************************** Request parameter *****************************************************\n \(parameters)")
        
        
        let digestHeader = DigestAuth.getDigestHeader(method: httpMethod.rawValue, uri: URLString)
        var accessToken = ""
        let accessTk =  CurrentUser.token
        if accessTk != nil{
            accessToken = accessTk!
        }
        
        let header = ["Content-Type":"application/x-www-form-urlencoded",
                      "Authorization" : digestHeader,
                      "Auth-Token" : accessToken]
        
        
        Alamofire.request(URLStr,
                          method: httpMethod,
                          parameters: parameters,
                          encoding: encoding,
                          headers: header).responseJSON { (response:DataResponse<Any>) in
                            

                            if loader { hideLoader() }
                            
                            switch(response.result) {
                                
                            case .success(let value):
                                printlnDebug(JSON(value))
                                let json = JSON(value)
                                
                                if json["statusCode"].intValue == 227{
                                    UserDefaults.clearUserDefaults()
                                    goToLogin()
                                    
                                }else{
                                    
                                    success(json)

                                }


                            case .failure(let e):
                                
                                if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                    // Handle Internet Not available UI
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                   // showToastWithMessage(msg: "No Internet Connection")
                                    
                                }
                                
                                if (e as NSError).code == NSURLErrorNetworkConnectionLost {
                                    // Handle Internet Not available UI
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                    //showToastWithMessage(msg: "No Internet Connection")

                                }
                                
                                if (e as NSError).code == NSURLErrorTimedOut {
                                    // Handle Internet Not available UI
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                   // showToastWithMessage(msg: "No Internet Connection")

                                }

                                failure(e)
                            }
        }
    }
    
    private static func upload(URLString : String,
                               httpMethod : HTTPMethod,
                               parameters : JSONDictionary = [:],
                               image : [String:UIImage]? = [:],
                               loader : Bool = true,
                               success : @escaping (JSON) -> Void,
                               failure : @escaping (Error) -> Void) {
        
        let URLStr = URLString
//        let basicAuth = headers
        printlnDebug("******************************************************** Request URL *****************************************************\n \(URLStr)")
        printlnDebug("******************************************************** Request parameter *****************************************************\n \(parameters)")
        
        
        let digestHeader = DigestAuth.getDigestHeader(method: httpMethod.rawValue, uri: URLString)
        var accessToken = ""
        let accessTk =  CurrentUser.token
        if accessTk != nil{
            accessToken = accessTk!
        }
        
        let header = ["Content-Type":"application/x-www-form-urlencoded",
                      "Authorization" : digestHeader,
                      "Auth-Token" : accessToken]

        let url = try! URLRequest(url: URLStr, method: httpMethod, headers: header)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
        
            let uploadData = parameters
            
            if let image = image {
                
                    if let imgData = UIImageJPEGRepresentation(image["user_image"]!, 0.5) {
                        multipartFormData.append(imgData, withName: "user_image", fileName: "image", mimeType: "image/jpg")
                    }
            }
            for (key , value) in uploadData{
                
                 multipartFormData.append((value as AnyObject).data(using : String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        },
                         with: url, encodingCompletion: { encodingResult in
                            
                            switch encodingResult{
                            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                                
                                upload.responseJSON(completionHandler: { (response:DataResponse<Any>) in
                                    switch response.result{
                                    case .success(let value):
                                        if loader { hideLoader() }
                                        
                                        let json = JSON(value)

                                        if json["statusCode"].intValue == 227{
                                            UserDefaults.clearUserDefaults()
                                            goToLogin()
                                            
                                        }else {
                                        success(JSON(value))
                                        }
                                    case .failure(let e):
                                        if loader { hideLoader() }
                                        
                                        if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                            NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                        }
                                        failure(e)
                                    }
                                })
                                
                            case .failure(let e):
                                if loader { hideLoader() }
                                                                
                                if (e as NSError).code == NSURLErrorNotConnectedToInternet {
                                    NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                                }
                                
                                failure(e)
                            }
        })
        
    }
    
}




