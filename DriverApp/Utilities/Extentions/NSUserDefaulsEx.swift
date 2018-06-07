//
//  NSUserDefaulsEx.swift
//  DriverApp
//
//  Created by Appinventiv on 11/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation


extension UserDefaults {
    //MARK: UserDefault
    
    class func save(_ value:AnyObject,forKey key:String)     {
        
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    class func userDefaultForKey(_ key:String) -> AnyObject? {
        
        if let value: AnyObject =  UserDefaults.standard.object(forKey: key) as AnyObject {
            
            return value
            
        } else {
            
            return nil
            
        }
    }
    
    class func userdefaultStringForKey(_ key:String) -> String? {
        
        if let value =  UserDefaults.standard.object(forKey: key) as? String {
            
            return value
            
        } else {
            
            return nil
            
        }
    }
    
    
    class func userdefaultIntForKey(_ key:String) -> Int? {
        
        if let value =  UserDefaults.standard.object(forKey: key) as? Int {
            
            return value
            
        } else {
            
            return nil
            
        }
    }
    
    class func userdefaultStringArrayForKey(_ key:String) -> [String]? {
        
        if let value =  UserDefaults.standard.object(forKey: key) as? [String] {
            
            return value
            
        } else {
            return nil
        }
    }

    
    class func removeFromUserDefaultForKey(_ key:String) {
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    class func clearUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
        
    }
}
