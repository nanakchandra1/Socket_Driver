//
//  ServiceClass.swift
//  DriverApp
//
//  Created by Abhishek on 07/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class ServiceClass{
 
    //MARK: login Api
    class func loginApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
    
        AppNetworking.POST(endPoint: URLName.LoginApiUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in

            completionHandler(data)

        }) { (error) in
            
            printlnDebug(error.localizedDescription)

        }
    }
    
    
    //MARK: rate Api
    class func rateApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.driverRateUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            completionHandler(data)
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    
    //MARK: logout Api
    class func logoutApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        
        AppNetworking.POST(endPoint: URLName.LogoutUrl, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" || "\(code)" == "220" {
                    
                    
                    normal_Timer.invalidate()
                    timerState = true
                    UserDefaults.clearUserDefaults()
                    SocketManegerInstance.closeConnection()
                    sharedAppdelegate.stausTimer.invalidate()
                    let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    let navController = UINavigationController(rootViewController: vc)
                    navController.isNavigationBarHidden = true
                    navController.automaticallyAdjustsScrollViewInsets=false
                    sharedAppdelegate.window?.rootViewController = navController
                    completionHandler(data)
                    return
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
        }
        
    }
    
    //MARK: update Password Api
    class func updatePasswordApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.ChangePasswordUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    completionHandler(data)

                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }

        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    
    //MARK: send OTP Api
    class func sendOTPApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.SendOTPUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    completionHandler(data)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    //MARK: verify OTP Api
    class func verifyOTPApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.VerifyOtpApiUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    completionHandler(data)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    
    //MARK: forgot Passowrd Api
    class func forgotPassowrdApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.ForgotPasswordApiUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    completionHandler(data)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    
    //MARK: set Status Api
    class func setStatusApi(_ params:[String:Any], completionHandler:@escaping ((_ success:Bool)->())){
        
        AppNetworking.POST(endPoint: URLName.SetStatusUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    if let online_for = data["result"]["online_for"].string{
                        UserDefaults.save(online_for as AnyObject, forKey: NSUserDefaultKey.ONLINE_FOR)
                     
                        completionHandler(true)
                    }
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    
    //MARK: static Pages Api
    class func staticPagesApi(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.staticPagesUrl, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    let result = data["result"]
                    
                    completionHandler(result)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    
    //MARK: my Transaction API
    class func myTransactionAPI(_ params:[String:Any], completionHandler:@escaping ((_ success : JSON , _ amount : String)->())){
        
        AppNetworking.POST(endPoint: URLName.myTransURL, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    let result = data["result"]
                    
                    if let amnt = data["amnt"].string{
                        
                        UserDefaults.save(amnt as AnyObject, forKey: NSUserDefaultKey.AMOUNT)
                        
                        completionHandler(result,amnt)
                    }
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    //MARK: notification Status API
    class func notificationStatusAPI(_ params:[String:Any], completionHandler:@escaping ((_ success:Bool)->())){
        
        AppNetworking.POST(endPoint: URLName.notificationstatusURL, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    completionHandler(true)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    //MARK: add Driver Card API
    class func addDriverCardAPI(_ params:[String:Any], completionHandler:@escaping ((_ success:JSON)->())){
        
        AppNetworking.POST(endPoint: URLName.addDriverCardURL, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "145" {
                    
                    let result = data["result"]
                    
                    completionHandler(result)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
    
    //MARK: set Default PayMethod API
    class func setDefaultPayMethodAPI(_ params:[String:Any], completionHandler:@escaping ((_ success:Bool)->())){
        
        AppNetworking.POST(endPoint: URLName.setDefaultPaymentMethodURL, parameters: params as JSONDictionary, loader: true, success: { (data) in
            
            if let message = data["message"].string{
                
                showToastWithMessage(message)
            }
            
            if let code = data["statusCode"].int{
                
                if "\(code)" == "200" {
                    
                    completionHandler(true)
                    
                }else if "\(code)" == "220"{
                    
                    goToLogin()
                }
            }
            
        }) { (error) in
            
            printlnDebug(error.localizedDescription)
            
        }
    }
}



//func forgotPassowrdApi(_ params:[String:AnyObject], completionHandler: @escaping (([String:AnyObject]) -> Void)){
//    
//    request(URLName.ForgotPasswordApiUrl, method: .post , parameters:params, headers: headers)
//        .responseJSON { response in
//            printlnDebug(response)
//            hideLoader()
//            if response.result.isSuccess{
//                
//                printlnDebug(response.result.value as! [String: AnyObject])   // json value
//                
//                
//                switch response.result {
//                case .success:
//                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
//                        NSLog("Result value in response is nil")
//                        //completionHandler()
//                        return
//                    }
//                    if let code = responseJSON["code"]{
//                        
//                        if "\(code)" == "200" {
//                            completionHandler(responseJSON)
//                        }else if "\(code)" == "220"{
//                            goToLogin()
//                        }
//                        else{
//                            if let message = responseJSON["message"] as? String{
//                                showToastWithMessage(message)
//                            }
//                            
//                        }
//                    }
//                    
//                    break
//                    
//                case .failure(let error):
//                    NSLog("Error result: \(error)")
//                    hideLoader()
//                    
//                    return
//                }
//            }
//    }
//}


//func myTransactionAPI(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionaryArray,String) -> Void)){
//    
//    
//    
//    request(URLName.myTransURL, method: .post, parameters:params, headers: headers)
//        .responseJSON { response in
//            printlnDebug(response)
//            hideLoader()
//            if response.result.isSuccess{
//                
//                printlnDebug(response.result.value as! [String: AnyObject])   // json value
//                
//                
//                switch response.result {
//                case .success:
//                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
//                        NSLog("Result value in response is nil")
//                        return
//                    }
//                    if let code = responseJSON["code"]{
//                        
//                        if "\(code)" == "200" {
//                            if let result = responseJSON["result"] as? JSONDictionaryArray{
//                                if let amnt = responseJSON["amnt"]{
//                                    UserDefaults.save("\(amnt)" as AnyObject, forKey: NSUserDefaultKey.AMOUNT)
//                                    SuccessBlock(result,"\(amnt)")
//                                }
//                            }
//                        }else if "\(code)" == "220"{
//                            goToLogin()
//                            hideLoader()
//                        }
//                        else{
//                            if let message = responseJSON["message"] as? String{
//                                showToastWithMessage(message)
//                            }
//                        }
//                    }
//                    
//                    break
//                    
//                case .failure(let error):
//                    NSLog("Error result: \(error)")
//                    printlnDebug(error)
//                    hideLoader()
//                    
//                    return
//                }
//            }
//    }
//}


//func notificationStatusAPI(_ params:JSONDictionary? ,SuccessBlock: @escaping ((Bool) -> Void), failureBlock: ((NSError) -> Void)){
//    
//    
//    
//    request(URLName.notificationstatusURL, method: .post, parameters:params, headers: headers)
//        .responseJSON { response in
//            printlnDebug(response)
//            hideLoader()
//            if response.result.isSuccess{
//                
//                printlnDebug(response.result.value as! [String: AnyObject])   // json value
//                
//                switch response.result {
//                case .success:
//                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
//                        NSLog("Result value in response is nil")
//                        return
//                    }
//                    if let code = responseJSON["code"]{
//                        
//                        if "\(code)" == "200" {
//                            SuccessBlock(true)
//                        }else if "\(code)" == "220"{
//                            goToLogin()
//                            hideLoader()
//                        }
//                        else{
//                            if let message = responseJSON["message"] as? String{
//                                showToastWithMessage(message)
//                            }
//                        }
//                    }
//                    
//                    break
//                    
//                case .failure(let error):
//                    NSLog("Error result: \(error)")
//                    printlnDebug(error)
//                    hideLoader()
//                    
//                    return
//                }
//            }
//    }
//}

//func addDriverCardAPI(_ params:JSONDictionary ,SuccessBlock: @escaping ((JSONDictionary) -> Void), failureBlock: ((NSError) -> Void)){
//    
//    printlnDebug(params)
//    printlnDebug(headers)
//    
//    request(URLName.addDriverCardURL, method: .post, parameters:params, headers: headers)
//        .responseJSON { response in
//            printlnDebug(response)
//            hideLoader()
//            if response.result.isSuccess{
//                
//                printlnDebug(response.result.value as! [String: AnyObject])   // json value
//                
//                switch response.result {
//                case .success:
//                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
//                        NSLog("Result value in response is nil")
//                        //completionHandler()
//                        return
//                    }
//                    if let code = responseJSON["code"]{
//                        
//                        if "\(code)" == "145" {
//                            if let result = responseJSON["result"] as? JSONDictionary{
//                                SuccessBlock(result)
//                            }
//                        }else if "\(code)" == "220"{
//                            hideLoader()
//                            goToLogin()
//                        }
//                        else{
//                            if let message = responseJSON["message"] as? String{
//                                showToastWithMessage(message)
//                            }
//                        }
//                    }
//                    
//                    break
//                    
//                case .failure(let error):
//                    NSLog("Error result: \(error)")
//                    printlnDebug(error)
//                    hideLoader()
//                    
//                    return
//                }
//            }
//    }
//    
//}

//func setDefaultPayMethodAPI(_ params:JSONDictionary ,SuccessBlock: @escaping ((Bool) -> Void), failureBlock: ((NSError) -> Void)){
//    
//    printlnDebug(params)
//    printlnDebug(headers)
//    
//    
//    
//    request(URLName.setDefaultPaymentMethodURL, method: .post, parameters:params, headers: headers)
//        .responseJSON { response in
//            printlnDebug(response)
//            hideLoader()
//            if response.result.isSuccess{
//                
//                printlnDebug(response.result.value as! [String: AnyObject])   // json value
//                
//                switch response.result {
//                case .success:
//                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
//                        NSLog("Result value in response is nil")
//                        //completionHandler()
//                        return
//                    }
//                    if let code = responseJSON["code"]{
//                        
//                        if "\(code)" == "200" {
//                            SuccessBlock(true)
//                        }else if "\(code)" == "220"{
//                            hideLoader()
//                            goToLogin()
//                        }
//                        else{
//                            if let message = responseJSON["message"] as? String{
//                                showToastWithMessage(message)
//                            }
//                        }
//                    }
//                    
//                    break
//                    
//                case .failure(let error):
//                    NSLog("Error result: \(error)")
//                    printlnDebug(error)
//                    hideLoader()
//                    
//                    return
//                }
//            }
//    }
//    
//}
