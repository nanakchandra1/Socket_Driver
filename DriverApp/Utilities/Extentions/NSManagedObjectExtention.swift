

//
//  StringExtention.swift
//  NexGTv
//
//  Created by Saurabh Shukla on 08/02/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject
{
    func getDictionary()->[String:AnyObject]
    {
        let keys = Array(self.entity.attributesByName.keys)
        let dict = self.dictionaryWithValues(forKeys: keys)
        return dict as [String : AnyObject]
    }
    func deleted()->Bool{
        if (self.managedObjectContext == nil) {
            return true
        }
        return false
    }
}
