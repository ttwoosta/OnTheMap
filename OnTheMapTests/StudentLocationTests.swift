//
//  OnTheMapTests.swift
//  OnTheMapTests
//
//  Created by Tu Tong on 8/4/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import OnTheMap

class OnTheMapTests: XCTestCase {
    
    var appDelegate: UDAppDelegate!
    var moc: NSManagedObjectContext!
    
    //////////////////////////////////
    // override methods
    /////////////////////////////////
    
    override func setUp() {
        super.setUp()
        // get app delegate from current application
        appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        XCTAssertNotNil(appDelegate, "Cannot get application delegate")
        
        // managed object context
        moc = appDelegate.managedObjectContext
        XCTAssertNotNil(moc, "Managed object context cannot be nil")
        
        // clear context for every test
        moc.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //////////////////////////////////
    // Fixture
    /////////////////////////////////
    
    func getStudentLocations() -> [String: AnyObject]! {
        // // create bundle and get fixture
        let bundle = NSBundle(forClass: self.dynamicType)
        let fixtureURL = bundle.URLForResource("get-student-locations.json", withExtension: nil)
        XCTAssertNotNil(fixtureURL)
        
        if let data = NSData(contentsOfURL: fixtureURL!) {
            var error: NSError? = nil
            if let locations = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [String: AnyObject] {
                return locations
            }
            else {
                println(error)
            }
        }
        
        return nil
    }
    
    func createStudentLocationObject() -> UDLocation {
        // entity
        let udlentity = NSEntityDescription.entityForName("UDLocation", inManagedObjectContext: moc)
        XCTAssertNotNil(udlentity)
        
        // student location object
        var sl = UDLocation(entity: udlentity!, insertIntoManagedObjectContext: moc)
        XCTAssertNotNil(sl)
        XCTAssertTrue(sl.isKindOfClass(UDLocation))
        
        return sl
    }
    
    //////////////////////////////////
    // Tests
    /////////////////////////////////
    
    func test_student_location() {
        let fixture = getStudentLocations()
        let results = fixture["results"] as! [[String: AnyObject]]
        let firstLocation = results[0]
        XCTAssertNotNil(firstLocation)
        
        var ust = createStudentLocationObject()
        ust.decodeWith(firstLocation)
        
        XCTAssertEqual(ust.firstName, "Jarrod")
        XCTAssertEqual(ust.lastName, "Parkes")
        XCTAssertEqual(ust.mapString, "Huntsville, Alabama ")
        XCTAssertEqual(ust.objectId, "JhOtcRkxsh")
        XCTAssertEqual(ust.uniqueKey, "996618664")
        
        XCTAssertEqual(ust.mediaURLString, "https://www.linkedin.com/in/jarrodparkes")
        XCTAssertEqual(ust.mediaURL.absoluteString!, "https://www.linkedin.com/in/jarrodparkes")
        
        XCTAssertEqual(ust.latitude.doubleValue, 34.7303688)
        XCTAssertEqual(ust.longitude.doubleValue, -86.5861037)
        
        // too hard to compare dates
        XCTAssertNotNil(ust.createdAt)
        XCTAssertNotNil(ust.updatedAt)
        
    }
    
    func test_student_location_3rd_object() {
        let fixture = getStudentLocations()
        let results = fixture["results"] as! [[String: AnyObject]]
        let firstLocation = results[2]
        XCTAssertNotNil(firstLocation)
        
        var ust = createStudentLocationObject()
        ust.decodeWith(firstLocation)
        
        XCTAssertEqual(ust.firstName, "Jason")
        XCTAssertEqual(ust.lastName, "Schatz")
        XCTAssertEqual(ust.mapString, "18th and Valencia, San Francisco, CA")
        XCTAssertEqual(ust.objectId, "hiz0vOTmrL")
        XCTAssertEqual(ust.uniqueKey, "2362758535")
        
        XCTAssertEqual(ust.mediaURLString, "http://en.wikipedia.org/wiki/Swift_%28programming_language%29")
        XCTAssertEqual(ust.mediaURL.absoluteString!, "http://en.wikipedia.org/wiki/Swift_%28programming_language%29")
        
        XCTAssertEqual(ust.latitude.doubleValue, 37.7617)
        XCTAssertEqual(ust.longitude.doubleValue, -122.4216)
        
        // too hard to compare dates
        XCTAssertNotNil(ust.createdAt)
        XCTAssertNotNil(ust.updatedAt)
        
    }
    
    func test_student_locations_multiple() {
        let fixture = getStudentLocations()
        let results = fixture["results"] as! [[String: AnyObject]]
        
        
        let locations = UDLocation.locationsFromResults(results, moc: moc)
        
        XCTAssertEqual(locations.count, 4)
        
        XCTAssertEqual(locations[0].uniqueKey, "996618664")
        XCTAssertEqual(locations[1].uniqueKey, "872458750")
        XCTAssertEqual(locations[2].uniqueKey, "2362758535")
        XCTAssertEqual(locations[3].uniqueKey, "2256298598")
        
        
        
    }
    
    //////////////////////////////////
    // Point Annotation
    /////////////////////////////////

    func test_student_location_point_annotation() {
        
        let fixture = getStudentLocations()
        let results = fixture["results"] as! [[String: AnyObject]]
        let firstLocation = results[0]
        XCTAssertNotNil(firstLocation)
        
        var ust = createStudentLocationObject()
        ust.decodeWith(firstLocation)
        
        let anno = ust.pointAnnotation()
        XCTAssertNotNil(anno)
        
        XCTAssertEqual(anno.coordinate.latitude, 34.7303688)
        XCTAssertEqual(anno.coordinate.longitude, -86.5861037)
        XCTAssertEqual(anno.title, "Jarrod Parkes")
        XCTAssertEqual(anno.subtitle, "https://www.linkedin.com/in/jarrodparkes")
        
    }
        
}
