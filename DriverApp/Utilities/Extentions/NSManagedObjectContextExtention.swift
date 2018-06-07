//
//  StringExtention.swift
//  NexGTv
//
//  Created by Saurabh Shukla on 08/02/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext
{
    func deleteAllData()
    {
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }
        
        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }
        
        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch { /*dealing with errors up to the usage*/ }
        }
    }
}
