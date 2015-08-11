//
//  UDLocation.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/5/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import CoreData

public class UDLocation: NSManagedObject {
    
    static let kUDLocation = "UDLocation"
    
    //////////////////////////////////
    // MARK: Properties
    /////////////////////////////////
    
    @NSManaged public var objectId: String
    @NSManaged public var uniqueKey: String
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var mapString: String
    @NSManaged public var mediaURLString: String
    @NSManaged public var latitude: NSNumber
    @NSManaged public var longitude: NSNumber
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var acl: String
    
    public var mediaURL: NSURL {
        get {
            return NSURL(string: mediaURLString)!
        }
    }
    
    //////////////////////////////////
    // MARK: Date formmater
    /////////////////////////////////
        
    static let dateFormat = NSDateFormatter()
    public override class func initialize() {
        //dateFormat.AMSymbol = "AM"
        //dateFormat.PMSymbol = "PM"
        dateFormat.dateFormat = "MM/dd/yyyy hh:mm a"
        
        super.initialize()
    }
    
    class func dateFormmater() -> NSDateFormatter {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: NSDateFormatter? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NSDateFormatter()
            Static.instance?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
        return Static.instance!
    }
    
    //////////////////////////////////
    // MARK: Decode method
    /////////////////////////////////
    
    public func decodeWith(dictionary: [String: AnyObject]) {
        firstName = dictionary[JSONKeys.firstName] as! String
        lastName = dictionary[JSONKeys.lastName] as! String
        
        if let lat = dictionary[JSONKeys.latitude] as? Double {
            latitude = NSNumber(double: lat)
        }
        if let long = dictionary[JSONKeys.longitude] as? Double {
            longitude = NSNumber(double: long)
        }
        
        mapString = dictionary[JSONKeys.mapString] as! String
        mediaURLString = dictionary[JSONKeys.mediaURL] as! String
        
        if let objId = dictionary[JSONKeys.objectId] as? String {
            objectId = objId
        }
        if let uniKey = dictionary[JSONKeys.uniqueKey] as? NSNumber {
            uniqueKey = "\(uniKey)"
        }
        // most of student's id are Number
        // mine starting with "u######"
        if let uniKey = dictionary[JSONKeys.uniqueKey] as? String {
            uniqueKey = uniKey
        }
        
        let dateFormmater = UDLocation.dateFormmater()
        if let created = dictionary[JSONKeys.createdAt] as? String {
            createdAt = dateFormmater.dateFromString(created)!
        }
        if let updated = dictionary[JSONKeys.updatedAt] as? String {
            updatedAt = dateFormmater.dateFromString(updated)!
        }
    }
    
    
    
    

    
    
    
    
    

}
