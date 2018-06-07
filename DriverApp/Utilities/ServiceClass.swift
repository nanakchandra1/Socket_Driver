//
//  ServiceClass.swift
//  DriverApp
//
//  Created by saurabh on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON


let loginData: Data = "admin@wav.com:Pass@word1".data(using: String.Encoding.utf8)!
let base64LoginString = loginData.base64EncodedString(options: [])


var headers:[String:String]{
    
    
    if let token = CurrentUser.token{
        
        return ["Authorization": ("Basic "+base64LoginString),"Auth-Token":token]
        
    }
    
    printlnDebug("Basic "+base64LoginString)
    
    return ["Authorization": ("Basic "+base64LoginString)]
    
}





func updateLocationAPI(_ params:[String:AnyObject]) {
    
    request(URLName.UpdateLocationUrl, method:.post , parameters: params, headers: headers).responseJSON { (response) in
        
        printlnDebug(response)
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            
            switch response.result {
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
//                if let message = responseJSON["message"] as? String{
//                    //showToastWithMessage(message)
//                }
                break
                
            case .failure(let error):
                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                hideLoader()
                return
            }
        }
    }
}


func rideActionApi(_ params:[String:AnyObject],completionHandler:@escaping ((_ success:[String: AnyObject])->())) {
    
    request(URLName.rideActionUrl, method: .post , parameters: params, headers: headers).responseJSON { (response) in
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            hideLoader()

            switch response.result {

            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
                if let code = responseJSON["code"] as? Int {
                    if code == 200{
                    completionHandler(responseJSON)
                    }else if "\(code)" == "220"{
                        goToLogin()
                    }else if "\(code)" == "237"{
                        gotoHomeVC()
                        if let message = responseJSON["message"] as? String{
                            showToastWithMessage(message)
                        }
                    }
                }
                
//                if let message = responseJSON["message"] as? String{
//                    //showToastWithMessage(message)
//                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                hideLoader()

                return
            }
        }
    }
}


func getLatLong(_ params:[String:AnyObject], successBlock: @escaping (JSONDictionary, String) -> Void){

    
    request(URLName.placeDetailUrl, method: .get , parameters: params, headers: nil).responseJSON { (response) in
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
                if let status = responseJSON["status"] as? String{
                    if status == "OK"{
                        
                        if let result = responseJSON["result"] as? JSONDictionary,let status = responseJSON["status"] as? String{
                            successBlock(result,status)
                        }
                    }
                    else{
                       // showToastWithMessage("Cannot determine your current location")
                    }
                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                hideLoader()

                return
            }
        }
    }
}


func googleGeocodeApi(_ params:[String:AnyObject], completionHandler:@escaping (([String: AnyObject]) -> Void)){
    
    request(URLName.googleGeocodeUrl, method: .get , parameters: params, headers: nil).responseJSON { (response) in
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
                if let status = responseJSON["status"] as? String{
                    if status == "OK"{
                        
                        if let result = responseJSON["results"] as? [[String: AnyObject]]{
                            completionHandler(result[0])
                        }
                    }
                    else{
                       // showToastWithMessage("Cannot determine your current location")
                    }
                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                hideLoader()

                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                return
            }
        }
    }
}
 
 

func startTripApi(_ params:[String:AnyObject], completionHandler:@escaping (([String: AnyObject]) -> Void)){
    
    request(URLName.startRideUrl, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            completionHandler(responseJSON)
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                            
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}



func startPickTripApi(_ params:[String:AnyObject], completionHandler:@escaping (([String: AnyObject]) -> Void)){
    
    request(URLName.startpickRideUrl, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            completionHandler(responseJSON)
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                            
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}



func completeTripApi(_ params:[String:AnyObject], completionHandler:@escaping (([String: AnyObject]) -> Void)){
    
    request(URLName.endRideUrl, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            completionHandler(responseJSON)
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }else if "\(code)" == "237"{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                            leavePickup()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
}


func completePickUpTripApi(_ params:[String:AnyObject], completionHandler:@escaping (([String: AnyObject]) -> Void)){
    
    request(URLName.endPickUpRideUrl, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            completionHandler(responseJSON)
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}
 
 
 
func checkStatusApi(_ params:JSONDictionary ,completionHandler: @escaping ((JSONDictionary) -> Void)){
    
    request(URLName.driverStatusUrl, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            //hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                completionHandler(result)
                            }
                        }else if "\(code)" == "220"{
                            sharedAppdelegate.stausTimer.invalidate()
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}


 func rideNowApi(_ params:JSONDictionary ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    request(URLName.pickuprequestURL, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            hideLoader()
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}


 func getvehicleApi(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionaryArray) -> Void)){
    
    
    
    request(URLName.endRideUrl, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionaryArray{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            goToLogin()
                            hideLoader()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}


 
 func googlePlacesAPI(_ params:String, completionHandler:@escaping ((JSONDictionaryArray, String) -> Void)){
    
    
    request(params, method: .get , parameters: ["":"" as AnyObject], headers: nil).responseJSON { (response) in
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
                if let status = responseJSON["status"] as? String{
                    if status == "OK"{
                        
                        if let result = responseJSON["predictions"] as? JSONDictionaryArray{
                            completionHandler(result,status)
                        }
                    }
                    else{
                        //showToastWithMessage("Cannot determine your current location")
                    }
                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                hideLoader()

                return
            }
        }
    }
    
}


func getEarningApi(_ params: JSONDictionary,completionHandler:@escaping ((_ success:[String: AnyObject])->())) {
    
    
    request(URLName.earningsUrl, method: .post, parameters: params, headers: headers).responseJSON { (response) in
        hideLoader()

        if response.result.isSuccess{
            
            printlnDebug(response.result.value as? [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    printlnDebug("Result value in response is nil")
                    return
                }
                
                if let code = responseJSON["code"]{
                    if "\(code)" == "200"{
                        completionHandler(responseJSON)
                    }else if "\(code)" == "220"{
                        goToLogin()
                    }
                }
                
//                if let message = responseJSON["message"] as? String{
//                    //showToastWithMessage(message)
//                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                printlnDebug("Error result: \(error)")
                hideLoader()
                return
            }
        }
    }
}


func getEarningDetailApi(_ params: JSONDictionary,completionHandler:@escaping ((_ success:[String: AnyObject])->())) {
    
    
    request(URLName.dateearningUrl, method: .post , parameters: params, headers: headers).responseJSON { (response) in
        hideLoader()
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as? [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    printlnDebug("Result value in response is nil")
                    return
                }
                
                if let code = responseJSON["code"]{
                    if "\(code)" == "200"{
                        completionHandler(responseJSON)
                    }else if "\(code)" == "220"{
                        goToLogin()
                    }
                }
                
                //                if let message = responseJSON["message"] as? String{
                //                    //showToastWithMessage(message)
                //                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                printlnDebug("Error result: \(error)")
                hideLoader()
                return
            }
        }
    }
}


func myJobsApi(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    
    
    request(URLName.rideHistoryURL, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! JSONDictionary)   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
//                            if let message = responseJSON["message"] as? String{
//                                showToastWithMessage(message)
//                            }
                            hideLoader()
                        }
                    }
                    hideLoader()

                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}





func addMoneyApi(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    
    
    request(URLName.paymentURL, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! JSONDictionary)   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                            hideLoader()
                        }
                    }
                    hideLoader()
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}


func regainRideStateAPI(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    
    
    request(URLName.regainstateURL, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! JSONDictionary)   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                                SuccessBlock(responseJSON)
                        }
                        else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                            hideLoader()
                        }
                    }
                    hideLoader()
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()

                    return
                }
            }
    }
}




func getHistoryApi(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    
    
    request(URLName.rideHistoryURL, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
}


func getEatApi(_ params:[String:AnyObject],source:String,destination:String, completionHandler:@escaping ((JSONDictionaryArray, String) -> Void)){

    let url = "https://maps.googleapis.com/maps/api/distancematrix/json?&origins=\(source)&destinations=\(destination)"
    
    let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

    
    request(encodedUrl!, method: .get, parameters: params, headers: nil).responseJSON { (response) in
        
        printlnDebug(response)
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
                if let status = responseJSON["status"] as? String{
                    if status == "OK"{
                        
                        if let result = responseJSON["rows"] as? JSONDictionaryArray{
                            completionHandler(result,status)
                        }
                    }
                    else{
                        //showToastWithMessage("No results found")
                    }
                }
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                hideLoader()
                
                return
            }
        }
    }
    
}


func calculateTotalFareAPI(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    
    
    request(URLName.getFareUrl, method: .post , parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            goToLogin()
                            hideLoader()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
}



func stopAcceptingAPI(_ params:JSONDictionary? ,SuccessBlock: @escaping ((Bool) -> Void), failureBlock: ((NSError) -> Void)){
    
    
    
    request(URLName.stopAcceptingReqstUrl, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            
                                SuccessBlock(true)
                            
                        }else if "\(code)" == "220"{
                            goToLogin()
                            hideLoader()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
}


func acceptChangeDestinationAPI(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionary) -> Void), failureBlock: ((NSError) -> Void)){
    
    
    
    request(URLName.changeLocgReqstUrl, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let _ = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(responseJSON)
                            }
                        }else if "\(code)" == "220"{
                            goToLogin()
                            hideLoader()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
}






func pickupActionApi(_ params:[String:AnyObject],completionHandler:@escaping ((_ success:JSONDictionary)->())) {
    
    request(URLName.pickupActionUrl, method: .post, parameters: params, headers: headers).responseJSON { (response) in
        
        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            hideLoader()
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    return
                }
                
                if let code = responseJSON["code"] as? Int {
                    if code == 200{
                        completionHandler(responseJSON)
                    }else if "\(code)" == "220"{
                        goToLogin()
                    }else if "\(code)" == "237"{
                        if let message = responseJSON["message"] as? String{
                            showToastWithMessage(message)
                        }
                    }
                }
                
                break
                
            case .failure(let error):
                printlnDebug(error)
                showToastWithMessage(ServiceStrings.failure)
                NSLog("Error result: \(error)")
                hideLoader()
                
                return
            }
        }
    }
}



//func notificationApi(params:JSONDictionary? ,SuccessBlock: ((JSONDictionaryArray) -> Void)){
//    
//    request(.GET, URLName.notificationsURL, parameters:params, headers: headers)
//        .responseJSON { response in
//            printlnDebug(response)
//            hideLoader()
//            if response.result.isSuccess{
//                
//                printlnDebug(response.result.value as! [String: AnyObject])   // json value
//                
//                
//                switch response.result {
//                case .Success:
//                    guard let responseJSON = response.result.value as? [String:AnyObject] where !responseJSON.isEmpty else {
//                        NSLog("Result value in response is nil")
//                        return
//                    }
//                    if let code = responseJSON["code"]{
//                        
//                        if "\(code)" == "200" {
//                            if let result = responseJSON["result"] as? JSONDictionaryArray{
//                                SuccessBlock(result)
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
//                case .Failure(let error):
//                    NSLog("Error result: \(error)")
//                    printlnDebug(error)
//                    hideLoader()
//                    
//                    return
//                }
//            }
//    }
//}



func notificationApi(_ params:JSONDictionary? ,SuccessBlock: @escaping ((JSONDictionaryArray) -> Void)){
    
    
    request(URLName.notificationsURL, method: .get, parameters: ["":"" as AnyObject], headers: headers).responseJSON { (response) in
        hideLoader()
        printlnDebug(response)   // json value

        if response.result.isSuccess{
            
            printlnDebug(response.result.value as! [String: AnyObject])   // json value
            
            switch response.result {
                
            case .success:
                guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                    NSLog("Result value in response is nil")
                    //completionHandler()
                    return
                }
                
                if let code = responseJSON["code"]{
                    
                    if "\(code)" == "200" {
                        if let result = responseJSON["result"] as? JSONDictionaryArray{
                            SuccessBlock(result)
                        }
                    }else if "\(code)" == "220"{
                        goToLogin()
                        hideLoader()
                    }
                    else{
                        if let message = responseJSON["message"] as? String{
                            showToastWithMessage(message)
                        }
                    }
                }
                
                break
                
            case .failure(let error):
                NSLog("Error result: \(error)")
                printlnDebug(error)
                hideLoader()
                
                return
            }
        }
    }
    
}


func watingChargeApi(_ params:JSONDictionary ,SuccessBlock: @escaping ((JSONDictionary) -> Void)){
    
    request(URLName.arrivedURL, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "200" {
                            if let result = responseJSON["result"] as? JSONDictionary{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            hideLoader()
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
}



 func saveCardDetailAPI(_ params:JSONDictionary ,SuccessBlock: @escaping ((JSONDictionaryArray) -> Void), failureBlock: ((NSError) -> Void)){
    
    printlnDebug(params)
    printlnDebug(headers)
    
    
    request(URLName.saveCardDetailURL, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "146" {
                            if let result = responseJSON["result"] as? JSONDictionaryArray{
                                SuccessBlock(result)
                            }
                        }else if "\(code)" == "220"{
                            hideLoader()
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }
    

}


 func removeSaveCardApi(_ params:JSONDictionary ,SuccessBlock: @escaping ((Bool) -> Void), failureBlock: ((NSError) -> Void)){
    
    request(URLName.removeSaveCardDetailURL, method: .post, parameters:params, headers: headers)
        .responseJSON { response in
            printlnDebug(response)
            hideLoader()
            if response.result.isSuccess{
                
                printlnDebug(response.result.value as! [String: AnyObject])   // json value
                
                switch response.result {
                case .success:
                    guard let responseJSON = response.result.value as? [String:AnyObject], !responseJSON.isEmpty else {
                        NSLog("Result value in response is nil")
                        //completionHandler()
                        return
                    }
                    if let code = responseJSON["code"]{
                        
                        if "\(code)" == "146" {
                            
                                SuccessBlock(true)
                            
                        }else if "\(code)" == "220"{
                            hideLoader()
                            goToLogin()
                        }
                        else{
                            if let message = responseJSON["message"] as? String{
                                showToastWithMessage(message)
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    NSLog("Error result: \(error)")
                    printlnDebug(error)
                    hideLoader()
                    
                    return
                }
            }
    }

}



