//
//  NSDateExtention.swift
//  DriverApp
//
//  Created by saurabh on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

//---------------------------------------------------------------------
// MARK: CLASS EXTENSION (NSDATE)
//---------------------------------------------------------------------

extension Date {
    
    static func getCurrentDate() -> Date {
        
        return convertDate(Date(), toFormat: "YYYY-MMM-dd")
    }
    
    static func convertDate(_ date:Date , toFormat format:String) -> Date {
        
        let currentDateString = Date.stringFromDate(date, format: format)
        
        return Date.dateFromString(currentDateString, format: format)
    }
    
    static func stringFromDate(_ date: Date, format: String) -> String {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    static func stringFromTime(_ time: Date, format: String) -> String {
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = .short
        formatter.dateFormat = format
        
        return formatter.string(from: time)
    }
    
    static func dateFromString(_ date: String, format: String) -> Date {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return (formatter.date(from: date))!
    }
    
    static func timeFromString(_ date: String, format: String) -> Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return (formatter.date(from: date))!
    }
    
    static func calculateAge(_ birthDate: Date) -> Int {
        
        let calendar = Calendar.current
        let ageComponents = (calendar as NSCalendar).components(.year, from: birthDate, to: Date(), options:NSCalendar.Options.matchStrictly)
        return ageComponents.year!
        
    }
    
    func calculateDaysBetweenTwoDates(date: Date,unit: Calendar.Component) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: unit, in: .era, for: date) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: unit, in: .era, for: self) else {
            return 0
        }
        return end - start
        
    }
    
    
    static func minimumAge() -> Date {
        
        let unitFlags: NSCalendar.Unit = [ .day, .month, .year]
        let now = Date()
        let gregorian = Calendar.current
        var dateComponents = (gregorian as NSCalendar).components(unitFlags, from: now)
        dateComponents.year = dateComponents.year! - 18
        
        return gregorian.date(from: dateComponents)!
    }
    
    
    static func maxAge() -> Date {
        
        let unitFlags: NSCalendar.Unit = [ .day, .month, .year]
        let now = Date()
        let gregorian = Calendar.current
        var dateComponents = (gregorian as NSCalendar).components(unitFlags, from: now)
        dateComponents.year = dateComponents.year! - 100
        
        return gregorian.date(from: dateComponents)!
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func isLessThanTime(_ timeToCompare:Date) -> Bool {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "HH:mm"
        
        let result = self.compare(timeToCompare)
        
        if(result == ComparisonResult.orderedDescending) {
            
            return false
            
        } else {
            
            return true
        }
    }
    
    func relativeDateString () -> String {
        
        let units : NSCalendar.Unit = [.minute,.hour , .day , .weekOfYear , .month,.year]
        
        let components = (Calendar.current as NSCalendar).components(units, from: self, to: Date(), options: [])
        
        if (components.year! > 0) {
            
            return "\(components.year!) \("yers ago")"
            
        } else if (components.month! > 0) {
            
            return "\(components.month!) \("month sgo")"
            
        } else if (components.weekOfYear! > 0) {
            
            return "\(components.weekOfYear!) \("weak ago")"
            
        } else if (components.day! > 0) {
            
            
            return "\(components.day!) \("days ago")"
            
            
        } else if (components.hour! > 0){
            if (components.hour! == 1){
                return "\(components.hour!) \("he ago")"
                
            }else{
                return "\(components.hour!) \("hrs ago")"
            }
        }else if (components.minute! > 1){
            
            return "\(components.minute!) \("mina ago")"
            
        }else{
            
            return "just now"
        }
    }
}
