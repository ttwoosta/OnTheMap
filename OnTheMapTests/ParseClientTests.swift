//
//  ParseClientTests.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import OnTheMap
import MapKit

class ParseClientTests: XCTestCase {

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
    // Tests URL parameters
    /////////////////////////////////
    
    func test_get_method() {
        let parameters = [UDParseClient.ParametersKey.Where: ["uniqueKey": "1234"]]
        let task = UDParseClient.sharedInstance().taskForGETMethod(UDParseClient.ClassesKey.StudentLocation, parameters: parameters) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "GET")
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_post_method() {
        let parameters = [UDParseClient.ParametersKey.Where: ["uniqueKey": "1234"]]
        let body = ["uniqueKey": "1234", "key1": "value1"]
        let task = UDParseClient.sharedInstance().taskForPOSTMethod(UDParseClient.ClassesKey.StudentLocation, parameters: parameters, jsonBody: body) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "POST")
        XCTAssertNotNil(URLRequest.HTTPBody)
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let contentType: String! = URLRequest.valueForHTTPHeaderField("Content-Type")
        XCTAssertEqual(contentType, "application/json")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_put_method() {
        let parameters = [UDParseClient.ParametersKey.Where: ["uniqueKey": "1234"]]
        let body = ["uniqueKey": "1234", "key1": "value1"]
        let task = UDParseClient.sharedInstance().taskForPUTMethod(UDParseClient.ClassesKey.StudentLocation, parameters: parameters, jsonBody: body) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task?.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "PUT")
        XCTAssertNotNil(URLRequest.HTTPBody)
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let contentType: String! = URLRequest.valueForHTTPHeaderField("Content-Type")
        XCTAssertEqual(contentType, "application/json")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    //////////////////////////////////
    // Retrieves object
    /////////////////////////////////
    
    func test_query_student_locations() {
        let expectation = self.expectationWithDescription(nil)
        
        let parameters: [String: AnyObject] = [UDParseClient.ParametersKey.Order: "-\(UDParseClient.ParametersValue.updatedAt)",
            UDParseClient.ParametersKey.Limit: 5]
        
        UDParseClient.queryStudentLocations(parameters) { results, error in
            
            if error == nil {
                println(results)
            }
            else {
                println(error)
            }
            
            XCTAssertNotNil(results)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test_query_next_page() {
        let expectation = self.expectationWithDescription(nil)
        
        let parameters: [String: AnyObject] = [UDParseClient.ParametersKey.Order: "-\(UDParseClient.ParametersValue.updatedAt)",
            UDParseClient.ParametersKey.Limit: 5, UDParseClient.ParametersKey.Skip: 5]
        
        UDParseClient.queryStudentLocations(parameters) { results, error in
            
            if error == nil {
                println(results)
            }
            else {
                println(error)
            }
            
            XCTAssertNotNil(results)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test_recursive() {
        let parameters: [String: AnyObject] = [UDParseClient.ParametersKey.Order: "-\(UDParseClient.ParametersValue.updatedAt)"]
            
        let expectation = self.expectationWithDescription(nil)
        var resultCount = 0
        UDParseClient.recurQueryStudentLocations(parameters) { result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let queryResult = result as? [AnyObject] {
                    resultCount += queryResult.count
                    
                    if resultCount == 225 {
                        expectation.fulfill()
                    }
                    println("Got results \(queryResult.count)")
                }
            }
        }
        
        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    //////////////////////////////////
    // Retrieves object
    /////////////////////////////////
    
    // must change this 2 value before test
    let USER_ID = "my_user_id"
    let OBJECT_ID = "my_object_id"
    
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
    
    func test_post_user_location() {
        let expectation = self.expectationWithDescription(nil)
        
        let userInfo = ["longitude": -71.056742, "lastName": "my_last_name", "latitude": 42.358894, "firstName": "my_first_name", "uniqueKey": USER_ID, "mapString": "Boston, MA, United States", "mediaURL": "http://udacity.com"] as [String: AnyObject]
        
        let task = UDParseClient.postStudentLocation(userInfo) { result, error in
            println(result)
            println(error)
            
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            
            XCTAssertNotNil(result["objectId"])
            XCTAssertNotNil(result["updatedAt"])
            XCTAssertNotNil(result["createdAt"])
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test_get_user_location() {
        let expectation = self.expectationWithDescription(nil)
        
        let task = UDParseClient.getStudentLocation(USER_ID) { result, error in
            println(result)
            println(error)
            
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            
            XCTAssertNotNil(result["updatedAt"])
            XCTAssertNotNil(result["uniqueKey"])
            XCTAssertNotNil(result["objectId"])
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test_update_user_location() {
        let expectation = self.expectationWithDescription(nil)
        
//        let userInfo = ["longitude": -71.056742, "lastName": "my_last_name", "latitude": 42.358894, "firstName": "my_first_name", "uniqueKey": USER_ID, "mapString": "Boston, MA, United States", "mediaURL": "http://udacity.com/my_profile"] as [String: AnyObject]
        
        let userInfo = ["mediaURL": "http://udacity.com/my_profile",
            "uniqueKey": USER_ID] as [String: AnyObject]
        
        let task = UDParseClient.updateStudentLocation(OBJECT_ID, postBody: userInfo) { result, error in
            println(result)
            println(error)
            
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            
            XCTAssertNotNil(result["updatedAt"])
            XCTAssertNotNil(result["uniqueKey"])
            XCTAssertNotNil(result["objectId"])
                        
            expectation.fulfill()
        }
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "PUT")
        XCTAssertNotNil(URLRequest.HTTPBody)
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let contentType: String! = URLRequest.valueForHTTPHeaderField("Content-Type")
        XCTAssertEqual(contentType, "application/json")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation/" + OBJECT_ID)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test_delete_current_location() {
        let expectation = self.expectationWithDescription(nil)
        
        let task = UDParseClient.deleteStudentLocation(OBJECT_ID) { result, error in
            println(result)
            println(error)
            
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            
            XCTAssertNotNil(result["updatedAt"])
            XCTAssertNotNil(result["uniqueKey"])
            XCTAssertNotNil(result["objectId"])
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
    }
}
