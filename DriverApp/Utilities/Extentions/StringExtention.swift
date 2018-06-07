//
//  StringExtention.swift
//  DriverApp
//
//  Created by saurabh on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation


extension String{
    
    var localized : String {
        
            return  localizedString(lang: "en")
    }
    
    
    func localizedString(lang:String) ->String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        //printlnDebug(path)
        let bundle = Bundle(path: path!)
        //printlnDebug(bundle)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    
    
}
