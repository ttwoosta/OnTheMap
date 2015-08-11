//
//  UDLocation+Convience.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/10/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import CoreData

extension UDLocation {
    
    //////////////////////////////////
    // MARK: Conveniece
    /////////////////////////////////
    
    public class func locationsFromResults(results: [[String: AnyObject]], moc: NSManagedObjectContext) -> [UDLocation] {
        
        // Location object entity
        let entity = NSEntityDescription.entityForName(kUDLocation, inManagedObjectContext: moc)!
        
        // returned locations array
        var locations = [UDLocation]()
        
        for d in results {
            var loc = UDLocation(entity: entity, insertIntoManagedObjectContext: moc)
            loc.decodeWith(d)
            locations.append(loc)
        }
        
        return locations
    }
    
    public class func createOrUpdateStudentLocation(uniqueKey: String, decodeDict: [String: AnyObject], inManagedObjectContext context: NSManagedObjectContext) -> UDLocation {
        
        // get location for uniqueKey
        let loc = studentLocationForUniqueKey(uniqueKey, inManagedObjectContext: context)
        
        // found location
        if loc != nil {
            loc.decodeWith(decodeDict)
            return loc
        }
        else { // location doesn't exist, create one
            let entity = NSEntityDescription.entityForName(kUDLocation, inManagedObjectContext: context)
            var obj = UDLocation(entity: entity!, insertIntoManagedObjectContext: context)
            obj.decodeWith(decodeDict)
            return obj
        }
    }
    
    public class func studentLocationForUniqueKey(uniqueKey: String, inManagedObjectContext context: NSManagedObjectContext) -> UDLocation! {
        // initialize fetch request
        var fetchRequest = NSFetchRequest(entityName: kUDLocation)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", JSONKeys.uniqueKey, uniqueKey)
        fetchRequest.fetchLimit = 1
        
        var error: NSError? = nil
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if let obj = result?.last as? UDLocation {
            return obj
        }
        return nil
    }
}